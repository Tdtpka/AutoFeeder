
#include <WiFi.h>
#include "time.h"
#include <Firebase_ESP_Client.h>
#include <ESP32Servo.h>
#include <NTPClient.h>
#include "soc/rtc.h"
#include "HX711.h"

//servo
const int servoPin = 33;
Servo myServo;

bool servoState = false;

//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// Insert Firebase project API Key
#define API_KEY "AIzaSyBsrZcPaky4y32ZajKiDy3HcfAvYCk3fjQ"

// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://auto-feed-29ce5-default-rtdb.firebaseio.com" 

//Define Firebase Data object
FirebaseData fbdo;
FirebaseJson json;
FirebaseJsonData nodeData;

FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;

const char* ssid     = "Tdt";
const char* password = "12345678";

const char* ntpServer = "vn.pool.ntp.org";
const int  gmtOffset_sec = 25200;
const uint8_t   daylightOffset_sec = 0;

struct tm timeinfo;
char feedTime[6];


char date[11];

// HX711 circuit wiring
const int LOADCELL_DOUT_PIN = 14;
const int LOADCELL_SCK_PIN = 27;
HX711 scale;

void setup(){
  Serial.begin(115200);

  myServo.attach(servoPin);

  // Connect to Wi-Fi
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected.");

  //Setup HX711
  rtc_cpu_freq_config_t configfreq;
  rtc_clk_cpu_freq_get_config(&configfreq);
  rtc_clk_cpu_freq_mhz_to_config(80, &configfreq);
  rtc_clk_cpu_freq_set_config_fast(&configfreq);
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(-456.7);
  scale.tare();

  // Init and get the time
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  getLocalTime(&timeinfo);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("ok");
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  WiFi.disconnect(true);
  delay(1000);
  WiFi.begin(ssid, password);
  Serial.println(WiFi.status());
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop(){
  getLocalTime(&timeinfo);
  snprintf(date, sizeof(date), "%04d-%02d-%02d", timeinfo.tm_year+1900, timeinfo.tm_mon+1, timeinfo.tm_mday);
  char time[6];
  snprintf(time, sizeof(time), "%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min);
  Serial.println((String)timeinfo.tm_wday);
  Firebase.RTDB.setString(&fbdo, "/food", scale.get_units());

  if(Firebase.RTDB.getBool(&fbdo, "/switchState")){
    bool switchState = fbdo.boolData();
    if(servoState!=switchState && switchState==true){
      myServo.write(180);
      saveHistory("Bật switch qua app");
      strcpy(feedTime, time);
    }else if(servoState!= switchState && switchState == false){
      myServo.write(0);
    }
    servoState = switchState;
  }
  if(strcmp(feedTime, time) != 0){
    if(Firebase.RTDB.getBool(&fbdo, "/every/"+String(time))){
      if(fbdo.boolData()==true){
        myServo.write(180);
        saveHistory("Hẹn giờ");
        strcpy(feedTime, time);
        Serial.print(String(feedTime));
        Serial.print("feeded");
        delay(1000);
        myServo.write(0);
      }
    }else if(Firebase.RTDB.getBool(&fbdo, "/day/"+String(date)+"/"+String(time))){
      Serial.println("y");
      if(fbdo.boolData()==true){
        myServo.write(180);
        saveHistory("Hẹn giờ");
        strcpy(feedTime, time);
        Serial.print(String(feedTime));
        Serial.print("feeded");
        delay(1000);
        myServo.write(0);
      }
    }else if(Firebase.RTDB.getJSON(&fbdo, "week")){
      json.setJsonData(fbdo.payload());
      if(json.get(nodeData, "/"+(String)timeinfo.tm_wday+"/"+String(time))){
        if(nodeData.to<bool>() == true){
          myServo.write(180);
          saveHistory("Hẹn giờ");
          strcpy(feedTime, time);
          Serial.print(String(feedTime));
          Serial.print("feeded");
          delay(1000);
          myServo.write(0);
        }
      }
    }
  }
}

void printLocalTime(){
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");
}
void saveHistory(String method){
  char saveTime[8];
  snprintf(saveTime, sizeof(saveTime), "%02d:%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
  int index = 0;
  if(Firebase.RTDB.getJSON(&fbdo, "/history/"+String(date))){
    json.setJsonData(fbdo.payload());  // Lấy dữ liệu JSON từ Firebase
    index = ((int) json.iteratorBegin())/3;  // Lấy số phần tử trong JSON Array
    json.iteratorEnd();  
  }
  Firebase.RTDB.setString(&fbdo, "/history/"+String(date)+"/"+String(index)+"/Time", saveTime);
  Firebase.RTDB.setString(&fbdo, "/history/"+String(date)+"/"+String(index)+"/Method", method);
}

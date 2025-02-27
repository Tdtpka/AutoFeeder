import 'package:auto_feed/feedHistory.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyBsrZcPaky4y32ZajKiDy3HcfAvYCk3fjQ",
    authDomain: "auto-feed-29ce5.firebaseapp.com",
    databaseURL: "https://auto-feed-29ce5-default-rtdb.firebaseio.com",
    appId: "1:489884048194:web:39100a5a8c884c3abc06db",
    messagingSenderId: "489884048194",
    projectId: "auto-feed-29ce5",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _onHour;
  int? _onMinute;
  bool isSwitched = false;
  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("/");
  @override
  void initState() {
    super.initState();
    _loadSwitchState();
    dbRef.child("schedule").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _onHour = data['hour'];
          _onMinute = data['minute'];
        });
      }
    });
  }

  void _updateSchedule(int hour, int minute) async {
    try {
      await dbRef.child("schedule").set({
        "hour": hour,
        "minute": minute,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!);
      },
    );
    if (picked != null) {
      setState(() {
        _onHour = picked.hour;
        _onMinute = picked.minute;
      });
      _updateSchedule(picked.hour, picked.minute);
    }
  }

  void _loadSwitchState() {
    dbRef.child('switchState').onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      setState(() {
        isSwitched = value;
      });
    });
  }

  void _updateSwitchState(bool value) {
    dbRef.child("switchState").set(value);
  }

  @override
  Widget build(BuildContext context) {
    String scheduleText = "Chưa đặt giờ cho ăn";
    if (_onHour != null && _onMinute != null) {
      scheduleText = "Lịch trình: $_onHour:$_onMinute";
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Switch State'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSwitched ? "ON" : "OFF",
              style: const TextStyle(fontSize: 24),
            ),
            Switch(
                value: isSwitched,
                onChanged: (bool value) {
                  setState(() {
                    isSwitched = value;
                  });
                  _updateSwitchState(value);
                }),
            const SizedBox(
              height: 20,
            ),
            Text(scheduleText),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text("Chọn thời gian"),
            ),
            ElevatedButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>FeedHistoryPage())), child: Text("History"))
          ],
        ),
      ),
    );
  }
}

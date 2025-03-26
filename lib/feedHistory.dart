import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FeedHistoryPage extends StatefulWidget {
  const FeedHistoryPage({super.key});

  @override
  _FeedHistoryPageState createState() => _FeedHistoryPageState();
}

class _FeedHistoryPageState extends State<FeedHistoryPage> {
  // Lấy tham chiếu đến node "feed_history" trong Firebase Realtime Database
  final DatabaseReference _feedHistoryRef =
      FirebaseDatabase.instance.ref("history");

  // Biến lưu trữ dữ liệu feed history
  Map<dynamic, dynamic> feedHistory = {};

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi dữ liệu trong node feed_history
    _feedHistoryRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          feedHistory = Map<dynamic, dynamic>.from(data);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách các timestamp (key của feed_history)
    List<String> feedTimes =
        feedHistory.keys.map((key) => key.toString()).toList();

    feedTimes.sort((a, b) => b.compareTo(a));

    return Center(
      child: ListView.builder(
        itemCount: feedTimes.length,
        itemBuilder: (context, index) {
          String day = feedTimes[index];
          List<dynamic> feedData = feedHistory[day];
          return Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.lightBlueAccent, borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$day (${feedData.length})", style: TextStyle(fontSize: 20),),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                        itemCount: feedData.length,
                        itemBuilder: (context, index){
                          return Container(
                            decoration: BoxDecoration(color: Colors.lightBlueAccent),
                              child: Text("${index+1} : ${feedData[index]['Time']} - ${feedData[index]['Method']}"),
                            );
                          }
                    ),
                  )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:auto_feed/history.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FeedHistoryPage extends StatefulWidget {
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

    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: feedTimes.length,
        itemBuilder: (context, index) {
          String day = feedTimes[index];
          Map<dynamic, dynamic> feedData = feedHistory[day];
          return ListTile(
            title: Text("$day"),
            subtitle: Text("$feedData"),
          );
        },
      ),
    );
  }
}
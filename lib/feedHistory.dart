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
            margin: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.amberAccent), child: Text("$day (${feedData.length})", style: TextStyle(fontSize: 20),)),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView.builder(
                    shrinkWrap: true,
                      itemCount: feedData.length,
                      itemBuilder: (context, index){
                        return Container(
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(border: Border.all(color: index.isEven? Colors.blueAccent: Colors.lightBlueAccent), borderRadius: const BorderRadius.all(Radius.circular(10))),
                            child: Text("${index+1} : ${feedData[index]['Time']} - ${feedData[index]['Method']}"),
                          );
                        }
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

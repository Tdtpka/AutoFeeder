import 'package:auto_feed/feedhistory.dart';
import 'package:auto_feed/home.dart';
import 'package:auto_feed/schedule.dart';
import 'package:firebase_core/firebase_core.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int myIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> listWidget = const [
      MyHomePage(),
      SchedulePage(),
      FeedHistoryPage()
    ];
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("$myIndex"),
      ),
      body: Center(child: listWidget[myIndex]),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
          currentIndex: myIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.schedule), label: "Schedule"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
          ]),
    ));
  }
}

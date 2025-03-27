import 'package:auto_feed/feedhistory.dart';
import 'package:auto_feed/firebase_options.dart';
import 'package:auto_feed/home.dart';
import 'package:auto_feed/schedule.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int myIndex = 0;
  String page = "Trang chủ";
  @override
  Widget build(BuildContext context) {
    List<Widget> listWidget = const [
      MyHomePage(),
      SchedulePage(),
      FeedHistoryPage()
    ];
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("$page"),
          ),
          body: Center(child: listWidget[myIndex]),
          bottomNavigationBar: BottomNavigationBar(
              onTap: (index) {
                setState(() {
                  switch (index) {
                    case 0:
                      page = "Trang chủ";
                      break;
                    case 1:
                      page = "Lịch cho ăn";
                      break;
                    case 2:
                      page = "Lịch sử";
                  }
                  myIndex = index;
                });
              },
              currentIndex: myIndex,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.schedule), label: "Lịch"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: "Lịch sử"),
              ]),
        ));
  }
}

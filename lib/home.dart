import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _onHour;
  int? _onMinute;
  bool isSwitched = false;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("/");
  @override
  void initState() {
    super.initState();
    _loadSwitchState();
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
    return Center(
      child: Column(
        children: [
          Switch(value: isSwitched, onChanged: (value){
            isSwitched = value;
            _updateSwitchState(value);
          })
        ],
      ),
    );
  }
}

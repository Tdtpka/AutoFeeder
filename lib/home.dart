import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  bool isSwitched = false;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("/");
  StreamSubscription<DatabaseEvent>? _subscription;
  @override
  void initState() {
    super.initState();
    _loadSwitchState();
  }
  @override 
  void dispose(){
    _subscription!.cancel();
    super.dispose();
  }

  void _loadSwitchState() async{
    _subscription = dbRef.child('switchState').onValue.listen((event) {
      if(!mounted) return;
      final dynamic value = event.snapshot.value;
      setState(() {
        isSwitched = value;
      });
    });
  }

  void _updateSwitchState(bool value) async{
    await dbRef.child("switchState").set(value);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Cho thú cưng ăn"),
          Switch(value: isSwitched, onChanged: (value){
            isSwitched = value;
            _updateSwitchState(value);
          })
        ],
      ),
    );
  }
}

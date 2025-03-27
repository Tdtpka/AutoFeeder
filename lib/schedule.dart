import 'dart:async';

import 'package:auto_feed/schedule_tile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("/");
  List<Map<String, dynamic>> schedule = [];
  StreamSubscription<DatabaseEvent>? _subscription;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _loadData() {
    _subscription =
        _dbRef.child("schedule").onValue.listen((DatabaseEvent event) {
      if (!mounted) return;
      final data = event.snapshot.value as List<dynamic>?;
      if (data != null) {
        setState(() {
          schedule.clear();
          for (int i = 0; i < data.length; i++) {
            if (data[i] != null) {
              var type = data[i]['type'];
              switch (type) {
                case "every":
                  var time = data[i]['time'];
                  var date = "Mỗi ngày";
                 bool status = data[i]['status'];
                  schedule.add({
                    'key' : i,
                    'time': time,
                    'date': date,
                    'type': type,
                    'status': status
                  });
                  break;
                default:
                  var time = data[i]['time'];
                  var date = data[i]['date'];
                  bool status = data[i]['status'];
                  schedule.add({
                    'key': i,
                    'time': time,
                    'date': date,
                    'type': type,
                    'status': status,
                  });
                  break;
              }
            }
          }
        });
      }
    });
  }

  void _showCustomDialog(BuildContext context) {
    List<int> week = [];
    String date = "";
    DateTime? selectedDate;
    TextEditingController hourController = TextEditingController();
    TextEditingController minuteController = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Popup",
      transitionDuration: Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("x"),
                      )
                    ],
                  ),
                  Card(
                      child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                              controller: hourController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ]),
                        ),
                      ),
                      const Text(":"),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                            controller: minuteController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ]),
                      ))
                    ],
                  )),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? "${selectedDate!.toLocal()}".split(' ')[0]
                                : "",
                            style: const TextStyle(
                                fontSize: 20,
                                decoration: TextDecoration.none,
                                color: Colors.black),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate:
                                      DateTime(DateTime.now().year, 12, 31));
                              if (picked != null && picked != selectedDate) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: const Icon(Icons.calendar_month_rounded),
                          )
                        ]),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      width: 400,
                      height: 50,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (!week.contains(index)) {
                                    week.add(index);
                                  } else {
                                    week.removeWhere((wday) => wday == index);
                                  }
                                  week.sort();
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                padding: const EdgeInsets.all(5),
                                width: 40,
                                decoration: BoxDecoration(
                                    color: week.contains(index)
                                        ? Colors.lightGreenAccent
                                        : Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50))),
                                child: Center(
                                    child: Text(
                                  index == 0 ? "CN" : "${index + 1}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      decoration: TextDecoration.none),
                                )),
                              ),
                            );
                          })),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String time =
                          "${hourController.text.trim()}:${minuteController.text.trim()}";
                      if (time.isEmpty || selectedDate == null) {
                        showGeneralDialog(
                            context: context,
                            barrierLabel: "Popup",
                            barrierDismissible: true,
                            transitionDuration: Duration(milliseconds: 100),
                            pageBuilder: (context, animation, animation2) {
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Colors.white),
                                  width: 350,
                                  child: Text(
                                    "Chưa chọn ngày hoặc giờ",
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontSize: 20,
                                        color: Colors.black),
                                  ),
                                ),
                              );
                            });
                        return;
                      }
                      if (selectedDate != null) {
                        date = selectedDate!.toLocal().toString().split(" ")[0];
                        _dbRef.child("day/$date/$time").set(true);
                        _dbRef
                            .child("schedule/${schedule.length}")
                            .set({'date': date, 'time': time, 'type': 'day', 'status': true});
                        _loadData();
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Lưu"),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      const SizedBox(
        height: 30,
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: FloatingActionButton(
          onPressed: () {
            _showCustomDialog(context);
          },
          child: const Text("+"),
        ),
      ),
      SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: schedule.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: ListView.builder(
                    itemCount: schedule.length,
                    itemBuilder: (context, index) {
                      return ScheduleTile(schedule[index]);
                    },
                    shrinkWrap: true,
                  ),
                ),
        ),
      )
    ]));
  }
}

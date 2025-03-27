import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ScheduleTile extends StatefulWidget {
  final dynamic schedule;
  const ScheduleTile(this.schedule, {super.key});

  @override
  State<ScheduleTile> createState() => _ScheduleTileState();
}

class _ScheduleTileState extends State<ScheduleTile> {
  bool _status = false;
  final List<String> _wday = [];
  @override
  void initState() {
    super.initState();
    if (widget.schedule['type'] == "week") {
      for (var i in widget.schedule['date']) {
        switch (i) {
          case 0:
            _wday.add("CN");
            break;
          case 1:
            _wday.add("T2");
            break;
          case 2:
            _wday.add("T3");
            break;
          case 3:
            _wday.add("T4");
            break;
          case 4:
            _wday.add("T5");
            break;
          case 5:
            _wday.add("T6");
            break;
          case 6:
            _wday.add("T7");
            break;
        }
      }
    }    
    _status = widget.schedule['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.schedule['time']}"),
                widget.schedule['type'] == "week"
                    ? Text(_wday.join(", "))
                    : Text("${widget.schedule['date']}")
              ],
            ),
          ),
          Expanded(
            child: Switch(
                value: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value;
                    DatabaseReference dbRef =
                        FirebaseDatabase.instance.ref("/");
                    switch (widget.schedule['type']) {
                      case "every":
                        dbRef
                            .child("every/${widget.schedule['time']}")
                            .set(value);
                        break;
                      case "day":
                        {
                          dbRef
                              .child("day/${widget.schedule['date']}/${widget.schedule['time']}")
                              .set(value);
                        }
                        break;
                      case "week":
                        for (var i in widget.schedule['date']) {
                          dbRef
                              .child("week/$i/${widget.schedule['time']}")
                              .set(value);
                        }
                        break;
                    }
                    dbRef.child("schedule/${widget.schedule['key']}/status").set(value);
                  });
                }),
          ),
        ],
      ),
    );
  }
}

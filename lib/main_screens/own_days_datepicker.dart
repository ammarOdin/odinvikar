import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/date_week_extensions.dart';



class OwnDaysDatepicker extends StatefulWidget {
  const OwnDaysDatepicker({Key? key}) : super(key: key);

  @override
  State<OwnDaysDatepicker> createState() => _OwnDaysDatepickerState();
}

class _OwnDaysDatepickerState extends State<OwnDaysDatepicker> {

  get saveShift => FirebaseFirestore.instance.collection(user!.uid);
  User? user = FirebaseAuth.instance.currentUser;

  bool isSwitched = false;
  late DateTime _pickedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  DateTime initialDate() {
    if (DateTime.now().weekday == DateTime.saturday){
      return DateTime.now().add(const Duration(days: 2));
    } else if (DateTime.now().weekday == DateTime.sunday){
      return DateTime.now().add(const Duration(days: 1));
    } else {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false, appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const BackButton(color: Colors.black,),
    ),
      body: Column(
          children: [
            Center(
              child: Text("Vælg dato", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  TextButton.icon(onPressed: null, icon: Icon(Icons.access_time), label: Text("Varighed")),
                  const Spacer(),
                  SizedBox(
                    width: 200,
                    child: SwitchListTile(
                      title: const Text("Hele dagen"),
                      value: isSwitched,
                      onChanged: (bool value) {
                        setState((){
                          isSwitched = value;
                          if (kDebugMode){
                            print(isSwitched);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isSwitched == false){
                        _pickedDay = (await showDatePicker(
                            locale : const Locale("da","DA"),
                            selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true,
                            context: context,
                            confirmText: "Vælg dag",
                            cancelText: "Annuller",
                            initialDate: initialDate(),
                            firstDate: initialDate(),
                            lastDate: DateTime.now().add(const Duration(days: 90))))!;

                        _startTime = (await showTimePicker(context: context, helpText: "Fra", initialTime: TimeOfDay(hour: 8, minute: 0)))!;
                        _endTime = (await showTimePicker(context: context, helpText: "Til", initialTime: TimeOfDay(hour: 10, minute: 0)))!;

                        final f = DateFormat('dd-MM-yyyy');
                        var pickedDate = f.format(_pickedDay);
                        var pickedMonth = _pickedDay.month;
                        var pickedWeek = _pickedDay.weekOfYear;
                        var start = _startTime.toString();
                        var end = _endTime.toString();
                        var pickedTime = '$start - $end';

                        saveShift.doc(pickedDate).get().then((DocumentSnapshot documentSnapshot) async {
                          if (documentSnapshot.exists) {
                            _showSnackBar(context, "Vagten findes allerede!", Colors.red);
                          } else if (!documentSnapshot.exists){
                            await saveShift.doc(pickedDate).set({'date': pickedDate,'month': pickedMonth, 'week': pickedWeek, 'time': pickedTime});
                            _showSnackBar(context, "Vagt Tilføjet", Colors.green);
                          }
                        });

                        Navigator.pop(context);

                      } else if (isSwitched == true){
                        _pickedDay = (await showDatePicker(
                            locale : const Locale("da","DA"),
                            selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true,
                            context: context,
                            confirmText: "Vælg dag",
                            cancelText: "Annuller",
                            initialDate: initialDate(),
                            firstDate: initialDate(),
                            lastDate: DateTime.now().add(const Duration(days: 90))))!;

                        final f = DateFormat('dd-MM-yyyy');
                        var pickedDate = f.format(_pickedDay);
                        var pickedMonth = _pickedDay.month;
                        var pickedWeek = _pickedDay.weekOfYear;

                        saveShift.doc(pickedDate).get().then((DocumentSnapshot documentSnapshot) async {
                          if (documentSnapshot.exists) {
                            _showSnackBar(context, "Vagten findes allerede!", Colors.red);
                          } else if (!documentSnapshot.exists){
                            await saveShift.doc(pickedDate).set({'date': pickedDate,'month': pickedMonth, 'week': pickedWeek});
                            saveShift.get();
                            _showSnackBar(context, "Vagt Tilføjet", Colors.green);
                          }

                        });
                      Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.navigate_next),
                    label: Text("Næste"))),
          ]
      ),);
  }
}

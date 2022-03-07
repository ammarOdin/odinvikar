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
  late DateTime? _pickedDay = DateTime.now();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String _startDropDownValue = "8:00";
  String _endDropDownValue = "8:00";

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
      body: ListView(
          children: [
            Center(
              child: Text("Vælg dato", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
            ),

            Container(
              padding: EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  TextButton.icon(onPressed: null, icon: Icon(Icons.date_range), label: Text("Dato")),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                        onPressed: () async {
                      _pickedDay = (await showDatePicker(
                      locale : const Locale("da","DA"),
                      selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true,
                      context: context,
                      confirmText: "Vælg dag",
                      cancelText: "Annuller",
                      initialDate: initialDate(),
                      firstDate: initialDate(),
                      lastDate: DateTime.now().add(const Duration(days: 90))))!;
                      setState(() {
                        _pickedDay;
                      });
                    }, child: Text('${DateFormat('dd-MM-yyyy').format(_pickedDay!)}'),),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.only(top: 10, bottom: 20),
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
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isSwitched == false) Center(child: Column(
              children: [
                Row(children: [
                  Column(
                      children: [
                        Container(padding: EdgeInsets.only(bottom: 5), child: Text("Fra")),
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          margin: EdgeInsets.only(left: 60, right: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              icon: Icon(Icons.keyboard_arrow_down),
                              value: _startDropDownValue,
                                items: <String>['8:00', '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue){
                                setState(() {
                                  _startDropDownValue = newValue!;
                                });
                                }),
                          ),
                        ),
                      ],
                    ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(padding: EdgeInsets.only(bottom: 5), child: Text("Til")),
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          margin: EdgeInsets.only(left: 30, right: 30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                icon: Icon(Icons.keyboard_arrow_down),
                                value: _endDropDownValue,
                                items: <String>['8:00', '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue){
                                  setState(() {
                                    _endDropDownValue = newValue!;
                                  });
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],),

            ],)) else Container(),

            Container(
              padding: EdgeInsets.all(20),
                child: ElevatedButton.icon(
                    onPressed: () async {
                      final f = DateFormat('dd-MM-yyyy');
                      var pickedDate = f.format(_pickedDay!);
                      var pickedMonth = _pickedDay?.month;
                      var pickedWeek = _pickedDay?.weekOfYear;
                      var timeRange = '';

                      if (isSwitched == false){
                         timeRange = '$_startDropDownValue - $_endDropDownValue';
                      } else if (isSwitched == true){
                        timeRange = 'Hele dagen';
                      }
                      saveShift.doc(pickedDate).get().then((DocumentSnapshot documentSnapshot) async {
                        if (documentSnapshot.exists) {
                          _showSnackBar(context, "Vagten findes allerede!", Colors.red);
                        } else if (!documentSnapshot.exists){
                          await saveShift.doc(pickedDate).set({'date': pickedDate,'month': pickedMonth, 'week': pickedWeek, 'time': timeRange});
                          saveShift.get();
                          _showSnackBar(context, "Vagt Tilføjet", Colors.green);
                        }
                      });
                    },
                    icon: Icon(Icons.navigate_next),
                    label: Text("Tilføj Dag"))),
          ]
      ),);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/card_assets.dart';
import 'package:intl/intl.dart';

import '../shift_system/shift_details.dart';
import 'own_days_details.dart';


class ShiftHistoryScreen extends StatefulWidget {
  const ShiftHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ShiftHistoryScreen> createState() => _ShiftHistoryScreenState();
}

class _ShiftHistoryScreenState extends State<ShiftHistoryScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  get unsortedShift => FirebaseFirestore.instance.collection(user!.uid).orderBy('date', descending: false);
  get shifsystemShifts => FirebaseFirestore.instance.collection('shifts');

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];
  late String dropdownValue;

  @override
  initState(){
    dropdownValue = getDropdownValue();
    super.initState();
  }

  getDropdownValue(){
    return months[DateTime.now().month - 1];
  }

  calculateHours(String month) async {
    var assignedShiftsRef = await FirebaseFirestore.instance.collection(user!.uid).get();
    var shiftsystemRef = await FirebaseFirestore.instance.collection('shifts').get();

    List shiftsystemList = [];
    List assignedShiftList = [];

    List shiftsystemHours = [];
    List shiftsystemMin = [];
    List assignedShiftHours = [];
    List assignedShiftMin = [];

    var totalHours;
    var totalMin;

    // save assigned shifts
    for (var assignedShifts in assignedShiftsRef.docs){
      String assignedMonth = months[assignedShifts.get(FieldPath(const ["month"])) - 1];
      if (month == assignedMonth && assignedShifts.get(FieldPath(const ["awaitConfirmation"])) != 0){
        if (assignedShifts.get(FieldPath(const['details'])) != ""){
          assignedShiftList.add(assignedShifts.get(FieldPath(const['details'])).substring(0,11));
        }
      }
    }
    // save shiftsystem shifts
    for (var shiftSystemShifts in shiftsystemRef.docs){
      String shiftMonth = months[shiftSystemShifts.get(FieldPath(const['month'])) - 1];
      if (shiftSystemShifts.get(FieldPath(const['userID'])) == user!.uid && month == shiftMonth){
        if (shiftSystemShifts.get(FieldPath(const['time'])) != ""){
          shiftsystemList.add(shiftSystemShifts.get(FieldPath(const['time'])));
        }
      }
    }
    // remove "Tilkaldt" from list, if exists
    assignedShiftList.removeWhere((element) => element.contains("Tilkaldt"));

    // save hours and minutes by looping through lists
    for (var assignedTime in assignedShiftList){
      var format = DateFormat("HH:mm");
      var start = format.parse(assignedTime.substring(0,5));
      var end = format.parse(assignedTime.substring(6));

      Duration duration = end.difference(start).abs();
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      assignedShiftHours.add(hours);
      assignedShiftMin.add(minutes);
    }

    for (var bookedTime in shiftsystemList){
      var format = DateFormat("HH:mm");
      var start = format.parse(bookedTime.substring(0,5));
      var end = format.parse(bookedTime.substring(6));

      Duration duration = end.difference(start).abs();
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      shiftsystemHours.add(hours);
      shiftsystemMin.add(minutes);
    }

    // calculate total hours + minutes from both lists

    // Vagtbanken list
    final bookedHours;
    final bookedMinutes;
    if (!shiftsystemList.isEmpty){
      bookedHours = shiftsystemHours.reduce((value, element) => value + element);
      bookedMinutes = shiftsystemMin.reduce((value, element) => value + element);
    } else {
      bookedMinutes = 0;
      bookedHours = 0;
    }

    // Tilgængelighedskalenderen list
    final assignedHours;
    final assignedMinutes;
    if (!assignedShiftList.isEmpty){
      assignedHours = assignedShiftHours.reduce((value, element) => value + element);
      assignedMinutes = assignedShiftMin.reduce((value, element) => value + element);
    } else {
      assignedMinutes = 0;
      assignedHours = 0;
    }

    var totalTime = (bookedHours * 60) + (assignedHours * 60) + bookedMinutes + assignedMinutes;
    totalHours = (totalTime / 60).round();
    totalMin = totalTime % 60;

    return totalHours.toString() + " timer og " + totalMin.toString() + " minutter" ;
  }

  calculateShifts(String month) async {
    var assignedShiftsRef = await FirebaseFirestore.instance.collection(user!.uid).get();
    var shiftsystemRef = await FirebaseFirestore.instance.collection('shifts').get();

    List shiftsystemList = [];
    List assignedShiftList = [];

    for (var assignedShifts in assignedShiftsRef.docs){
      String assignedMonth = months[assignedShifts.get(FieldPath(const ["month"])) - 1];
      if (month == assignedMonth && assignedShifts.get(FieldPath(const ["awaitConfirmation"])) != 0){
        if (assignedShifts.get(FieldPath(const['details'])) != ""){
          assignedShiftList.add(assignedShifts.get(FieldPath(const['details'])).substring(0,11));
        }
      }
    }
    // save shiftsystem shifts
    for (var shiftSystemShifts in shiftsystemRef.docs){
      String shiftMonth = months[shiftSystemShifts.get(FieldPath(const['month'])) - 1];
      if (shiftSystemShifts.get(FieldPath(const['userID'])) == user!.uid && month == shiftMonth && shiftSystemShifts.get(FieldPath(const ["awaitConfirmation"])) != 0){
        if (shiftSystemShifts.get(FieldPath(const['time'])) != ""){
          shiftsystemList.add(shiftSystemShifts.get(FieldPath(const['time'])));
        }
      }
    }
    // remove "Tilkaldt" from list, if exists
    //assignedShiftList.removeWhere((element) => element.contains("Tilkaldt"));
    return shiftsystemList.length + assignedShiftList.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mine timer"),
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 18, color: Colors.white,),),
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          // Month dropdown
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Center(
              child: DropdownButton<String>(
                underline: Container(color: Colors.grey, height: 1,),
                value: dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });},
                items: [for (var num = 0; num <= 11; num++) DropdownMenuItem(child: Text(months[num]), value: months[num])],
                icon: Icon(Icons.keyboard_arrow_down), ),
            ),
          ),

          FutureBuilder(
            future: calculateHours(dropdownValue),
            builder: (context, snapshot) {
              if (snapshot.hasData){
                return Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: Text("Timer: " + snapshot.data.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                );
              } else if (!snapshot.hasData) {
                return Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: Text("Timer: ingen", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                );
              } else {
                return Container();
              }
            }
          ),

          Container(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text("Timer beregnes ud fra de vagter du er blevet tildelt, og fra vagtbanken - der tages ikke udgangspunkt i timer fra tilkaldelse.", style: TextStyle(color: Colors.grey, fontSize: 12),),
          ),

          FutureBuilder(
              future: calculateShifts(dropdownValue),
              builder: (context, snapshot) {
                if (snapshot.hasData){
                  return Container(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text("Antal vagter: " + snapshot.data.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  );
                } else if (!snapshot.hasData) {
                  return Container(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text("Antal vagter: ingen", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  );
                } else {
                  return Container();
                }
              }
          ),

          const Divider(thickness: 1,),

          // Cards of shifts on selected month
          StreamBuilder(
            stream: unsortedShift.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitFoldingCube(
                  color: Colors.blue,
                  size: 50,
                ));
              }
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10, bottom: 20, top: 20),
                    child: Text("Tilgængelighedskalenderen", style: TextStyle(fontSize: 16),),
                  ),
                  Column(
                    children: snapshot.data!.docs.map((document){
                      if (months[document['month'] - 1] == dropdownValue && document['awaitConfirmation'] == 2){
                        var reference = document as QueryDocumentSnapshot<Map<String, dynamic>>;
                        return ShiftCard(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
                            date: document.id,
                            status: document['status'],
                            time: document['time'],
                            comment: document['comment'],
                            awaitConfirmation: document['awaitConfirmation'],
                            details: document['details'],
                            color: document['color'],
                            data: reference,
                          )));
                        }, text: document['date'].substring(0,5), subtitle: document['status'],);
                      } else {
                        return Container();
                      }
                    }).toList(),
                  ),
                ],
              );
            },
          ),

          // shiftsystem shifts
          StreamBuilder(
            stream: shifsystemShifts.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitFoldingCube(
                  color: Colors.blue,
                  size: 50,
                ));
              }
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10, bottom: 20, top: 20),
                    child: Text("Vagtbanken", style: TextStyle(fontSize: 16),),
                  ),
                  Column(
                    children: snapshot.data!.docs.map((document){
                      if (months[document['month'] - 1] == dropdownValue && document['awaitConfirmation'] == 2 && document['userID'] == user!.uid){
                        var reference = document as QueryDocumentSnapshot<Map<String, dynamic>>;
                        return ShiftCard(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftSystemDetailsScreen(
                            date: document['date'],
                            comment: document['comment'],
                            time: document['time'],
                            name: document['name'],
                            token: document['token'],
                            data: document.id,
                            status: document['status'],
                            awaitConfirmation: document['awaitConfirmation'],
                            acute: document['isAcute'],
                            color: document['color'] ,
                          )));
                        }, text: document['date'].substring(0,5), subtitle: "Taget vagt",);
                      } else {
                        return Container();
                      }
                    }).toList(),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}

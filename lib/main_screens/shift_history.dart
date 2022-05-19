import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/card_assets.dart';
import 'package:intl/intl.dart';


class ShiftHistoryScreen extends StatefulWidget {
  const ShiftHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ShiftHistoryScreen> createState() => _ShiftHistoryScreenState();
}

class _ShiftHistoryScreenState extends State<ShiftHistoryScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  get unsortedShift => FirebaseFirestore.instance.collection(user!.uid).orderBy('date', descending: false);
  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];
  late String dropdownValue;
  List times = [];

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
        shiftsystemList.add(shiftSystemShifts.get(FieldPath(const['time'])));
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
      final bookedHours = shiftsystemHours.reduce((value, element) => value + element);
      final assignedHours = assignedShiftHours.reduce((value, element) => value + element);
      final bookedMinutes = shiftsystemMin.reduce((value, element) => value + element);
      final assignedMinutes = assignedShiftMin.reduce((value, element) => value + element);

      totalHours = bookedHours + assignedHours;
      totalMin = bookedMinutes + assignedMinutes;

      return totalHours.toString() +" timer og "+totalMin.toString() + " minutter";
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

          Container(
            padding: EdgeInsets.only(left: 10, bottom: 40, top: 10),
            child: Text("Antal vagter:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ),

          // Cards of shifts on selected month
          StreamBuilder(
            stream: unsortedShift.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitFoldingCube(
                  color: Colors.blue,
                  size: 50,
                ));
              }else if (snapshot.data!.docs.isEmpty){
                return Container(
                  padding: const EdgeInsets.all(50),
                  child: const Center(child: Text(
                    "Ingen Vagter",
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),),
                );
              }
              return Column(
                children: snapshot.data!.docs.map((document){
                  if (months[document['month'] - 1] == dropdownValue && document['awaitConfirmation'] == 2){
                    return ShiftCard(onPressed: (){calculateHours(dropdownValue);}, text: document['date'].substring(0,5), subtitle: document['status'],);
                  } else {
                    return Container();
                  }
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

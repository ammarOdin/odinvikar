import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'generate_pdf_invoice.dart';
import 'package:intl/intl.dart';

class AdminTotalHours extends StatefulWidget {
  const AdminTotalHours({Key? key}) : super(key: key);

  @override
  State<AdminTotalHours> createState() => _AdminTotalHoursState();
}

class _AdminTotalHoursState extends State<AdminTotalHours> {

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];

  late String dropdownValue;

  late String shiftAmount;
  late String shiftLength;
  late String averageLength;
  late String averagePay;
  late String commission;

  @override
  initState(){
    dropdownValue = getDropdownValue();
    super.initState();
  }

  getDropdownValue(){
    return months[DateTime.now().month - 1];
  }

  @override
  void dispose(){
    super.dispose();
  }

  Future<int> calculateTotalShiftAmount(String month) async {
    int totalShiftAmount = 0;
    var userRef = await FirebaseFirestore.instance.collection('user').get();
    var shiftsystemRef = await FirebaseFirestore.instance.collection('shifts').get();

    for (var shifts in shiftsystemRef.docs){
      String shiftMonth = months[shifts.get(FieldPath(const ["month"])) - 1];
      if (shifts.data()['awaitConfirmation'] == 2 && month == shiftMonth){
        totalShiftAmount++;
      }
    }

    for (var users in userRef.docs){
      var documentRef = await FirebaseFirestore.instance.collection(users.id).get();
      for (var document in documentRef.docs){
        String shiftMonth = months[document.get(FieldPath(const ["month"])) - 1];
        if (document.data()['awaitConfirmation'] == 2 && month == shiftMonth){
          totalShiftAmount++;
        }
      }
    }
    shiftAmount = totalShiftAmount.toString();
    return totalShiftAmount;
  }


  calculateTotalHours(String month) async {
    var totalHours;
    var totalMin;
    List shiftsystemList = [];
    List assignedShiftList = [];

    List shiftsystemHours = [];
    List shiftsystemMin = [];
    List assignedShiftHours = [];
    List assignedShiftMin = [];

    // save assigned shifts
    var userRef = await FirebaseFirestore.instance.collection('user').get();
    for (var users in userRef.docs){
      var documentRef = await FirebaseFirestore.instance.collection(users.id).get();
      for (var document in documentRef.docs){
        String shiftMonth = months[document.get(FieldPath(const ["month"])) - 1];
        if (document.data()['awaitConfirmation'] != 0 && month == shiftMonth && document.get(FieldPath(const['details'])) != ""){
          assignedShiftList.add(document.get(FieldPath(const['details'])).substring(0,11));
        }
      }
    }
    assignedShiftList.removeWhere((element) => element.contains("Tilkaldt"));

    // save bookingsystem shifts
    var shiftsRef = await FirebaseFirestore.instance.collection("shifts").get();
    for (var shifts in shiftsRef.docs){
      String shiftMonth = months[shifts.get(FieldPath(const ["month"])) - 1];
      if (shifts.data()['awaitConfirmation'] != 0 && month == shiftMonth && shifts.get(FieldPath(const['time'])) != ""){
        shiftsystemList.add(shifts.get(FieldPath(const['time'])));
      }
    }

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
    totalMin = (totalTime % 60) / 100;
    var result = totalHours + totalMin;
    shiftLength = result.toString();
    return totalHours + totalMin;
  }

  double calculateAverageHour() {
    var average = double.parse(shiftLength) / double.parse(shiftAmount);
    averageLength = average.toString();
    return average;
  }

  double calculateAverageSalary() {
    var average = double.parse(averageLength) * 215;
    averagePay = average.toString();
    return average;
  }

  double calculateCommission() {
    var commissionVal =  (0.04 * double.parse(averagePay)) * double.parse(shiftAmount);
    commission = commissionVal.toString();
    return commissionVal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Timer"),
        actions: [
          IconButton(onPressed: () async {
            final pdf = await PdfApi.generateInvoice(
              dropdownValue,
                shiftAmount,
                shiftLength,
                double.parse((calculateAverageHour()).toStringAsFixed(2)).toString(),
                double.parse((calculateAverageSalary()).toStringAsFixed(2)).toString(),
                double.parse((calculateCommission()).toStringAsFixed(2)).toString());
            PdfApi.openFile(pdf);
          }, icon: Icon(Icons.picture_as_pdf_outlined))
        ],
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 18,),),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 30),
            child: Center(
              child: DropdownButton<String>(
                underline: Container(color: Colors.grey, height: 1,),
                value: dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });},
                items: [for (var num = 0; num <= 11; num++) DropdownMenuItem(child: Text(months[num]), value: months[num])],
                icon: Icon(Icons.keyboard_arrow_down)),
            ),
          ),

          Container(
            padding: EdgeInsets.only(left: 10, bottom: 30),
            child: Text("Vejledende antal vagter og timer for valgte måned. Tallene bruges til at beregne gennemsnittelige antal timer per vagt, og ligeledes vejledende løn der tilskrives per vagt.", style: TextStyle(fontSize: 14, color: Colors.grey),),
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
            ),
            padding: EdgeInsets.only(top: 20, bottom: 10),
            margin: EdgeInsets.only(left: 10, right: 10),
            child: FutureBuilder(
                future: calculateTotalShiftAmount(dropdownValue),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    return Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Text("Antal vagter: "),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                          child: Text(snapshot.data.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        ),
                      ],
                    );
                  } else if (!snapshot.hasData) {
                    return Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Text("Antal vagter: "),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                          child: Text("...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white
            ),
            margin: EdgeInsets.only(left: 10, right: 10, top: 10),
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: FutureBuilder(
                future: calculateTotalHours(dropdownValue),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    return Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Text("Antal timer: "),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                          child: Text(snapshot.data.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        ),
                      ],
                    );
                  } else if (!snapshot.hasData) {
                    return Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Text("Antal timer: "),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                          child: Text("...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odinvikar/main_screens/own_days.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:week_of_year/date_week_extensions.dart';



class OwnDaysDatepicker extends StatefulWidget {
  final DateTime date;
  const OwnDaysDatepicker({Key? key, required this.date}) : super(key: key);

  @override
  State<OwnDaysDatepicker> createState() => _OwnDaysDatepickerState();
}

class _OwnDaysDatepickerState extends State<OwnDaysDatepicker> {

  get saveShift => FirebaseFirestore.instance.collection(user!.uid);
  User? user = FirebaseAuth.instance.currentUser;
  final databaseReference = FirebaseFirestore.instance;
  MeetingDataSource? events;

  bool isSwitched = false;
  late DateTime? _pickedDay = widget.date;

  late List<TimeOfDay> timeList;
  late TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = TimeOfDay(hour: 9, minute: 0);

  final commentController = TextEditingController();
  final GlobalKey<FormState> _commentKey = GlobalKey<FormState>();


  Future<void> getFirestoreShift() async {
    var snapShotsValue = await databaseReference.collection(user!.uid).get();

    List<Meeting> list = snapShotsValue.docs.map((e)=>
        Meeting(eventName: "Detaljer",
            from: DateFormat('dd-MM-yyyy').parse(e.data()['date']),
            to: DateFormat('dd-MM-yyyy').parse(e.data()['date']) ,
            background: DateTime.now().isAfter(DateFormat('dd-MM-yyyy').parse(e.data()['date']).add(const Duration(days: 1))) ? Colors.grey : Colors.indigoAccent,
            isAllDay: true)).toList();

    setState(() {
      events = MeetingDataSource(list);
    });
  }

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

  DateTime getDateFromCalendar(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == true){
      final tapDate = DateFormat('dd-MM-yyyy').format(calendarTapDetails.date as DateTime);
      if(kDebugMode){
        print(calendarTapDetails.date);
      }
      return tapDate as DateTime;
    } else {
      if (DateTime.now().weekday == DateTime.saturday){
        return DateTime.now().add(const Duration(days: 2));
      } else if (DateTime.now().weekday == DateTime.sunday){
        return DateTime.now().add(const Duration(days: 1));
      } else {
        return DateTime.now();
      }
    }
  }

  String? validateComment(String? input){
    if (input!.contains(new RegExp(r'^[#$^*():{}|<>]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: kToolbarHeight + 2,
        leading: const BackButton(color: Colors.white,),
    ),
      body: ListView(
          physics: ClampingScrollPhysics(),
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          children: [
            Container(
                  height: MediaQuery.of(context).size.height / 5,
                  padding: EdgeInsets.only(bottom: 30),
                  color: Colors.blue,
                  child: ListView(
                    padding: EdgeInsets.only(top: 40),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Center(
                        child: Text("Tilføj Dag", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 40, bottom: 10),
                  child: Row(
                    children: [
                      TextButton.icon(onPressed: null, icon: Icon(Icons.date_range), label: Text("Dato")),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.only(right: 20),
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(color: Colors.blue)
                              )
                          )),
                            onPressed: () async {
                          _pickedDay = (await showDatePicker(
                          locale : const Locale("da","DA"),
                          selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true,
                          context: context,
                          confirmText: "Vælg dag",
                          cancelText: "Annuller",
                          initialDate: widget.date,
                          firstDate: initialDate(),
                          lastDate: DateTime.now().add(const Duration(days: 90))))!;
                          setState(() {
                            widget.date;
                          });
                        }, child: Text('${DateFormat('dd-MM-yyyy').format(widget.date)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),),
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
                    Row(
                      children: [
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                            children: [
                              Container(padding: EdgeInsets.only(bottom: 5, left: 40), child: Text("Fra")),
                              Container(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/10, right: MediaQuery.of(context).size.width/20),
                                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/10, right: MediaQuery.of(context).size.width/20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white
                                ),
                                child: TextButton(onPressed: () async {
                                  startTime = (await showTimePicker(initialTime: startTime, context: context))!;
                                  setState(() {
                                  startTime.format(context);
                                });
                                  },
                                child: Text(startTime.format(context)),),
                              ),
                            ],
                          ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(padding: EdgeInsets.only(bottom: 5), child: Text("Til")),
                            Container(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/10, right: MediaQuery.of(context).size.width/20),
                              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width/20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white
                              ),
                              child: TextButton(onPressed: () async {
                                endTime = (await showTimePicker(initialTime: endTime, context: context))!;
                                setState(() {
                                endTime.format(context);
                                });
                                },
                                child: Text(endTime.format(context)),),
                            ),
                          ],
                        ),
                      ),

                    ],),
                    /*Container(
                        padding: EdgeInsets.only(left: 100, right: 100),
                        child: ElevatedButton.icon(onPressed: (){

                        }, icon: Icon(Icons.add), label: Text("Tilføj Tidsrum"))),*/
                ],)) else Container(),

                Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: null, icon: Icon(Icons.add_comment_outlined), label: Text("Kommentar"))),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: MediaQuery.of(context).viewInsets.bottom),
                  //height: MediaQuery.of(context).size.height / 5,
                  child: Form(
                    key: _commentKey,
                    child: TextFormField(
                      controller: commentController,
                      validator: validateComment,
                      decoration: InputDecoration(
                          //contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 10, horizontal: 10),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 0.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue, width: 1)),
                      ),
                    ),
                  ),),

                  //Spacer(),
                        Container(
                            padding: EdgeInsets.all(15),
                            height: 100,
                            margin: EdgeInsets.only(left: 50, right: 50, top: 10),
                            child: ElevatedButton.icon(
                                style: ButtonStyle(shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: const BorderSide(color: Colors.blue)
                                    )
                                )),
                                onPressed: () async {
                                  final f = DateFormat('dd-MM-yyyy');
                                  var pickedDate = f.format(_pickedDay!);
                                  var pickedMonth = _pickedDay?.month;
                                  var pickedWeek = _pickedDay?.weekOfYear;
                                  var starting = startTime.format(context);
                                  var ending = endTime.format(context);
                                  var timeRange = '';
                                  var comment = commentController.text;
                                  if (commentController.text == "" || commentController.text.isEmpty){
                                    comment = "Ingen";
                                  }
                                  if (isSwitched == false){
                                     timeRange = '$starting - $ending';
                                  } else if (isSwitched == true){
                                    timeRange = 'Hele dagen';
                                  }
                                  saveShift.doc(pickedDate).get().then((DocumentSnapshot documentSnapshot) async {
                                    if (documentSnapshot.exists) {
                                      _showSnackBar(context, pickedDate + " er allerede oprettet", Colors.red);
                                    } else if (!documentSnapshot.exists && _commentKey.currentState!.validate()){
                                      try{
                                        await saveShift.doc(pickedDate).set({'date': pickedDate,'month': pickedMonth, 'week': pickedWeek, 'time': timeRange, 'comment': comment, 'isAccepted': false, 'color': '0xFFFF9800', 'status': 'Tilgængelig'});
                                        Navigator.pop(context);
                                        _showSnackBar(context, pickedDate + " Tilføjet", Colors.green);
                                      } catch (e) {
                                        _showSnackBar(context, "Fejl ved oprettelse", Colors.red);
                                      }
                                    }
                                  });
                                },
                                icon: Icon(Icons.add_circle),
                                label: Text("Tilføj Dag", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),))),
              ]
          ),
      );
  }
}

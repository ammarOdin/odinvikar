import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:odinvikar/main_screens/own_days_datepicker.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OwnDaysScreen extends StatefulWidget {
  const OwnDaysScreen({Key? key}) : super(key: key);

  @override
  OwnDays createState() => OwnDays();

}

class OwnDays extends State<OwnDaysScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  get shift => FirebaseFirestore.instance.collection(user!.uid).orderBy('month', descending: false);
  get saveShift => FirebaseFirestore.instance.collection(user!.uid);
  final databaseReference = FirebaseFirestore.instance;
  MeetingDataSource? events;

  late DateTime getDateTap = initialDate();

  @override
  void initState() {
    getFirestoreShift().then((results) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        setState(() {
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> sendAcceptedShiftNotification(String token, String date, String name) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('acceptShiftNotif');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date,
      'name': name,
    });
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

  Color calendarColor(String dateTime, int awaitConfirmation){
    if (DateTime.now().isAfter(DateFormat('dd-MM-yyyy').parse(dateTime).add(const Duration(days: 1)))){
      return Colors.grey;
    } else if (awaitConfirmation == 2){
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }


  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    final tapDate = DateFormat('dd-MM-yyyy').format(calendarTapDetails.date as DateTime);
    var userData = await databaseReference.collection(user!.uid).get();
    var userNameRef = await databaseReference.collection('user').doc(user!.uid).get();
    var adminRef = await databaseReference.collection('user').get();
    getDateTap = calendarTapDetails.date!;

    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
        for (var data in userData.docs){
        if (data.get(FieldPath(const ["date"])) == tapDate){
          showDialog(context: context, builder: (BuildContext context){
            return SimpleDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), title: Center(child: Text("Tilgængelig"),), children: [
              Center(child: Text("\n Kan arbejde: " + data.get(FieldPath(const ["time"])))),
              Container(padding: EdgeInsets.all(30), child: Center(child: Text("\n Egen kommentar: " + data.get(FieldPath(const ["comment"]))))),
              const Divider(thickness: 1),
              Container(child: Center(child: Text("\n Status: " + data.get(FieldPath(const ["status"]))))),
              data.get(FieldPath(const ["isAccepted"])) ? Container(child: Center(child: Text("\n Detaljer: " + data.get(FieldPath(const ["details"]))))) : Container(),
              const Divider(thickness: 1, height: 50,),

              Row(
                children: [
                  SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: (){
                    var confirmation = data.get(FieldPath(const ["awaitConfirmation"]));
                    if(confirmation == 0){
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text("Accepter Vagt"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          content: const Text("Du er ikke blevet tildelt en vagt endnu. Denne handling kan ikke udføres."),
                          actions: [
                            TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")) ,
                          ],
                        );});
                    } else if (confirmation == 1){
                      data.reference.update({"awaitConfirmation": 2, 'status': "Godkendt Vagt", 'color' : '0xFF4CAF50'});
                      Navigator.pop(context);
                      _showSnackBar(context, "Vagt Accepteret", Colors.green);
                      getFirestoreShift();
                      for (var admins in adminRef.docs){
                        if (admins.get(FieldPath(const ["isAdmin"])) == true){
                          sendAcceptedShiftNotification(admins.get(FieldPath(const ["token"])), data.get(FieldPath(const ["date"])), userNameRef.get(FieldPath(const ["name"])));
                        }
                      }
                    } else if (confirmation == 2){
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text("Accepter Vagt"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          content: const Text("Vagten er allerede accepteret."),
                          actions: [
                            TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")) ,
                          ],
                        );});
                    }
                  }, icon: Icon(Icons.add_circle, color: Colors.green,), label: Text("Accepter", style: TextStyle(color: Colors.green),)),),),
                  SimpleDialogOption(child: Align(alignment: Alignment.centerRight, child: TextButton.icon(label: const Text("Slet Dag", style: TextStyle(color: Colors.red),) , icon: const Icon(Icons.delete, color: Colors.red,), onPressed: (){
                    if (data.get(FieldPath(const ["isAccepted"])) == true){
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text("Slet Dag"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          content: const Text("Vagten er allerede tildelt. Kontakt din leder hvis du ikke kan arbejde."),
                          actions: [
                            TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")) ,
                          ],
                        );});
                    } else {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text("Slet Dag"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          content: const Text("Er du sikker på at slette dagen?"),
                          actions: [
                            TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,
                            TextButton(onPressed: () {data.reference.delete(); Navigator.pop(context); Navigator.pop(context); getFirestoreShift(); _showSnackBar(context, data.id + " Slettet", Colors.green); setState(() {});}
                                , child: const Text("Slet"))
                          ],
                        );});
                    }
                    },), ),),
                ],
              ),
            ],);
          });
        }
      }

    }
  }

  Future<void> getFirestoreShift() async {
    var snapShotsValue = await databaseReference.collection(user!.uid).get();

    List<Meeting> list = snapShotsValue.docs.map((e)=>
        Meeting(eventName: "Detaljer",
        from: DateFormat('dd-MM-yyyy').parse(e.data()['date']),
        to: DateFormat('dd-MM-yyyy').parse(e.data()['date']) ,
        background: calendarColor(e.data()['date'], e.data()['awaitConfirmation']),
        isAllDay: true)).toList();

    setState(() {
      events = MeetingDataSource(list);
    });
  }

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return getFirestoreShift();
        },
      backgroundColor: Colors.white,
      displacement: 70,
      edgeOffset: 0,
      child: Scaffold(
        body: SizedBox(
          child: ListView(
            //physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 50),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.5,
                width: MediaQuery.of(context).size.width,
                child: SfCalendar(
                  /*todayHighlightColor: Colors.lightBlueAccent,
                  backgroundColor: Colors.blueGrey,*/
                  onTap: calendarTapped,
                  view: CalendarView.month,
                  firstDayOfWeek: 1,
                  showCurrentTimeIndicator: true, timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 7,
                    endHour: 19,
                    nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
                  monthViewSettings: const MonthViewSettings(
                    showAgenda: true,
                    agendaViewHeight: 100,
                    agendaItemHeight: 30,),
                  //monthCellBuilder: monthCellBuilder,
                  dataSource: events,
                  cellBorderColor: Colors.transparent,
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    shape: BoxShape.rectangle,),
                ),
              ),

              const Divider(thickness: 1, height: 4),

              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 10),
                child: ElevatedButton.icon(onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDatepicker(date: getDateTap))).then((value) {
                    setState(() {
                    getFirestoreShift();
                  });});
                  }, icon: const Icon(Icons.add_circle), label: const Align(alignment: Alignment.centerLeft, child: Text("Tilføj Dag")), style: ButtonStyle(shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: const BorderSide(color: Colors.blue)
                    ))),),),
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 10),
                child: ElevatedButton.icon(onPressed: showJobInfo, icon: const Icon(Icons.edit), label: const Align(alignment: Alignment.centerLeft, child: Text("Rediger Dage")),
                  style: ButtonStyle(shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: const BorderSide(color: Colors.blue)
                    )
                )), ),),
            ],
          ),
        ),
      ),
    );
  }

  Future showJobInfo () => showSlidingBottomSheet(
    context,
    builder: (context) => SlidingSheetDialog(
      duration: const Duration(milliseconds: 450),
      snapSpec: const SnapSpec(
          snappings: [0.4, 0.7, 1], initialSnap: 0.4
      ),
      builder: showJob,
      /////headerBuilder: buildHeader,
      avoidStatusBar: true,
      cornerRadius: 15,
    ),
  );

  Widget showJob(context, state) => Material(
  child: ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Container(padding: const EdgeInsets.only(bottom: 20, top: 10), child: const Center(child: Text("Dine Dage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),)),
        StreamBuilder(
            stream: shift.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const CircularProgressIndicator.adaptive());
              } else if (snapshot.data!.docs.isEmpty){
                return Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                  child: const Center(child: Text(
                    "Ingen Dage",
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),),
                );
              }
                return Column(
                children: snapshot.data!.docs.map((document){
                  var docDate = DateFormat('dd-MM-yyyy').parse(document['date']).add(const Duration(days: 1));
                  if (DateTime.now().isAfter(docDate)){
                    return Container();
                  } else if (DateTime.now().isBefore(docDate)){
                    return Column(children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15, left: 3, right: 3, bottom: 15),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))),
                        child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent), onPressed: () {
                          if (document.get(FieldPath(const ["isAccepted"])) == true){
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                title: const Text("Slet Dag"),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                content: const Text("Der er en vagt tildelt til dig på denne dato. Kontakt din chef hvis du ikke kan arbejde."),
                                actions: [
                                  TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")) ,
                                ],
                              );});
                          } else {
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                title: const Text("Slet Dag"),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                content: const Text("Er du sikker på at slette dagen?"),
                                actions: [
                                  TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,
                                  TextButton(onPressed: () {document.reference.delete(); Navigator.pop(context); Navigator.pop(context); getFirestoreShift(); _showSnackBar(context, document.id + " Slettet", Colors.green); setState(() {});}
                                      , child: const Text("Slet"))
                                ],
                              );});
                          }
                          }, child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                              children: [
                                Align(alignment: Alignment.centerLeft, child: Text("Dag: " + document['date'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
                                const Spacer(),
                                const Align(alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.red,))
                              ]),
                        )) ,),
                    ],);
                  } else {
                    return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const CircularProgressIndicator.adaptive());
                  }
                }).toList(),);
            }),
      ],
    ),
  );
}

// Calendar content class (syncfusion)
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  String? eventName;
  DateTime? from;
  DateTime? to;
  Color? background;
  bool? isAllDay;

  Meeting({this.eventName, this.from, this.to, this.background, this.isAllDay});
}

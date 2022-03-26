import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminCalendar extends StatefulWidget {
  const AdminCalendar({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminCalendar> {

  User? user = FirebaseAuth.instance.currentUser;
  get sub => FirebaseFirestore.instance.collection('user');
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');

  final databaseReference = FirebaseFirestore.instance;
  MeetingDataSource? events;

  final detailsController = TextEditingController();
  final GlobalKey<FormState> _detailsKey = GlobalKey<FormState>();


  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  String? validateDetails(String? input){
    if (input!.contains(new RegExp(r'^[#$^*():{}|<>]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    } else {
      return null;
    }
  }

  @override
  void initState() {
    getFirestoreShift().then((results) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<void> sendAssignedShiftNotification(String token, String date) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('addShiftNotif');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date
    });
  }

  Future<void> sendEditedShiftNotification(String token, String date) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('editShiftNotif');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date
    });
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    var userRef = await databaseReference.collection('user').get();
    final Meeting appointmentDetails = calendarTapDetails.appointments![0];
    final tapDate = DateFormat('dd-MM-yyyy').format(calendarTapDetails.date as DateTime);

    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      for (var users in userRef.docs){
        var userData = await databaseReference.collection(users.id).get();
        var userRef = await databaseReference.collection(users.id);
        for (var data in userData.docs){
          if (appointmentDetails.eventName == users.get(FieldPath(const ["name"])) && data.get(FieldPath(const ["date"])) == tapDate){
            showDialog(context: context, builder: (BuildContext context){
              return SimpleDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), title: Center(child: Text(data.get(FieldPath(const ["date"])) + " - "+users.get(FieldPath(const ["name"]))),), children: [
                Center(child: Text("\n Kan arbejde: " + data.get(FieldPath(const ["time"])))),
                Container(padding: EdgeInsets.only(bottom: 15), child: Center(child: Text("\n Kommentar: " + data.get(FieldPath(const ["comment"]))))),
                Container(child: Center(child: Text("\n Status: " + data.get(FieldPath(const ["status"]))))),
                data.get(FieldPath(const ["isAccepted"])) ? Container(child: Center(child: Text("\n Detaljer: " + data.get(FieldPath(const ["details"]))))) : Container(),
                const Divider(thickness: 1, height: 50,),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  alignment: Alignment.center,
                  child: Text("Skift Status", style: TextStyle(fontWeight: FontWeight.bold),),),
                Form(
                  key: _detailsKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SimpleDialogOption(
                        child: Align(alignment: Alignment.centerLeft,
                          child: TextButton.icon(label: data.get(FieldPath(const ["isAccepted"])) == true ? const Text("Rediger Vagt", style: TextStyle(color: Colors.orange),):const Text("Tildel Vagt", style: TextStyle(color: Colors.green),),
                        icon: data.get(FieldPath(const ["isAccepted"])) == true ? const Icon(Icons.edit, color: Colors.orange,):const Icon(Icons.add_circle, color: Colors.green,) , onPressed: (){
                        if (data.get(FieldPath(const ["isAccepted"])) == true){
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(title: Text("Rediger Vagt"),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              content: Text("TIlføj nye detaljer nedenunder:"),
                              actions: [
                                TextFormField(validator: validateDetails, controller: detailsController, decoration: const InputDecoration(icon: Icon(Icons.info), hintText: "Detaljer",),),
                                TextButton(onPressed: () async {
                                  if (_detailsKey.currentState!.validate()){
                                    try{
                                      await userRef.doc(data.id).update({'details': detailsController.text});
                                      sendEditedShiftNotification(users.get(FieldPath(const ["token"])), data.get(FieldPath(const ['date'])));
                                      Navigator.pop(context);Navigator.pop(context);
                                      _showSnackBar(context,"Vagt Redigeret", Colors.green);
                                    } catch (e) {
                                      _showSnackBar(context, "Fejl", Colors.red);
                                    }
                                  }
                                }
                                    , child: const Text("Godkend"))],);});
                        } else {
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(title: Text("Tildel Vagt"),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              content: Text("Suppler med detaljer nedenunder (Tidsrum mm.):"),
                              actions: [
                                TextFormField(validator: validateDetails, controller: detailsController, decoration: const InputDecoration(icon: Icon(Icons.info), hintText: "Detaljer",),),
                                TextButton(onPressed: () async {
                                  if (_detailsKey.currentState!.validate()){
                                    try{
                                      await userRef.doc(data.id).update({'status': 'Tildelt Vagt', 'isAccepted': true, 'color': '0xFF4CAF50', 'details': detailsController.text});
                                      Navigator.pop(context);Navigator.pop(context);
                                      sendAssignedShiftNotification(users.get(FieldPath(const ["token"])), data.get(FieldPath(const ['date'])));
                                      _showSnackBar(context,"Vagt Tildelt", Colors.green);
                                    } catch (e) {
                                      _showSnackBar(context, "Fejl", Colors.red);
                                    }
                                  }
                                }
                                    , child: const Text("Godkend"))],);});
                        }
                      },), ),),
                      SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("Fjern", style: TextStyle(color: Colors.red),) , icon: const Icon(Icons.delete, color: Colors.red,), onPressed: (){
                        showDialog(context: context, builder: (BuildContext context){
                          return AlertDialog(title: Text("Slet Dag"),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            content: Text("Du er ved at slette dagen. Handlingen kan ikke fortrydes."),
                            actions: [TextButton(onPressed: () {data.reference.delete(); getFirestoreShift(); Navigator.pop(context); Navigator.pop(context);}
                                , child: const Text("SLET", style: TextStyle(color: Colors.red),))],); });
                      },), ),),

                    ],
                  ),
                ),
               /* SimpleDialogOption(child: TextButton(onPressed: () {
                  sendAssignedShiftNotification(users.get(FieldPath(const ["token"])));
                },
                  child: Text("Test notifikation"),),),*/
                const Divider(thickness: 1),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  alignment: Alignment.center,
                child: Text("Kontakt", style: TextStyle(fontWeight: FontWeight.bold),),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("Opkald") , icon: const Icon(Icons.phone), onPressed: (){launch("tel:" + users.get(FieldPath(const ["phone"])));},), ),),
                    SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("SMS") , icon: const Icon(Icons.message), onPressed: (){launch("sms:" + users.get(FieldPath(const ["phone"])));},), ),),
                  ],
                ),
              ],);
            });
          }
        }
      }
    }
  }

  Future<void> getFirestoreShift() async {
    var userRef = await databaseReference.collection('user').get();
    List<String> shiftList = [];

    for (var users in userRef.docs){
      CollectionReference shiftRef = FirebaseFirestore.instance.collection(users.id);
      QuerySnapshot shiftSnapshot = await shiftRef.get();
      for (var shifts in shiftSnapshot.docs){
        shiftList.add(shifts.id+users.get(FieldPath(const ['phone']))+users.get(FieldPath(const ['name'])));
      }
    }

    List<Meeting> list = shiftList.map((e)=> Meeting(eventName: e.substring(18),
        from: DateFormat('dd-MM-yyyy').parse(e.substring(0,10)),
        to: DateFormat('dd-MM-yyyy').parse(e.substring(0,10)),
        background: DateTime.now().isAfter(DateFormat('dd-MM-yyyy').parse(e.substring(0,10)).add(const Duration(days: 1))) ? Colors.grey : Colors.indigoAccent,
        isAllDay: true)).toList();

    setState(() {
      events = MeetingDataSource(list);
    });
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      onRefresh: () {return getFirestoreShift();},
      backgroundColor: Colors.white,
      displacement: 70,
      edgeOffset: 0,
      child: Scaffold(
        body: SizedBox(
          child: ListView(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 15),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.35,
                width: MediaQuery.of(context).size.width,
                child: SfCalendar(
                  onTap: calendarTapped,
                  view: CalendarView.month,
                  firstDayOfWeek: 1,
                  showCurrentTimeIndicator: true, timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 7,
                    endHour: 19,
                    nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
                  monthViewSettings: const MonthViewSettings(
                    showAgenda: true,
                    agendaViewHeight: 150,
                    agendaItemHeight: 35,
                    agendaStyle: AgendaStyle(),
                  ),
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
              ],
          ),
        ),
      ),
    );
  }


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

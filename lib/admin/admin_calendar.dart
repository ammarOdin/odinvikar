import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
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

  Future<void> getFirestoreShift() async {
    var userRef = await databaseReference.collection('user').get();
    List<String> shiftList = [];

    for (var users in userRef.docs){
      CollectionReference shiftRef = FirebaseFirestore.instance.collection(users.id);
      QuerySnapshot shiftSnapshot = await shiftRef.get();
      for (var shifts in shiftSnapshot.docs){
        shiftList.add(shifts.id+users.get(FieldPath(const ['name'])));
      }
    }

    List<Meeting> list = shiftList.map((e)=> Meeting(eventName: e.substring(10),
        from: DateFormat('dd-MM-yyyy').parse(e.substring(0,10)),
        to: DateFormat('dd-MM-yyyy').parse(e.substring(0,10)),
        background: Colors.blue,
        isAllDay: true)).toList();

    setState(() {
      events = MeetingDataSource(list);
    });
  }

  Future<List> getInfo() async {
    List<String> phoneNr = [];
    QuerySnapshot usersSnapshot = await usersRef.get();
    for (var users in usersSnapshot.docs){
      if(users.get(FieldPath(const ['isAdmin']))==false){
        phoneNr.add(users.get(FieldPath(const['phone']))+users.get(FieldPath(const['name'])));
      }
    }
    return phoneNr;
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      onRefresh: () {return Future.delayed(const Duration(seconds: 1));},
      backgroundColor: Colors.white,
      displacement: 70,
      edgeOffset: 0,
      child: Scaffold(
        body: SizedBox(
          child: ListView(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 15),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.45,
                width: MediaQuery.of(context).size.width,
                child: SfCalendar(
                  view: CalendarView.month,
                  showCurrentTimeIndicator: true, timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 7,
                    endHour: 19,
                    nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
                  monthViewSettings: const MonthViewSettings(showAgenda: true, agendaViewHeight: 120,),
                  dataSource: events,

                ),
              ),

              const Divider(thickness: 1, height: 4),

              Container(
                height: 50,
                width: 150,
                margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5, top: 10),
                child: ElevatedButton.icon(onPressed: showJobInfo, icon: const Icon(Icons.contact_phone), label: const Align(alignment: Alignment.centerLeft, child: Text("Telefonliste")), style: ElevatedButton.styleFrom(primary: Colors.blue),),),
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
        FutureBuilder(future: getInfo(), builder: (context, AsyncSnapshot<List> snapshot){
          if (!snapshot.hasData){
            return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(50),
              child: const Center(child: Text(
                "Ingen Vikarer",
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),),
            );
          }
          return Column(
            children: snapshot.data!.map<Widget>((document){
              return Column(children: [
                Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, left: 10), child: Align(alignment: Alignment.centerLeft, child: Text(document.substring(8), style: const TextStyle(fontWeight: FontWeight.bold),),),),
                Container(margin: const EdgeInsets.only(top: 15, left: 3, right: 3, bottom: 15), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.white10), onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Opkald"), content: const Text("Du er ved at foretage et opkald"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () {launch("tel://" + document.substring(0,8));}, child: const Text("Opkald"))],);});}, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Opkald", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.call, color: Colors.green,))]),)) ,),
              ],);
            }).toList(),
          );
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
        background: Colors.green,
        isAllDay: true)).toList();

    setState(() {
      events = MeetingDataSource(list);
    });
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
                  showCurrentTimeIndicator: true, firstDayOfWeek: 1, timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 7,
                    endHour: 19,
                    nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
                  monthViewSettings: const MonthViewSettings(showAgenda: true, agendaViewHeight: 120,),
                  dataSource: events,

                ),
              ),

              //const Divider(thickness: 1, height: 4),
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

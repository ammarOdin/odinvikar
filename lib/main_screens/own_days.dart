import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:odinvikar/main_screens/own_days_datepicker.dart';
import 'package:odinvikar/main_screens/own_days_details.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
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
    } else if (awaitConfirmation == 1) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  String calendarDetails(int awaitConfirmation, String status){
    if (awaitConfirmation == 0){
      return 'Tilgængelig - se mere';
    } else if (awaitConfirmation == 1) {
      return 'Afventer Accept - se mere';
    } else if (awaitConfirmation == 2 && status == "Godkendt vagt") {
      return 'Godkendt - se mere';
    } else if (awaitConfirmation == 2 && status == "Tilkaldt") {
      return 'Tilkaldt - se mere';
    } else {
      return 'Detaljer - se mere';
    }
  }


  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    final tapDate = DateFormat('dd-MM-yyyy').format(calendarTapDetails.date as DateTime);
    var userData = await databaseReference.collection(user!.uid).get();
    getDateTap = calendarTapDetails.date!;

    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
        for (var data in userData.docs){
        if (data.get(FieldPath(const ["date"])) == tapDate && data.get(FieldPath(const['awaitConfirmation'])) != 0){
          Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
            date: data.id,
            status: data.get(FieldPath(const ['status'])),
            time: data.get(FieldPath(const ['time'])),
            comment: data.get(FieldPath(const ['comment'])),
            awaitConfirmation: data.get(FieldPath(const ['awaitConfirmation'])),
            details: data.get(FieldPath(const ['details'])),
            color: data.get(FieldPath(const ['color'])),
            data: data,

          ))).then((value) {
            setState(() {
              getFirestoreShift();
            });
          });

        } else if (data.get(FieldPath(const ["date"])) == tapDate && data.get(FieldPath(const['awaitConfirmation'])) == 0){
          Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
            date: data.id,
            status: data.get(FieldPath(const ['status'])),
            time: data.get(FieldPath(const ['time'])),
            comment: data.get(FieldPath(const ['comment'])),
            awaitConfirmation: data.get(FieldPath(const ['awaitConfirmation'])),
            color: data.get(FieldPath(const ['color'])),
            data: data,

          ))).then((value) {
            setState(() {
              getFirestoreShift();
            });
          });
        }
      }
    }
  }

  Future<void> getFirestoreShift() async {
    var snapShotsValue = await databaseReference.collection(user!.uid).get();

    List<Meeting> list = snapShotsValue.docs.map((e)=>
        Meeting(eventName: calendarDetails(e.data()['awaitConfirmation'], e.data()['status']),
        from: DateFormat('dd-MM-yyyy').parse(e.data()['date']),
        to: DateFormat('dd-MM-yyyy').parse(e.data()['date']) ,
        background: calendarColor(e.data()['date'], e.data()['awaitConfirmation']),
        isAllDay: true)).toList();

    setState(() {
      events = MeetingDataSource(list);
    });
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
                    agendaItemHeight: 40,),
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
                  if (getDateTap.weekday == 6  || getDateTap.weekday == 7){
                    showTopSnackBar(context, CustomSnackBar.error(message: "Du kan ikke tilføje på en weekend",),);
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDatepicker(date: getDateTap))).then((value) {
                      setState(() {
                        getFirestoreShift();
                      });});
                  }
                  }, icon: const Icon(Icons.add_circle_outline, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Tilføj dag")), style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                  primary: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ),),
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

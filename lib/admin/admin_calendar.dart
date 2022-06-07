import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/admin/admin_shift_details.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../card_assets.dart';


class AdminCalendar extends StatefulWidget {
  const AdminCalendar({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminCalendar> {
  get sub => FirebaseFirestore.instance.collection('user');

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
  final detailsController = TextEditingController();
  final databaseReference = FirebaseFirestore.instance;
  MeetingDataSource? events;

  //late DateTime? selectedDate = initialDate();
  //late DateTime selectedDate = initialDate();
  var selectedDate;
  String userToken = "";
  User? user = FirebaseAuth.instance.currentUser;
  bool loading = true;

 /* var _month = DateTime.now().month;
  var _year;
  Map months =
  {'January':1, 'February':2, 'March':3, 'April':4, 'May':5,'June':6,'July':7,'August':8,'September':9,'October':10,'November':11,'December':12};*/

  String? validateDetails(String? input){
    if (input!.contains(new RegExp(r'^[#$^*():{}|<>]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    } else {
      return null;
    }
  }

  @override
  void initState() {
    setState(() {
      selectedDate = DateTime.now();
    });
    /*_month = DateTime.now().month;
    getFirestoreShift().then((results) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });*/
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

  updateActiveDate(DateTime? date){
    selectedDate = date!;
    getDateShifts();
    /*setState((){

    })*/;
  }

  /*void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      setState(() {
        final selected = viewChangedDetails.visibleDates[viewChangedDetails.visibleDates.length ~/ 2];
        _month = selected.month;
        *//*_year = DateFormat('yyyy').format(viewChangedDetails
            .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]).toString();*//*
      });
    });
    getFirestoreShift();
  }*/

  // awaitConfirmation = 0 -> User added a shift
  // awaitConfirmation = 1 -> Admin assigned shift, not accepted by user
  // awaitConfirmation = 2 -> User accepted assigned shift by admin

  /*void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    var userRef = await databaseReference.collection('user').get();
    final Meeting appointmentDetails = calendarTapDetails.appointments![0];
    final tapDate = DateFormat('dd-MM-yyyy').format(calendarTapDetails.date as DateTime);

    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      showDialog(barrierDismissible: false, context: context, builder: (BuildContext context){
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: SpinKitFoldingCube(
            color: Colors.blue,
          ),
        );
      });
      for (var users in userRef.docs){
        var userData = await databaseReference.collection(users.id).get();
        var userRef = await databaseReference.collection(users.id);

        for (var data in userData.docs){
          if (appointmentDetails.eventName == users.get(FieldPath(const ["name"])) && data.get(FieldPath(const ["date"])) == tapDate){
            Navigator.pop(context);
            if (data.get(FieldPath(const ["date"])) == tapDate && data.get(FieldPath(const['awaitConfirmation'])) != 0){
              var dataRef = await databaseReference.collection(users.id).doc(data.id);
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
                date: data.id,
                status: data.get(FieldPath(const ['status'])),
                name: users.get(FieldPath(const ['name'])),
                token: users.get(FieldPath(const ['token'])),
                time: data.get(FieldPath(const ['time'])),
                comment: data.get(FieldPath(const ['comment'])),
                awaitConfirmation: data.get(FieldPath(const ['awaitConfirmation'])),
                details: data.get(FieldPath(const ['details'])),
                color: data.get(FieldPath(const ['color'])),
                data: dataRef,
                userRef: userRef,
              ))).then((value) {
                setState(() {
                  getFirestoreShift();
                  _month = data.get(FieldPath(const ['month']));
                });
              });
            } else if (data.get(FieldPath(const ["date"])) == tapDate && data.get(FieldPath(const['awaitConfirmation'])) == 0){
              var dataRef = await databaseReference.collection(users.id).doc(data.id);
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
                date: data.id,
                status: data.get(FieldPath(const ['status'])),
                name: users.get(FieldPath(const ['name'])),
                token: users.get(FieldPath(const ['token'])),
                time: data.get(FieldPath(const ['time'])),
                comment: data.get(FieldPath(const ['comment'])),
                awaitConfirmation: data.get(FieldPath(const ['awaitConfirmation'])),
                color: data.get(FieldPath(const ['color'])),
                data: dataRef,
                userRef: userRef,
              ))).then((value) {
                setState(() {
                  getFirestoreShift();
                  _month = data.get(FieldPath(const ['month']));
                });
              });
            }
          }
        }
      }
    }
  }*/

/*  Future<void> getFirestoreShift() async {
    loading = true;
    var userRef = await databaseReference.collection('user').get();
    List<String> entireShift = [];
    List<Meeting> separatedShiftList = [];

    for (var users in userRef.docs){
      var shiftRef = await databaseReference.collection(users.id).where("month", isEqualTo: _month).get();
      for (var shifts in shiftRef.docs){
        entireShift.add(shifts.data()['date'] + ";"
            + shifts.data()['status'] + ";"
            + users.get(FieldPath(const ['phone'])) + ";"
            + users.get(FieldPath(const ['name'])) + ";"
            + shifts.data()['awaitConfirmation'].toString());
      }
    }

    for (var shifts in entireShift){
      List shiftSplit = shifts.split(";");
      separatedShiftList.add(Meeting(eventName: shiftSplit[3],
          from: DateFormat('dd-MM-yyyy').parse(shiftSplit[0]),
          to: DateFormat('dd-MM-yyyy').parse(shiftSplit[0]),
          background: calendarColor(shiftSplit[0], int.parse(shiftSplit[4])),
          isAllDay: true));
    }
    setState(() {
      events = MeetingDataSource(separatedShiftList);
      loading = false;
    });
  }*/

  Future<List> getDateShifts() async {
    loading = true;
    var userRef = await databaseReference.collection('user').get();
    List<String> entireShift = [];
    List<AdminAvailableShiftCard> separatedShiftList = [];

    for (var users in userRef.docs){
      var shiftRef = await databaseReference.collection(users.id).get();
      for (var shifts in shiftRef.docs){
        if (shifts.data()['awaitConfirmation'].toString() != "0"){
          entireShift.add(shifts.data()['date'] + ";"
              + shifts.data()['status'] + ";"
              + shifts.data()['color'] + ";"
              + shifts.data()['time'] + ";"
              + shifts.data()['comment'] + ";"
              + users.get(FieldPath(const ['phone'])) + ";"
              + users.get(FieldPath(const ['name'])) + ";"
              + users.get(FieldPath(const ['token'])) + ";"
              + users.id + ";"
              + shifts.data()['awaitConfirmation'].toString() + ";"
              + shifts.data()['details'] + ";"
          );
        } else if (shifts.data()['awaitConfirmation'].toString() == "0") {
          entireShift.add(shifts.data()['date'] + ";"
              + shifts.data()['status'] + ";"
              + shifts.data()['color'] + ";"
              + shifts.data()['time'] + ";"
              + shifts.data()['comment'] + ";"
              + users.get(FieldPath(const ['phone'])) + ";"
              + users.get(FieldPath(const ['name'])) + ";"
              + users.get(FieldPath(const ['token'])) + ";"
              + users.id + ";"
              + shifts.data()['awaitConfirmation'].toString() + ";"
          );
        }
      }
    }

    for (var shifts in entireShift){
      List shiftSplit = shifts.split(";");
      if (shiftSplit[0] == DateFormat('dd-MM-yyyy').format(selectedDate)) {
        separatedShiftList.add(
            AdminAvailableShiftCard(text: shiftSplit[6],
                time: "Tilgængelig: " + shiftSplit[3],
                subtitle: "Se mere",
                icon: Icon(
                  Icons.circle, color: Color(int.parse(shiftSplit[2])),),
                onPressed: () async {
                  var userRef = await databaseReference.collection(
                      shiftSplit[8]);
                  var dataRef = await databaseReference.collection(
                      shiftSplit[8]).doc(shiftSplit[0]);
                  if (int.parse(shiftSplit[9]) != 0) {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>
                        AdminShiftDetailsScreen(
                          date: shiftSplit[0],
                          status: shiftSplit[1],
                          name: shiftSplit[6],
                          token: shiftSplit[7],
                          time: shiftSplit[3],
                          comment: shiftSplit[4],
                          awaitConfirmation: int.parse(shiftSplit[9]),
                          details: shiftSplit[10],
                          color: shiftSplit[2],
                          data: dataRef,
                          userRef: userRef,
                        )));
                  } else if (int.parse(shiftSplit[9]) == 0) {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>
                        AdminShiftDetailsScreen(
                          date: shiftSplit[0],
                          status: shiftSplit[1],
                          name: shiftSplit[6],
                          token: shiftSplit[7],
                          time: shiftSplit[3],
                          comment: shiftSplit[4],
                          awaitConfirmation: int.parse(shiftSplit[9]),
                          color: shiftSplit[2],
                          data: dataRef,
                          userRef: userRef,
                        )));
                  }
                })
        );
      }
    }
    loading = false;
    return separatedShiftList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.only(top: 40, bottom: 30),
            child: CalendarTimeline(
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(Duration(days: 90)),
              lastDate: DateTime.now().add(Duration(days: 90)),
              onDateSelected: (date) {
                updateActiveDate(date);
                print(selectedDate);
              },
              leftMargin: 20,
              monthColor: Colors.black,
              dayColor: Colors.black,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.blue,
              dotsColor: Colors.white,
              selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true,
              locale: 'da',
            ),
          ),
          /*Container(
              padding: EdgeInsets.only(top: 40),
              child: SfCalendar(
                onTap: calendarTapped,
                view: CalendarView.month,
                firstDayOfWeek: 1,
                onViewChanged: viewChanged,
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
          loading ? Stack(
            children: [
              Opacity(
                opacity: 0.5,
                  child: Container(color: Colors.transparent)),
              Center(
                    child: SpinKitFoldingCube(
                      color: Colors.blue,
                      size: 50,
                )),
            ],
          ) : Container(),*/

          FutureBuilder(
              future: getDateShifts(), builder: (context, AsyncSnapshot<List> snapshot){
            if (snapshot.connectionState == ConnectionState.waiting){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitFoldingCube(
                    color: Colors.blue,
                    size: 50,
                  )),
                  Container(
                    padding: EdgeInsets.only(top: 30, left: 5),
                    child: Text("Henter vagter..."),
                  )
                ],
              );
            } else if (snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Intet at vise",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),);
            } else if (!snapshot.hasData){
              return Center(
                child: Text(
                  "Intet at vise",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),);
            }
            return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index){
                  AdminAvailableShiftCard shiftCard = snapshot.data?[index];
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        shiftCard
                      ],
                    ),
                  );
                }
            );
          }),
        ],
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

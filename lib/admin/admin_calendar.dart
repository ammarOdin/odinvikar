import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/admin/admin_shift_details.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


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

  late DateTime selectedDate = initialDate();
  String userToken = "";
  User? user = FirebaseAuth.instance.currentUser;
  bool loading = true;

  var _month = DateTime.now();
  var _year;
  List months =
  ['January', 'February', 'March', 'April', 'May','June','July','August','September','October','November','December'];

  getMonthValue(){
    /*var dateString = _month;
    DateFormat format = new DateFormat("dd-MM-yyyy");
    var formattedDate = format.parse(dateString);*/
    return months[_month.month - 1];
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
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
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

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      setState(() {
        _month = DateFormat('MMMM').format(viewChangedDetails
            .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]).toString() as DateTime;
        _year = DateFormat('yyyy').format(viewChangedDetails
            .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]).toString();
      });
    });
  }

  // awaitConfirmation = 0 -> User added a shift
  // awaitConfirmation = 1 -> Admin assigned shift, not accepted by user
  // awaitConfirmation = 2 -> User accepted assigned shift by admin

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
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
                });
              });
            }
          }
        }
      }
    }
  }

  Future<void> getFirestoreShift() async {
    //var userRef = await databaseReference.collection('user').where("month", isEqualTo: ).get();
    var userRef = await databaseReference.collection('user').get();
    List<String> entireShift = [];
    List<Meeting> separatedShiftList = [];

    for (var users in userRef.docs){
      var shiftRef = await databaseReference.collection(users.id).get();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  child: Container(color: Colors.black)),
              Center(
                    child: SpinKitFoldingCube(
                      color: Colors.blue,
                      size: 50,
                )),
            ],
          ) : Container(),
          Padding(padding: EdgeInsets.all(10), child: Text(getMonthValue()),)
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

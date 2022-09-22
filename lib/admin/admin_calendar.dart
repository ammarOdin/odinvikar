import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/admin/admin_shift_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  var selectedDate;
  String userToken = "";
  User? user = FirebaseAuth.instance.currentUser;
  bool loading = true;

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
  }

  Future<List> getDateShifts() async {
    // TODO optimize load of shifts - taking too long
    Stopwatch stopwatch = new Stopwatch()..start();

    loading = true;
    var userRef = await databaseReference.collection('user').get();
    List<String> entireShift = [];
    List<AdminAvailableShiftCard> separatedShiftList = [];

    for (var users in userRef.docs){
      var shiftRef = await databaseReference.collection(users.id).
      where("date", isEqualTo: DateFormat('dd-MM-yyyy').format(selectedDate).toString()).get();

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
    print('getDateShift() - fetch and save all shifts - executed in ${stopwatch.elapsed}');

    for (var shifts in entireShift){
      List shiftSplit = shifts.split(";");
      if (shiftSplit[0] == DateFormat('dd-MM-yyyy').format(selectedDate)) {
        separatedShiftList.add(
            AdminAvailableShiftCard(text: shiftSplit[6],
                time: int.parse(shiftSplit[9]) == 0 ? "Tilgængelig: " + shiftSplit[3] : shiftSplit[10].substring(0,11),
                subtitle: "Se mere",
                icon: Icon(Icons.square_rounded, size: 22, color: Color(int.parse(shiftSplit[2])),),
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
                        ))).then((value) {
                      setState((){getDateShifts();});
                    });
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
                        ))).then((value) {
                          setState((){getDateShifts();});
                    });
                  }
                })
        );
      }
    }
    loading = false;
    print('getDateShift() - return users list - executed in ${stopwatch.elapsed}');
    return separatedShiftList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            child: TableCalendar(
              calendarStyle: CalendarStyle(
                defaultDecoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
                todayDecoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(10)),
                selectedDecoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                weekendDecoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
                weekendTextStyle: TextStyle(color: Colors.grey[500]),
              ),
              daysOfWeekHeight: 40,
              headerStyle: HeaderStyle(
                headerPadding: EdgeInsets.only(bottom: 20, top: 20),
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              calendarFormat: CalendarFormat.week,
              locale: 'da',
              firstDay: DateTime.utc(2022, 1, 1),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: selectedDate,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay){
                setState((){
                  selectedDate = selectedDay;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
            )
          ),

          FutureBuilder(
              future: getDateShifts(), builder: (context, AsyncSnapshot<List> snapshot){
            if (snapshot.connectionState == ConnectionState.waiting){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 100), child: SpinKitRing(
                    color: Colors.blue,
                    size: 50,
                  )),
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 5),
                    child: Text("Henter vikarer..."),
                  )
                ],
              );
            } else if (snapshot.data!.isEmpty) {
              return Center(
                child: Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    "Intet at vise",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),);
            } else if (!snapshot.hasData){
              return Center(
                child: Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    "Intet at vise",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),);
            }
            return Container(
              padding: EdgeInsets.only(top: 40),
              child: ListView.builder(
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
              ),
            );
          }),
        ],
      ),
    );
  }
}

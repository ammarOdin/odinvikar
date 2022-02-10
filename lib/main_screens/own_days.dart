import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:week_of_year/week_of_year.dart';

class OwnDaysScreen extends StatefulWidget {
  const OwnDaysScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();

}

class _State extends State<OwnDaysScreen> {

  late DateTime _pickedDay;
  //late List<DateTime> _specialDates;
  User? user = FirebaseAuth.instance.currentUser;
  get shift => FirebaseFirestore.instance.collection(user!.uid).orderBy('month', descending: false).orderBy('date', descending: false);
  get saveShift => FirebaseFirestore.instance.collection(user!.uid);
  final databaseReference = FirebaseFirestore.instance;
  MeetingDataSource? events;
  final DateRangePickerController drpController = DateRangePickerController();



  @override
  void initState() {
    getFirestoreShift().then((results) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        setState(() {
        });
      });
    });
    //_specialDates = <DateTime>[DateTime.now()];
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
    var snapShotsValue = await databaseReference.collection(user!.uid).get();

    List<Meeting> list = snapShotsValue.docs.map((e)=>
        Meeting(eventName: "Til Rådighed",
        from: DateFormat('dd-MM-yyyy').parse(e.data()['date']),
        to: DateFormat('dd-MM-yyyy').parse(e.data()['date']) ,
        background: DateTime.now().isAfter(DateFormat('dd-MM-yyyy').parse(e.data()['date']).add(const Duration(days: 1))) ? Colors.grey : Colors.green,
        isAllDay: true)).toList();

    setState(() {
      events = MeetingDataSource(list);
    });
  }

  /*void changedSelection(DateRangePickerSelectionChangedArgs args){
    if (kDebugMode) {
      print(args.value);
    }
  }*/

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
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 15),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.45,
                width: MediaQuery.of(context).size.width,
                child: /*SfDateRangePicker(
                  view: DateRangePickerView.month,
                  controller: drpController,
                  onSelectionChanged: changedSelection,
                  selectionShape: DateRangePickerSelectionShape.rectangle,
                  selectionMode: DateRangePickerSelectionMode.multiple,
                  monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 1, specialDates: _specialDates),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    specialDatesDecoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(color: const Color(0xFF2B732F), width: 1),
                        shape: BoxShape.circle),
                  ),
                ),*/
                SfCalendar(
                  view: CalendarView.month,
                  firstDayOfWeek: 1,
                  showCurrentTimeIndicator: true, timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 7,
                    endHour: 19,
                    nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
                  monthViewSettings: const MonthViewSettings(
                    showAgenda: true,
                    agendaViewHeight: 100,
                    agendaItemHeight: 30,
                  monthCellStyle: MonthCellStyle(),
                  agendaStyle: AgendaStyle(),),
                  dataSource: events,
                ),
              ),

              const Divider(thickness: 1, height: 4),

              Container(
                height: 45,
                margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 10),
                child: ElevatedButton.icon(onPressed: () async {
                  _pickedDay = (await showDatePicker(
                      locale : const Locale("da","DA"),
                      selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true,
                      context: context,
                      confirmText: "Vælg dag",
                      cancelText: "Annuller",
                      initialDate: initialDate(),
                      firstDate: initialDate(),
                      lastDate: DateTime.now().add(const Duration(days: 60))))!;

                      final f = DateFormat('dd-MM-yyyy');
                      var pickedDate = f.format(_pickedDay);
                      var pickedMonth = _pickedDay.month;
                      var pickedWeek = _pickedDay.weekOfYear;

                  saveShift.doc(pickedDate).get().then((DocumentSnapshot documentSnapshot) async {
                    if (documentSnapshot.exists) {
                      _showSnackBar(context, "Vagten findes allerede!", Colors.red);
                    } else if (!documentSnapshot.exists){
                      await saveShift.doc(pickedDate).set({'date': pickedDate,'month': pickedMonth, 'week': pickedWeek});
                      getFirestoreShift();
                      _showSnackBar(context, "Vagt Tilføjet", Colors.green);
                    }
                  });
                  }, icon: const Icon(Icons.add_circle), label: const Align(alignment: Alignment.centerLeft, child: Text("Tilføj Dag")), style: ButtonStyle(shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.blue)
                    )
                )),),
              ),
              Container(
                height: 45,
                margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5, top: 10),
                child: ElevatedButton.icon(onPressed: showJobInfo, icon: const Icon(Icons.edit), label: const Align(alignment: Alignment.centerLeft, child: Text("Rediger Vagter")),
                  style: ButtonStyle(shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
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

  //Widget buildHeader(BuildContext context, SheetState state) => Material(child: Stack(children: <Widget>[Container(height: MediaQuery.of(context).size.height / 3 , color: Colors.blue,),Positioned(bottom: 20, child: SizedBox(width: MediaQuery.of(context).size.width, height: 40, child: Image.network("https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", height: 59, fit: BoxFit.contain)))],),);

  Widget showJob(context, state) => Material(
  child: ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Container(padding: const EdgeInsets.only(bottom: 20, top: 10), child: const Center(child: Text("Dine Vagter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),)),
        StreamBuilder(
            stream: shift.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator());
              } else if (snapshot.data!.docs.isEmpty){
                return Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                  child: const Center(child: Text(
                    "Ingen Vagter",
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
                      Container(margin: const EdgeInsets.only(top: 15, left: 3, right: 3, bottom: 15), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent), onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Slet Vagt"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: const Text("Er du sikker på at slette vagten?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () {saveShift.doc(document.id).delete(); Navigator.pop(context); Navigator.pop(context); getFirestoreShift(); _showSnackBar(context, "Vagt Slettet", Colors.green); setState(() {});}, child: const Text("Slet"))],);});}, child: Align(alignment: Alignment.centerLeft, child: Row(children: [Align(alignment: Alignment.centerLeft, child: Text("Vagt: " + document['date'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), const Spacer(), const Align(alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.red,))]),)) ,),
                    ],);
                  } else {
                    return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator());
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

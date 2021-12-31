import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'home_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/week_of_year.dart';

class OwnDaysScreen extends StatefulWidget {
  const OwnDaysScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<OwnDaysScreen> {

  late DateTime _pickedDay;

  get shift => FirebaseFirestore.instance.collection('shift').orderBy('date', descending: false);
  get saveShift => FirebaseFirestore.instance.collection('shift');

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.5,
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
            ),
          ),

          const Divider(thickness: 1, height: 4),

          Container(
            height: 45,
            width: 150,
            margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 20),
            child: ElevatedButton.icon(onPressed: () async {
              _pickedDay = (await showDatePicker(
                  locale : const Locale("da","DA"),
                  selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true,
                  context: context,
                  confirmText: "Vælg dag",
                  cancelText: "Annuller",
                  initialDate: initialDate(),
                  firstDate: initialDate(),
                  lastDate: DateTime.now().add(const Duration(days: 32))))!;

                  final f = DateFormat('dd/MM/yyyy');

                  //var pickedDate = DateFormat.yMMMd().format(_pickedDay);
                  var pickedDate = f.format(_pickedDay);
                  var pickedMonth = _pickedDay.month;
                  var pickedWeek = _pickedDay.weekOfYear;
                  await saveShift.add({'date': pickedDate,'month': pickedMonth, 'week': pickedWeek});

              }, icon: const Icon(Icons.add_circle), label: const Align(alignment: Alignment.centerLeft, child: Text("Tilføj Dag")),),
          ),
          Container(
            height: 45,
            width: 150,
            margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
            child: ElevatedButton.icon(onPressed: showJobInfo, icon: const Icon(Icons.edit), label: const Align(alignment: Alignment.centerLeft, child: Text("Rediger Vagter")), style: ElevatedButton.styleFrom(primary: Colors.blue),),),
          const Divider(thickness: 1, height: 4),
          Container(padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20), child: const Text("Alle Vagter", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
          // one card, make foreach from db within current user
          StreamBuilder(
              stream: shift.snapshots() ,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if (!snapshot.hasData){
                  return const Center(child: CircularProgressIndicator(),);
                } else if (snapshot.data!.docs.isEmpty){
                  return const Center(child: Text(
                    "Ingen Vagter",
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),);
                }
                return Column(
                  children: snapshot.data!.docs.map((document){
                    return CardFb2(text: "Vikar - " + document['date'], imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "", onPressed: (){});
                  }).toList(),
                );
              }),
        ],
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
        StreamBuilder(
            stream: shift.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return const Center(child: CircularProgressIndicator(),);
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
                  return Column(children: [
                    Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 30), child: const Center(child: Text("Vagt Detaljer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),),
                    Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, left: 10), child: Align(alignment: Alignment.centerLeft, child: Text("Mulige vagt: " + document['date'], style: const TextStyle(fontWeight: FontWeight.bold),),),),
                    Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, left: 10), child: const Align(alignment: Alignment.centerLeft, child: Text("Du vil blive ringet op på dagen, hvis du får vagten. Kontakt IKKE vagt-telefonen."),) ,),
                    Container(margin: const EdgeInsets.only(top: 15, left: 3, right: 3, bottom: 15), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.white10), onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Slet Vagt"), content: const Text("Er du sikker på at slette vagten?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () {saveShift.doc(document.id).delete(); Navigator.pop(context);}, child: const Text("Slet"))],);});}, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Slet", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.red,))]),)) ,),
                  ],);
                }).toList(),
              );
            }),
      ],
    ),
  );
}

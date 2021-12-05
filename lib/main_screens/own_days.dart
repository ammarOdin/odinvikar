import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/utils/calendar_utils.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_day.dart';
import 'home_screen.dart';


class OwnDaysScreen extends StatefulWidget {
  const OwnDaysScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<OwnDaysScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Event>> _selectedEvents;

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.5,
      child: ListView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 15),
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              /*selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.

                // Using `isSameDay` is recommended to disregard
                // the time-part of compared DateTime objects.
                return isSameDay(_focusedDay, day);
              },*/
             /* onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },*/
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  // Call `setState()` when updating calendar format
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // No need to call `setState()` here
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _getEventsForDay(day);
              },
            ),
          ),
          /*Expanded(child: ValueListenableBuilder<List<Event>>(valueListenable: _selectedEvents,
              builder: (context, value, _){
                return ListView.builder(itemCount: value.length, itemBuilder: (context, index){
                  return Container(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12.0),
                  ),child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Text('${value[index]}'),
                      ),);
                });
              },)),*/
          Container(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 12, right: MediaQuery.of(context).size.width / 12, top: MediaQuery.of(context).size.width / 25, bottom: MediaQuery.of(context).size.height / 40),
            child: ElevatedButton.icon(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDayScreen()));}, icon: const Icon(Icons.add_circle), label: const Text("Tilføj dage"), style: ElevatedButton.styleFrom(primary: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),),
          ),
          const Divider(thickness: 1, height: 4),
          Container(padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20), child: const Text("Alle Dage", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
          // only show entries for the selected date!
          CardFb2(text: "Vikar - 7/12/2021", imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "Se mere", onPressed: showJobInfo),
          CardFb2(text: "Vikar - 8/12/2021", imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "Se mere", onPressed: showJobInfo),
          CardFb2(text: "Vikar - 10/12/2021", imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "Se mere", onPressed: showJobInfo),
          CardFb2(text: "Vikar - 13/12/2021", imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "Se mere", onPressed: showJobInfo),
          CardFb2(text: "Vikar - 15/12/2021", imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "Se mere", onPressed: showJobInfo),
          CardFb2(text: "Vikar - 17/12/2021", imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "Se mere", onPressed: showJobInfo),
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

  Widget buildHeader(BuildContext context, SheetState state) => Material(child: Stack(children: <Widget>[Container(height: MediaQuery.of(context).size.height / 3 , color: Colors.blue,),Positioned(bottom: 20, child: SizedBox(width: MediaQuery.of(context).size.width, height: 40, child: Image.network("https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", height: 59, fit: BoxFit.contain)))],),);

  Widget showJob(context, state) => Material(
    child: ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Container(margin: const EdgeInsets.all(3), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent, ), onPressed: () {  }, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Rediger", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.edit, color: Colors.black,))]),)) ,),
        Container(margin: const EdgeInsets.only(top: 3, left: 3, right: 3, bottom: 10), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent, ), onPressed: () {  }, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Slet", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.red,))]),)) ,),
      ],
    ),
  );
}

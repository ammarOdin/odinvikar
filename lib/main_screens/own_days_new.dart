import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


class CalendarPickerIntegration extends StatefulWidget {
  const CalendarPickerIntegration({Key? key}) : super(key: key);

  @override
  CalendarPickerIntegrationState createState() =>
      CalendarPickerIntegrationState();
}

class CalendarPickerIntegrationState extends State<CalendarPickerIntegration> {
  final DateRangePickerController _dateRangePickerController =
  DateRangePickerController();
  late _AppointmentDataSource _appointmentDataSource;
  late List<DateTime> _specialDates;
  late List<Appointment> appointments;
  List<String> subjectName=[];

  User? user = FirebaseAuth.instance.currentUser;
  final databaseReference = FirebaseFirestore.instance;
  get shifts => FirebaseFirestore.instance.collection(user!.uid).get();


  String subjectName1 = '';
  String subjectName2 = '';
  String subjectName3 = '';

  @override
  void initState() {
    _appointmentDataSource = _getCalendarDataSource();
    _specialDates = <DateTime>[];
    for (int i = 0; i < _appointmentDataSource.appointments!.length; i++) {
      _specialDates.add(_appointmentDataSource.appointments![i].startTime);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.multiple,
                  selectionShape: DateRangePickerSelectionShape.rectangle,
                  selectionColor: Colors.blue,
                  todayHighlightColor: Colors.blue,
                  controller: _dateRangePickerController,
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    specialDates: _specialDates,
                  ),
                  onSelectionChanged: selectionChanged,
                  monthCellStyle: const DateRangePickerMonthCellStyle(
                    specialDatesDecoration: _MonthCellDecoration(
                        borderColor: null,
                        backgroundColor: Color(0xfff7f4ff),
                        showIndicator: true,
                        indicatorColor: Colors.green),
                    cellDecoration: _MonthCellDecoration(
                        borderColor: null,
                        backgroundColor: Color(0xfff7f4ff),
                        showIndicator: false,
                        indicatorColor: Colors.orange),
                    todayCellDecoration: _MonthCellDecoration(
                        borderColor: null,
                        backgroundColor: Color(0xfff7f4ff),
                        showIndicator: false,
                        indicatorColor: Colors.orange),
                  ),
                ),
                Expanded(
                    child: Container(
                        color: Colors.black12,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(2),
                          itemCount: 1,//subjectName.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                padding: const EdgeInsets.all(2),
                                // height: subjectName.length*20,
                                // color: _appointmentDetails[index].color,
                                child: ListTile(
                                  leading: Column(
                                      children: List.generate(
                                          subjectName.length,
                                              (index) => Text(subjectName[index]))),
                                ));
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                            height: 5,
                          ),
                        )))
              ],
            ),
          ),
        ));
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    subjectName.clear();
    List<DateTime> date = args.value;
    for (int i = 0; i < date.length; i++) {
      for (int j = 0; j < appointments.length; j++) {
        if (appointments[j].startTime.day == date[i].day &&
            appointments[j].startTime.month == date[i].month &&
            appointments[j].startTime.year == date[i].year) {
          subjectName.add(appointments[i].subject);
        }
      }
      setState(() {
        // subjectName = appointments[i].subject;
        // subjectName.add(appointments[i].subject);
        // subjectName.contains(app)
        if (kDebugMode) {
          print(date[i]);
        }
        if (kDebugMode) {
          print(subjectName.length);
        }
      });
    }
  }

  _AppointmentDataSource _getCalendarDataSource() {
    appointments = <Appointment>[];
    /*FutureBuilder(
        future: shifts,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: snapshot.data!.docs.map((document){
                appointments.add(Appointment(
                  startTime: DateFormat('dd-MM-yyyy').parse(document['date']),
                  endTime: DateFormat('dd-MM-yyyy').parse(document['date']),
                  subject: 'Til Rådighed',
                  color: Colors.green,
                ));
              }).toList(),);
          } else if (snapshot.hasError) {
            return const Icon(Icons.error_outline);
          } else {
            return const CircularProgressIndicator();
          }
        });*/
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: 2)),
      endTime: DateTime.now().add(Duration(days: 2, hours: 1)),
      subject: 'Planning',
      color: Colors.red,
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: 3)),
      endTime: DateTime.now().add(Duration(days: 3, hours: 1)),
      subject: 'Meeting',
      color: Colors.blue,
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: 4)),
      endTime: DateTime.now().add(Duration(days: 4, hours: 1)),
      subject: 'Retrospective',
      color: Colors.blue,
    ));

    return _AppointmentDataSource(appointments);
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _dateRangePickerController.selectedDate =
      viewChangedDetails.visibleDates[0];
      _dateRangePickerController.displayDate =
      viewChangedDetails.visibleDates[0];
    });
  }

  bool isAppointmentDate(DateTime date) {
    for (int j = 0; j < _specialDates.length; j++) {
      if (date.year == _specialDates[j].year &&
          date.month == _specialDates[j].month &&
          date.day == _specialDates[j].day) {
        return true;
      }
    }
    return false;
  }
}

class _MonthCellDecoration extends Decoration {
  const _MonthCellDecoration(
      {this.borderColor,
        required this.backgroundColor,
        required this.showIndicator,
        required this.indicatorColor});

  final Color? borderColor;
  final Color backgroundColor;
  final bool showIndicator;
  final Color indicatorColor;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MonthCellDecorationPainter(
        borderColor: borderColor,
        backgroundColor: backgroundColor,
        showIndicator: showIndicator,
        indicatorColor: indicatorColor);
  }
}

class _MonthCellDecorationPainter extends BoxPainter {
  _MonthCellDecorationPainter(
      {this.borderColor,
        required this.backgroundColor,
        required this.showIndicator,
        required this.indicatorColor});

  final Color? borderColor;
  final Color backgroundColor;
  final bool showIndicator;
  final Color indicatorColor;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect bounds = offset & configuration.size!;
    _drawDecoration(canvas, bounds);
  }

  void _drawDecoration(Canvas canvas, Rect bounds) {
    final Paint paint = Paint()..color = backgroundColor;
    canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, const Radius.circular(5)), paint);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    if (borderColor != null) {
      paint.color = borderColor!;
      canvas.drawRRect(
          RRect.fromRectAndRadius(bounds, const Radius.circular(5)), paint);
    }

    if (showIndicator) {
      paint.color = indicatorColor;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bounds.right - 6, bounds.top + 6), 2.5, paint);
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

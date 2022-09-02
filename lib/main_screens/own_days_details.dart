import 'dart:io';
import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shimmer/shimmer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'calendar_item.dart';
import 'edit_shift_screen.dart';

class OwnDaysDetailsScreen extends StatefulWidget {
  final String date, status, time, comment, color;
  final String? details;
  final QueryDocumentSnapshot<Map<String, dynamic>> data;
  final int awaitConfirmation;
  const OwnDaysDetailsScreen({Key? key, required this.date, required this.status, required this.time, required this.comment,
    required this.awaitConfirmation, this.details, required this.color,  required this.data}) : super(key: key);

  @override
  State<OwnDaysDetailsScreen> createState() => _OwnDaysDetailsScreenState();
}

class _OwnDaysDetailsScreenState extends State<OwnDaysDetailsScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  final databaseReference = FirebaseFirestore.instance;
  late ICalendar _iCalendar;

  late String time;
  late String comment;
  late String? timeRange;
  late String icsFilePath = "";

  late bool isSynced = false;
  late bool loading = true;

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];

  late TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = TimeOfDay(hour: 9, minute: 0);

  Future<void> sendAcceptedShiftNotification(String token, String date, String name) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('acceptShiftNotif');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date,
      'name': name,
    });
  }

  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
  }

  @override
  void initState() {
    super.initState();
    time = widget.time;
    if(widget.details != null){
      timeRange = widget.details!.substring(0,11);
    }
    comment = widget.comment;
    _getSyncStatus();
    Future.delayed(Duration(seconds: 1), () {
      isSynced? _downloadIcsFile() : null;
    });
    Future.delayed(Duration(seconds: 2), () {
      //_getAssetsFile();
      _getIcsEvents();
    });
  }

  _downloadIcsFile() async {
    Response response;
    var dio = Dio();
    var directory = await getApplicationDocumentsDirectory();
    var path = Platform.isAndroid ? "/sdcard/Download/" : directory.path + Platform.pathSeparator;

    FirebaseFirestore.instance.collection("user").doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) async {
      response = await dio.download(value['syncURL'], path + 'vikarlydata.ics');
    });
    print(path+'vikarlydata.ics');
    setState(() {
      icsFilePath = path + "vikarlydata.ics";
    });
  }

  Future _getIcsData() async {
    final icsString = await rootBundle.loadString('assets/guide/download.ics');
    final iCalendar = ICalendar.fromString(icsString);
    /// Use in production below
    /*final data = await File(icsFilePath).readAsLines();
    final iCalendar = ICalendar.fromLines(data);*/
    return iCalendar;
  }

  Future _getIcsEvents() async {
    ICalendar iCalendar = await _getIcsData();
    List<CalendarItem> items = [];

    for (var item in iCalendar.data) {
      items.add(CalendarItem.fromJson(item));
      //print(item['location'].toString());
    }
    setState(() {
      loading = false;
    });
    return items;
  }

  /// Live version method
  /*Future<void> _getAssetsFile() async {
    try {
      final data = await File(icsFilePath).readAsLines();
      setState(() {
        //_iCalendar = ICalendar.fromLines(lines);
        _iCalendar = ICalendar.fromLines(data);
      });
    } catch (e) {
      throw 'Error: $e';
    }
    setState(() {
      loading = false;
    });
  }*/

  /*Future<void> _getAssetsFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final myPath = path.join(directory.path, 'download.ics');
      final data = await rootBundle.load("assets/guide/download.ics");
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final file = await File(myPath).writeAsBytes(bytes);
      final lines = await file.readAsLines();
      setState(() {
        _iCalendar = ICalendar.fromLines(lines);
      });
    } catch (e) {
      throw 'Error: $e';
    }
    setState(() {
      loading = false;
    });
  }*/

  /*Widget _generateTextContent() {
    const style = TextStyle(color: Colors.black);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              children: _iCalendar.data.map((e) => TextSpan(
                children: e.keys.map((f) => TextSpan(children: [
                  TextSpan(text: '${f.toUpperCase()}: ', style: style.copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${e[f]}\n')
                ])).toList(),)).toList()),
        ],
        style: style,
      ),
    );
  }*/

  _getSyncStatus() {
    FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      setState((){
        value['isSynced'] == true ? isSynced = true : isSynced = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Vagt detaljer"),
        actions: [
          IconButton(onPressed: () async {
            if (widget.awaitConfirmation != 0){
              showTopSnackBar(context, CustomSnackBar.error(message: "En vagt er allerede tildelt. Du kan ikke redigere dagen.",),);
            } else {
              var userRef = await databaseReference.collection(user!.uid);
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditShiftScreen(date: widget.date, userRef: userRef, details: widget.time)));
              setState(() {
                time = result[0];
                comment = result[1];
              });
            }
          }, icon: Icon(Icons.edit_calendar_outlined, color: Colors.white,)),
        ],
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white,),),
      ),
      body: loading? Column(
        children: <Widget> [
          Shimmer.fromColors(
              baseColor: Colors.grey,
              highlightColor: Colors.white10,
              child: Container(
                height: MediaQuery.of(context).size.height / 6,
                margin: EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white10
                ),
              )
          ),
          Shimmer.fromColors(
              baseColor: Colors.grey,
              highlightColor: Colors.white10,
              child: Container(
                height: MediaQuery.of(context).size.height / 6,
                margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white10
                ),
              )
          ),
        ],
      ): ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          // Date
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.only(right: 10, left: 5),
                      child: Icon(Icons.date_range_outlined, color: Colors.grey,)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                          child: Text("Dato", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                      Container(child: Text(getDayOfWeek(DateFormat('dd-MM-yyyy').parse(widget.date))
                          + ", " + widget.date.substring(0,2)
                          + " " + months[DateFormat('dd-MM-yyyy').parse(widget.date).month.toInt() - 1]
                          + " " + widget.date.substring(6), style: TextStyle(color: Colors.grey),))
                    ],
                  ),
                ],
              ),
          ),
          // Status
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child: Icon(Icons.warning_amber_outlined, color: Colors.grey,)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text("Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(child: Text(widget.status, style: TextStyle(color: Color(int.parse(widget.color)), fontWeight: FontWeight.w500),)),
                    if (widget.awaitConfirmation == 1) Container(
                      padding: EdgeInsets.only(top: 10),
                      height: 35,
                      //width: 100,
                      child: ElevatedButton.icon(
                          onPressed: () async {
                            await widget.data.reference.update({"awaitConfirmation": 2, 'status': "Godkendt vagt", 'color' : '0xFF4CAF50'});
                            Navigator.pop(context);
                            showTopSnackBar(context, CustomSnackBar.success(message: "Vagt accepteret",),);
                            var adminRef = await databaseReference.collection('user').get();
                            var userNameRef = await databaseReference.collection('user').doc(user!.uid).get();
                            for (var admins in adminRef.docs){
                              if (admins.get(FieldPath(const ["isAdmin"])) == true){
                                sendAcceptedShiftNotification(admins.get(FieldPath(const ["token"])), widget.date, userNameRef.get(FieldPath(const ["name"])));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 16),
                            primary: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.check, color: Colors.white, size: 14,),
                          label: Text("Accepter", style: TextStyle(fontSize: 14),)),
                    ) else Container(),
                  ],
                ),

                // Accept button

              ],
            ),
          ),
          // Time
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child: Icon(Icons.access_time_outlined, color: Colors.grey,)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text("Kan arbejde", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(child: Text(time, style: TextStyle(color: Colors.grey),))
                  ],
                )
              ],
            ),
          ),
          // Comment
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child: Icon(Icons.comment_outlined, color: Colors.grey,)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text("Egen kommentar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(
                        width: MediaQuery.of(context).size.width/1.2,
                        child: Text(comment, style: TextStyle(color: Colors.grey),))
                  ],
                )
              ],
            ),
          ),
          if (widget.awaitConfirmation == 1 || widget.awaitConfirmation == 2) Container(
            padding: EdgeInsets.only(top: 20),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Center(
                  child: Text("Vagtoplysninger", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                ),
                // Timerange
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 10, left: 5),
                          child: Icon(Icons.access_time_outlined, color: Colors.grey,)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text("Tidsrum", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                          Container(child: Text(timeRange!, style: TextStyle(color: Colors.grey),))
                        ],
                      )
                    ],
                  ),
                ),
                // Details
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 10, left: 5),
                          child: Icon(Icons.comment_outlined, color: Colors.grey,)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text("Detaljer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                          Container(
                              width: MediaQuery.of(context).size.width/1.2,
                              child: Text(widget.details!.substring(22), style: TextStyle(color: Colors.grey),))
                        ],
                      )
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 10, left: 5),
                          child: Icon(Icons.school_outlined, color: Colors.grey,)),
                      Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text("Lokalefordeling", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),)),
                    ],
                  ),
                ),

                // TODO futurebuilder for _getIcsEvents
                FutureBuilder(
                            future: _getIcsEvents(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return Text(snapshot.data.toString());
                              } else if (snapshot.hasError) {
                                return Icon(Icons.error_outline);
                              } else {
                                return CircularProgressIndicator();
                              }
                            })
                      ],
            ),
          ) else Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 50),
            height: 100,
            width: 250,
            child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(title: Text("Slet dag"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      content: Text("Er du sikker på at slette dagen?"),
                      actions: [TextButton(onPressed: () {widget.data.reference.delete(); Navigator.pop(context); Navigator.pop(context);  showTopSnackBar(context, CustomSnackBar.success(message: "Vagt slettet",),);
                        }
                          , child: const Text("SLET", style: TextStyle(color: Colors.red),))],); });
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.delete_outline, color: Colors.white, size: 18,),
                label: Text("Slet dag")),
          ),
          if (widget.status == "Tilkaldt") Container(
            //padding: EdgeInsets.only(left: 10),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(top: 20),
                          child: TextButton.icon(onPressed: null, icon: Icon(Icons.timelapse), label: Text("Timer"))),
                      const Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Column(
                                    children: [
                                      Container(padding: EdgeInsets.only(bottom: 5), child: Text("Fra")),
                                      Container(
                                        padding: EdgeInsets.only(left: 5, right: 5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white
                                        ),
                                        child: TextButton(onPressed: () async {
                                          startTime = (await showTimePicker(initialTime: startTime, context: context))!;
                                          setState(() {
                                            startTime.format(context);
                                          });
                                        },
                                          child: Text(startTime.format(context)),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Column(
                                    children: [
                                      Container(padding: EdgeInsets.only(bottom: 5), child: Text("Til")),
                                      Container(
                                        padding: EdgeInsets.only(left: 5, right: 5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white
                                        ),
                                        child: TextButton(onPressed: () async {
                                          endTime = (await showTimePicker(initialTime: endTime, context: context))!;
                                          setState(() {
                                            endTime.format(context);
                                          });
                                        },
                                          child: Text(endTime.format(context)),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(top: 20, left: 15),
                                  child: ElevatedButton.icon(onPressed: (){
                                    showDialog(context: context, builder: (BuildContext context){
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                        elevation: 0,
                                        title: Text("Gem timer"),
                                        content: Text("Du er ved at gemme dine timer."),
                                        actions: [
                                          TextButton(onPressed: () async {
                                            await widget.data.reference.update({'details': startTime.format(context) + "-" + endTime.format(context) + "\n\nDetaljer: Ingen",});
                                            setState((){
                                              timeRange = startTime.format(context) + "-" + endTime.format(context);
                                            });
                                            Navigator.pop(context);
                                            showTopSnackBar(context, CustomSnackBar.success(message: "Nyt tidsrum gemt",),);
                                          }, child: Text("GEM", style: TextStyle(color: Colors.green),))
                                        ],
                                      );
                                    });
                                  }, icon: Icon(Icons.save, size: 18,), label: Text("Gem", style: TextStyle(fontSize: 12),), ),
                                ),
                              ),
                            ],),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Text("Du har mulighed for at indskrive dine timer, hvis du er blevet tilkaldt. Således kan timerne inkluderes inde under 'Mine timer'."
                      , style: TextStyle(color: Colors.grey, fontSize: 14),)),
              ],
            ),
          ) else Container()
        ],
      ),
    );
  }
}

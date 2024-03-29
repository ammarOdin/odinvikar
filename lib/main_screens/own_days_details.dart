import 'dart:io';
import 'dart:core';
import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:odinvikar/main_screens/shiftinfo_sync.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
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

  late String time;
  late String comment;
  late String? timeRange;
  late String icsFilePath = "null";

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
  }

  _downloadIcsFile() async {
    Response response;
    var dio = Dio();
    var directory = await getApplicationDocumentsDirectory();
    var path = directory.path + Platform.pathSeparator;

    FirebaseFirestore.instance.collection("user").doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) async {
      response = await dio.download(value['syncURL'], path + 'vikarlydata.ics');
    });
    setState(() {
      icsFilePath = path + "vikarlydata.ics";
      loading = false;
    });
  }

  Future<List> _getCalenderEvents() async {
    //final icsString = await rootBundle.loadString('assets/guide/download.ics');
    //final calendar = ICalendar.fromString(icsString);
    /// Use in production below
    final data = await File(icsFilePath).readAsLines();
    final calendar = ICalendar.fromLines(data);

    // List for calendar items
    List items = [];
    // List for datetime start
    List dtstart = [];
    // List for datetime end
    List dtend = [];

    // List for displayable items for the user
    List display = [];
    // List for parsed items that are fetched from icalendar
    List displayItems = [];

    // Loop through all calendar events that have been downloaded - then save the relevant info
    for (var data in calendar.data) {
      dtstart.add(data['dtstart']);
      dtend.add(data['dtend']);
      items.add(data['location'].toString() + ';' + data['summary'].toString() + ';' + data['description'].toString() + ';' + data['attendee'].toString());
    }
    dtstart.removeRange(0, 3); items.removeRange(0, 3); dtend.removeRange(0, 3);

    // Loop through the saved info, and parse/prettify the data, then save to a map that will be used when displaying data
    for (var item in items){
      List itemList = item.split(';');
      List classList = itemList.last.split(',');

      DateTime startTime = DateTime.parse(dtstart[items.indexOf(item)].dt.toString());
      DateTime endTime = DateTime.parse(dtend[items.indexOf(item)].dt.toString());
      String className = classList.length == 10 ? classList[8].substring(7) : " Ukendt klasse";
      String location = itemList[0] == 'null' ? 'Ukendt lokation' : itemList[0];
      String summary = itemList[1] == 'null' ? 'Ukendt fag' : itemList[1];
      String description = itemList[2].substring(314).contains(new RegExp(r'[a-z]')) ? itemList[2].substring(314).toString().replaceAll('\\n', '\n') : 'Ingen vikarbesked';

      // Check whether the date of the shift is the same as the date of the calendar events
      if (widget.date == DateFormat('dd-MM-yyyy').format(DateTime.parse(dtstart[items.indexOf(item)].dt)).toString()) {
        Map itemMap = {
          'start': startTime,
          'end': endTime,
          'location': location,
          'summary': summary,
          'classname': className,
          'description': description
        };
        displayItems.add(itemMap);
      }
    }

    // The saved data from icalendar is not sorted timewise - we need to sort it in a ascending manner (hours)
    displayItems.sort((a,b){
      var aTime = a['start'];
      var bTime = b['start'];
      return aTime.compareTo(bTime);
    });

    // Save the data to a widget that can be displayed in the futurebldr
    for (var displayItem in displayItems){
      if (widget.date == DateFormat('dd-MM-yyyy').format(displayItem['start']).toString()){
        display.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 6,
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    Text('${DateFormat('HH:mm').format(displayItem['start'])}'),
                    Padding(padding: EdgeInsets.only(top: 25)),
                    Text('${DateFormat('HH:mm').format(displayItem['end'])}'),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                height: MediaQuery.of(context).size.height / 6,
                width: 3,
                color: Colors.blue,
              ),
              Container(
                height: 120,
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Klasse:${displayItem['classname']}'),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text('Fag: ${displayItem['summary']}'),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text('Lokale: ${displayItem['location']}'),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    InkWell(
                        onTap: (){
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text("Vikarbesked"),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              content: Text('${displayItem['description']}'),
                              actions: [
                                TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")),
                              ],);});
                        },
                        child: Text(displayItem['description'] == 'Ingen vikarbesked' ? 'Ingen vikarbesked' : 'Se vikarbesked' , style: TextStyle(color: Colors.blue),))
                  ],
                ),
              )
            ],
          ),
        );
      }
    }
    FirebaseFirestore.instance.collection(user!.uid).doc(widget.date).get().then((value) {
      if (calendar.data.length > 3 && displayItems.isNotEmpty && widget.date == value['date']){
        value.reference.update({
          'details': DateFormat('HH:mm').format(displayItems.first['start']).toString() + "-" + DateFormat('HH:mm').format(displayItems.last['end']).toString() + "\n\nDetaljer: Ingen",
        });
      }
    });
    return display;
  }

  _getSyncStatus() {
    FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      setState((){
        value['isSynced'] == true ? isSynced = true : Navigator.push(context, PageTransition(duration: Duration(milliseconds: 200), type: PageTransitionType.rightToLeft, child: ShiftInfoSyncScreen()));
      });
    });
  }

  Widget buildShimmer(){
    return Shimmer.fromColors(
        baseColor: Colors.grey,
        highlightColor: Colors.white10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 40),
                child: Icon(Icons.square_rounded, color: Colors.grey.withOpacity(0.25), size: 100,)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.75,
                  height: MediaQuery.of(context).size.height / 40,
                  margin: EdgeInsets.only(left: 10, right: 10, top: 40),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.withOpacity(0.25)
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  height: MediaQuery.of(context).size.height / 40,
                  margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.withOpacity(0.25)
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 4,
                  height: MediaQuery.of(context).size.height / 40,
                  margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.withOpacity(0.25)
                  ),
                ),
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: false,
        backgroundColor: Colors.blue,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Text("Vagtdetaljer",  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),),
        actions: [
          PopupMenuButton(itemBuilder: (context){
            return[
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.orange,),
                    Padding(padding: EdgeInsets.only(left: 10),),
                    Text("Rediger", style: TextStyle(color: Colors.black)),
                  ],
                )
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red,),
                    Padding(padding: EdgeInsets.only(left: 10),),
                    Text("Slet", style: TextStyle(color: Colors.black)),
                  ],
                )
              ),
            ];
          },
          onSelected: (value) async {
            if (value == 0){
              if (widget.awaitConfirmation != 0){
                Flushbar(
                    margin: EdgeInsets.all(10),
                    borderRadius: BorderRadius.circular(10),
                    title: 'Vagt',
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    message: "En vagt er allerede tildelt. Du kan ikke redigere dagen",
                    flushbarPosition: FlushbarPosition.BOTTOM).show(context);
              } else {
                var userRef = await databaseReference.collection(user!.uid);
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditShiftScreen(date: widget.date, userRef: userRef, details: widget.time)));
                setState(() {
                  time = result[0];
                  comment = result[1];
                });
              }
            } else if (value == 1){
              try{
                if (widget.awaitConfirmation != 0) {
                  Flushbar(
                      margin: EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(10),
                      title: 'Vagt',
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                      message: "En vagt er allerede tildelt. Du kan ikke slette dagen",
                      flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                } else {
                  Dialogs.bottomMaterialDialog(
                      msg: 'Er du sikker på at slette dagen?',
                      title: 'Slet dag',
                      context: context,
                      actions: [
                        IconsOutlineButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          text: 'Annuller',
                          iconData: Icons.cancel_outlined,
                          textStyle: TextStyle(color: Colors.grey),
                          iconColor: Colors.grey,
                        ),
                        IconsButton(
                          onPressed: () {
                            widget.data.reference.delete();
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Vagt',
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                                message: "Vagt slettet",
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);

                          },
                          text: 'Slet',
                          iconData: Icons.delete,
                          color: Colors.red,
                          textStyle: TextStyle(color: Colors.white),
                          iconColor: Colors.white,
                        ),
                      ]);
                }
              } on FirebaseAuthException catch (e){
                /// show error snackbar
              }
            }
          },
          )
        ],
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white,),),
      ),
      body: loading? Column(
        children: List.generate(3, (i) {
          return buildShimmer();
        })
      ): ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          // Date
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Row(
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
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Vagt',
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                                message: "Vagt accepteret",
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
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
                            backgroundColor: Colors.green,
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
            padding: EdgeInsets.only(top: 30),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Center(
                  child: Text("Vagtoplysninger", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                              width: MediaQuery.of(context).size.width / 1.2,
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
                          child: Text("Timeoversigt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),)),
                    ],
                  ),
                ),

                // TODO futurebuilder for _getIcsEvents
                FutureBuilder(
                            future: _getCalenderEvents(),
                            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                              int? ListLenght = snapshot.data?.length;
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data?.length,
                                    itemBuilder: (context, index){
                                      var calendarItem = snapshot.data?[index];
                                      return SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            calendarItem
                                          ],
                                        ),
                                      );
                                    }
                                );
                              } else if (snapshot.hasError) {
                                return Icon(Icons.error_outline, size: 30,);
                              } else if (snapshot.connectionState == ConnectionState.waiting){
                                return SpinKitRing(color: Colors.blue, size: 50,);
                              } else if (ListLenght!.toInt() == 0){
                                return Text("Intet at vise", style: TextStyle(color: Colors.black),);
                              } else {
                                return Container();
                              }
                            })
                      ],
            ),
          ) else Container(),
        ],
      ),
    );
  }
}

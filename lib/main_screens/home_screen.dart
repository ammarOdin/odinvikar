import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:tap_to_expand/tap_to_expand.dart';
import 'package:week_of_year/week_of_year.dart';
import '../assets/bezier_shape.dart';
import 'own_days_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<HomeScreen> with TickerProviderStateMixin {

  User? user = FirebaseAuth.instance.currentUser;
  get shift => FirebaseFirestore.instance.collection(user!.uid).orderBy('month', descending: false).orderBy('date', descending: false);
  get unsortedShift => FirebaseFirestore.instance.collection(user!.uid).orderBy('month', descending: false);
  final databaseReference = FirebaseFirestore.instance;
  late int sliderValue;

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];

  @override
  void initState() {
    sliderValue = 1;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
  }

  String getWeekOfYear(){
    if (DateTime.now().weekday == DateTime.sunday){
      return DateTime.now().add(Duration(days: 1)).weekOfYear.toString();
    } else if (DateTime.now().weekday == DateTime.saturday){
      return DateTime.now().add(Duration(days: 2)).weekOfYear.toString();
    } else {
      return DateTime.now().weekOfYear.toString();
    }
  }

  Future<void> sendAcceptedShiftNotification(String token, String date, String name) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('acceptShiftNotif');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date,
      'name': name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(
            color: Colors.blue,
            height: MediaQuery.of(context).size.height / 4.5,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 12,
                      left: 25
                    ),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                        child: Text(
                          "Odinskolen",
                          style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                        ))),
              ],
            ),
          ),
          ClipPath(
            clipper: HomeHeaderCustomClipPath(),
            child: ClipRRect(
              child: Container(
                //height: MediaQuery.of(context).size.height / 8,
                height: 80,
                color: Colors.blue,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 25),
                child: Text("Kommende vagter", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16),),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: CustomSlidingSegmentedControl(
                  onValueChanged: (value) {
                    setState(() {
                      sliderValue = int.parse(value.toString());
                    });
                  },
                  children: {
                    1: Text('Uge'),
                    2: Text('Måned'),
                  },
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.3),
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInToLinear,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: StreamBuilder(
                stream: unsortedShift.snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData){
                    return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                      color: Colors.blue,
                      size: 50,
                    ));
                  } else if (snapshot.data!.docs.isEmpty){
                    return Container(
                      padding: const EdgeInsets.all(50),
                      child: const Center(child: Text(
                        "Ingen Vagter",
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      ),),
                    );
                  }
                  return Column(
                    children: snapshot.data!.docs.map((document){
                      DateTime date = DateFormat('dd-MM-yyyy').parse(document['date']);
                      int currentWeek = DateTime.now().weekOfYear.toInt();
                      int documentWeek = document['week'];
                      int currentMonth = DateTime.now().month.toInt();
                      int documentMonth = document['month'];

                      if (DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday){
                        currentWeek += 1;
                      }
                      if (sliderValue == 1 && currentWeek == documentWeek){
                        if (document['awaitConfirmation'] == 2 && DateFormat('dd-MM-yyyy').format(DateTime.now()).toString() == document['date']) {
                          return TapToExpand(
                            openedHeight: 275,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['details'].substring(0,11)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['status']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['details'].substring(22)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 20)),
                                Center(child: ElevatedButton(onPressed: (){
                                  var reference = document as QueryDocumentSnapshot<Map<String, dynamic>>;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
                                    date: document.id,
                                    status: document['status'],
                                    time: document['time'],
                                    comment: document['comment'],
                                    awaitConfirmation: document['awaitConfirmation'],
                                    details: document['details'],
                                    color: document['color'],
                                    data: reference,
                                  )));
                                }, style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(Size(150, 50)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        )
                                    )),child: Text("Vagtdetaljer", style: TextStyle(fontSize: 16),))),
                                Padding(padding: EdgeInsets.only(bottom: 10)),
                              ],
                            ), title: Row(
                            children: [
                              Icon(Icons.work_history_outlined, color: Colors.white),
                              Padding(padding: EdgeInsets.only(right: 10)),
                              Text("${getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date']))} d. ${document['date'].substring(0,5)}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                            color: Color(int.parse(document['color'])),
                          );
                        } else if (document['awaitConfirmation'] != 0 && date.isAfter(DateTime.now()) || date == DateTime.now()) {
                          return TapToExpand(
                            openedHeight: 275,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['details'].substring(0,11)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['status']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['details'].substring(22)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 40)),
                                Center(child: ElevatedButton(onPressed: (){
                                  var reference = document as QueryDocumentSnapshot<Map<String, dynamic>>;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
                                    date: document.id,
                                    status: document['status'],
                                    time: document['time'],
                                    comment: document['comment'],
                                    awaitConfirmation: document['awaitConfirmation'],
                                    details: document['details'],
                                    color: document['color'],
                                    data: reference,
                                  )));
                                }, style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(Size(150, 50)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        )
                                    )),child: Text("Vagtdetaljer", style: TextStyle(fontSize: 16),))),
                                Padding(padding: EdgeInsets.only(bottom: 10)),
                              ],
                            ), title: Row(
                            children: [
                              Icon(Icons.work_history_outlined, color: Colors.white),
                              Padding(padding: EdgeInsets.only(right: 10)),
                              Text("${getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date']))} d. ${document['date'].substring(0,5)}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                            color: Color(int.parse(document['color'])),
                          );
                        } else if (document['awaitConfirmation'] == 0 && date.isAfter(DateTime.now()) || date == DateTime.now()) {
                          return TapToExpand(
                            openedHeight: 250,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['time']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['comment']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),                                Padding(padding: EdgeInsets.only(top: 30)),
                                Center(child: ElevatedButton(onPressed: (){
                                  var reference = document as QueryDocumentSnapshot<Map<String, dynamic>>;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
                                    date: document.id,
                                    status: document['status'],
                                    time: document['time'],
                                    comment: document['comment'],
                                    awaitConfirmation: document['awaitConfirmation'],
                                    color: document['color'],
                                    data: reference,
                                  )));
                                }, style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(Size(150, 50)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        )
                                    )),child: Text("Vagtdetaljer", style: TextStyle(fontSize: 16),))),
                                Padding(padding: EdgeInsets.only(bottom: 10)),
                              ],
                            ), title: Row(
                            children: [
                              Icon(Icons.work_history_outlined, color: Colors.white),
                              Padding(padding: EdgeInsets.only(right: 10)),
                              Text("${getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date']))} d. ${document['date'].substring(0,5)}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                            color: Color(int.parse(document['color'])),
                          );
                        } else {
                          return Container();
                        }
                      } else if (sliderValue == 2 && currentMonth == documentMonth){
                        if (document['awaitConfirmation'] == 2 && DateFormat('dd-MM-yyyy').format(DateTime.now()).toString() == document['date']) {
                          return TapToExpand(
                            openedHeight: 275,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['details'].substring(0,11)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['status']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['details'].substring(22)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 20)),
                                Center(child: ElevatedButton(onPressed: (){
                                  var reference = document as QueryDocumentSnapshot<Map<String, dynamic>>;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
                                    date: document.id,
                                    status: document['status'],
                                    time: document['time'],
                                    comment: document['comment'],
                                    awaitConfirmation: document['awaitConfirmation'],
                                    details: document['details'],
                                    color: document['color'],
                                    data: reference,
                                  )));
                                }, style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(Size(150, 50)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        )
                                    )),child: Text("Vagtdetaljer", style: TextStyle(fontSize: 16),))),
                                Padding(padding: EdgeInsets.only(bottom: 10)),
                              ],
                            ), title: Row(
                            children: [
                              Icon(Icons.work_history_outlined, color: Colors.white),
                              Padding(padding: EdgeInsets.only(right: 10)),
                              Text("${getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date']))} d. ${document['date'].substring(0,5)}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                            color: Color(int.parse(document['color'])),
                          );
                        } else if (document['awaitConfirmation'] != 0 && date.isAfter(DateTime.now())) {
                          return TapToExpand(
                            openedHeight: 275,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['details'].substring(0,11)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['status']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['details'].substring(22)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 40)),
                                Center(child: ElevatedButton(onPressed: (){
                                  var reference = document as QueryDocumentSnapshot<Map<String, dynamic>>;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
                                    date: document.id,
                                    status: document['status'],
                                    time: document['time'],
                                    comment: document['comment'],
                                    awaitConfirmation: document['awaitConfirmation'],
                                    details: document['details'],
                                    color: document['color'],
                                    data: reference,
                                  )));
                                }, style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(Size(150, 50)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        )
                                    )),child: Text("Vagtdetaljer", style: TextStyle(fontSize: 16),))),
                                Padding(padding: EdgeInsets.only(bottom: 10)),
                              ],
                            ), title: Row(
                            children: [
                              Icon(Icons.work_history_outlined, color: Colors.white),
                              Padding(padding: EdgeInsets.only(right: 10)),
                              Text("${getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date']))} d. ${document['date'].substring(0,5)}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                            color: Color(int.parse(document['color'])),
                          );
                        } else if (document['awaitConfirmation'] == 0 && date.isAfter(DateTime.now())) {
                          return TapToExpand(
                            openedHeight: 250,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['time']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),                                Padding(padding: EdgeInsets.only(top: 7)),
                                Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.black.withOpacity(0.30),),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Text("${document['comment']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ],
                                ),                                Padding(padding: EdgeInsets.only(top: 30)),
                                Center(child: ElevatedButton(onPressed: (){
                                  var reference = document as QueryDocumentSnapshot<Map<String, dynamic>>;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OwnDaysDetailsScreen(
                                    date: document.id,
                                    status: document['status'],
                                    time: document['time'],
                                    comment: document['comment'],
                                    awaitConfirmation: document['awaitConfirmation'],
                                    color: document['color'],
                                    data: reference,
                                  )));
                                }, style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(Size(150, 50)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        )
                                    )),child: Text("Vagtdetaljer", style: TextStyle(fontSize: 16),))),
                                Padding(padding: EdgeInsets.only(bottom: 10)),
                              ],
                            ), title: Row(
                            children: [
                              Icon(Icons.work_history_outlined, color: Colors.white),
                              Padding(padding: EdgeInsets.only(right: 10)),
                              Text("${getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date']))} d. ${document['date'].substring(0,5)}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                            color: Color(int.parse(document['color'])),
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }

                    }).toList(),
                  );
                }),
          ),
        ],
      ),
    );
  }
}




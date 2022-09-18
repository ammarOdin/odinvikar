import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/week_of_year.dart';
import '../card_assets.dart';
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
  late TabController _controller;

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener((){
      /*if (kDebugMode) {
        print('my index is '+ _controller.index.toString());
      }*/
      setState(() {
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
            height: MediaQuery.of(context).size.height / 4,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 20),
                    child: const Center(
                        child: Text(
                          "Kommende vagter",
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ))),
                Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 30),
                    child: Center(
                      child: Text(
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        style: const TextStyle(color: Colors.white, fontSize: 26),
                      ),
                    )
                ),
              ],
            ),
          ),
          Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(labelColor: Colors.black, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue, controller: _controller, tabs: const [Tab(text: "Uge"), Tab(text: "Måned",)])),

          Row(
            children: [
              Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.square_rounded, color: Colors.orange, size: 16,),
                  ),
                  Text(" Tilgængelig", style: TextStyle(fontSize: 12),)
                ],
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.square_rounded, color: Colors.red, size: 16,),
                  ),
                  Text(" Afventer accept", style: TextStyle(fontSize: 12),)
                ],
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.square_rounded, color: Colors.green, size: 16,),
                  ),
                  Text(" Godkendt vagt", style: TextStyle(fontSize: 12),)
                ],
              ),
            ],
          ),

          const Divider(thickness: 1),

          if (_controller.index == 1) Container(
              padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
              child: Text(months[DateTime.now().month.toInt() - 1], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
          if (_controller.index == 0) Container(
              padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
              child: Text("Uge " + getWeekOfYear(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),

          Container(
            padding: EdgeInsets.only(top: 10),
            child: StreamBuilder(
                stream: unsortedShift.snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData){
                    return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                      color: Colors.blue,
                      size: 50,
                    ));
                  }else if (snapshot.data!.docs.isEmpty){
                    return Container(
                      padding: const EdgeInsets.all(50),
                      child: const Center(child: Text(
                        "Ingen Vagter",
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      ),),
                    );
                  }
                  if (_controller.index == 0){
                    return Column(
                      children: snapshot.data!.docs.map((document){
                        if (DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday){
                          int week = document['week'];
                          int weekOfYear = DateTime.now().weekOfYear.toInt() + 1;
                          if (week == weekOfYear && document['awaitConfirmation'] != 0) {
                            return AvailableShiftCard(time: document['details'].substring(0,11), icon: Icon(Icons.square_rounded, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
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
                            });
                          } else if (week == weekOfYear && document['awaitConfirmation'] == 0) {
                            return AvailableShiftCard(time: "Tilgængelig", icon: Icon(Icons.square_rounded, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
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
                            });
                          } else {
                            return Container();
                          }
                        } else if (DateTime.now().weekday != DateTime.saturday || DateTime.now().weekday != DateTime.sunday) {
                          if (document['week'] == DateTime.now().weekOfYear && document['awaitConfirmation'] == 2 && DateFormat('dd-MM-yyyy').format(DateTime.now()).toString() == document['date']) {
                            return ActiveShiftCard(time: document['details'].substring(0,11), icon: Icon(Icons.square_rounded, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
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
                            });
                          } else if (document['week'] == DateTime.now().weekOfYear && document['awaitConfirmation'] != 0 ) {
                            return AvailableShiftCard(time: document['details'].substring(0,11), icon: Icon(Icons.square_rounded, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
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
                            });
                          } else if (document['week'] == DateTime.now().weekOfYear && document['awaitConfirmation'] == 0 ) {
                            return AvailableShiftCard(time: "Tilgængelig", icon: Icon(Icons.square_rounded, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
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
                            });
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      }).toList(),
                    );
                  } else if (_controller.index == 1){
                    return Column(
                      children: snapshot.data!.docs.map((document){
                        if (document['month'] == DateTime.now().month && document['awaitConfirmation'] != 0) {
                          return AvailableShiftCard(time: document['details'].substring(0,11), icon: Icon(Icons.square_rounded, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
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
                          });
                        } else if (document['month'] == DateTime.now().month && document['awaitConfirmation'] == 0) {
                          return AvailableShiftCard(time: "Tilgængelig", icon: Icon(Icons.square_rounded, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
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
                          });
                        } else {
                          return Container();
                        }
                      }).toList(),
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
        ],
      ),
    );
  }
}




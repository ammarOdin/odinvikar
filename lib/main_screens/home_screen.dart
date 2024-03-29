import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:odinvikar/assets/card_assets.dart';
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
          Transform.translate(
            offset: Offset(0, -3),
            child: ClipPath(
              clipper: HomeHeaderCustomClipPath(),
              child: Container(
                  height: 80,
                  color: Colors.blue,
                ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 15),
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
                          /// active shift card
                          return ActiveShiftCard(text: document['date'] , day: getDayOfWeek(date), icon: Icon(Icons.arrow_forward_ios), time: document['details'].substring(0,11), onPressed: (){
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
                          }, color: Color(int.parse(document['color'])),);
                        } else if (document['awaitConfirmation'] != 0 && (date.isAfter(DateTime.now()) || DateFormat('dd-MM-yyyy').format(date) == DateFormat('dd-MM-yyyy').format(DateTime.now()))) {
                          /// Awaiting response from user card
                          return AvailableShiftCard(text: document['date'] , day: getDayOfWeek(date), icon: Icon(Icons.arrow_forward_ios), time: document['details'].substring(0,11), onPressed: (){
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
                          }, color: Color(int.parse(document['color'])),);
                        } else if (document['awaitConfirmation'] == 0 && date.isAfter(DateTime.now()) || DateFormat('dd-MM-yyyy').format(date) == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
                          /// Available user card
                          return AvailableShiftCard(text: document['date'] , day: getDayOfWeek(date), icon: Icon(Icons.arrow_forward_ios), time: document['time'], onPressed: (){
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
                          }, color: Color(int.parse(document['color'])),);
                        } else {
                          return Container();
                        }
                      } else if (sliderValue == 2 && currentMonth == documentMonth && DateTime.now().year.toString() == document['date'].substring(6)){
                        if (document['awaitConfirmation'] == 2 && DateFormat('dd-MM-yyyy').format(DateTime.now()).toString() == document['date']) {
                          return ActiveShiftCard(text: document['date'] , day: getDayOfWeek(date), icon: Icon(Icons.arrow_forward_ios), time: document['details'].substring(0,11), onPressed: (){
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
                          }, color: Color(int.parse(document['color'])),);
                        } else if (document['awaitConfirmation'] != 0 && date.month == document['month']) {
                          return AvailableShiftCard(text: document['date'] , day: getDayOfWeek(date), icon: Icon(Icons.arrow_forward_ios), time: document['details'].substring(0,11), onPressed: (){
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
                          }, color: Color(int.parse(document['color'])),);
                        } else if (document['awaitConfirmation'] == 0 && date.month == document['month']) {
                          return AvailableShiftCard(text: document['date'] , day: getDayOfWeek(date), icon: Icon(Icons.arrow_forward_ios), time: document['time'], onPressed: (){
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
                          }, color: Color(int.parse(document['color'])),);
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




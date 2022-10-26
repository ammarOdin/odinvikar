import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:odinvikar/admin/admin_edit_shift.dart';
import 'package:tap_to_expand/tap_to_expand.dart';
import 'package:url_launcher/url_launcher.dart';
import '../assets/bezier_shape.dart';
import '../assets/card_assets.dart';
import 'admin_assign_shift.dart';
import 'admin_shift_details.dart';


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminHomeScreen> with TickerProviderStateMixin {

  get users => FirebaseFirestore.instance.collection('user');
  final databaseReference = FirebaseFirestore.instance;
  late int sliderValue;

  @override
  void initState() {
    sliderValue = 1;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<List> getUserInfo() async {
    var userRef = await databaseReference.collection('user').get();
    List<String> entireShift = [];
    List todayList = [];
    List tomorrowList = [];

    for (var users in userRef.docs){
      var shiftRef;
      if (sliderValue == 1){
        shiftRef = await databaseReference.collection(users.id).
        where("date", isEqualTo: DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()).get();
      } else if (sliderValue == 2){
        shiftRef = await databaseReference.collection(users.id).
        where("date", isEqualTo: DateFormat('dd-MM-yyyy').format(DateTime.now().add(Duration(days: 1))).toString()).get();
      }

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

    for (var shifts in entireShift){
      List shiftSplit = shifts.split(";");
      if (shiftSplit[0] == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
        todayList.add(
            TapToExpand(
              openedHeight: 175,
              borderRadius: 20,
              content: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: () async {
                        var userRef = await databaseReference.collection(shiftSplit[8]);
                        var dataRef = await databaseReference.collection(shiftSplit[8]).doc(shiftSplit[0]);
                        if (int.parse(shiftSplit[9]) != 0){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
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
                          ))); } else if (int.parse(shiftSplit[9]) == 0){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
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
                          )));
                        }
                      }, style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          minimumSize: MaterialStateProperty.all(Size(150, 50)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          )),child: Text("Vagtdetaljer", style: TextStyle(fontSize: 16, color: Colors.black),)),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Expanded(child: IconButton(icon: const Icon(Icons.phone, color: Colors.white,), onPressed: (){launch("tel:" + shiftSplit[5]);},)),
                      Expanded(child: IconButton(icon: const Icon(Icons.message, color: Colors.white,), onPressed: (){launch("sms:" + shiftSplit[5]);},)),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 10),)
                ],
              ), title: Row(
              children: [
                Icon(Icons.person, color: Colors.white),
                Padding(padding: EdgeInsets.only(right: 10)),
                Text(shiftSplit[6], style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
              color: Color(int.parse(shiftSplit[2])),
            )
        );
      } else if (shiftSplit[0] == DateFormat('dd-MM-yyyy').format(DateTime.now().add(const Duration(days: 1)))){
        tomorrowList.add(
            TapToExpand(
              openedHeight: 205,
              borderRadius: 20,
              content: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.black.withOpacity(0.30),),
                    Padding(padding: EdgeInsets.only(left: 10)),
                    Text(shiftSplit[3], style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   ElevatedButton(onPressed: () async {
                      var userRef = await databaseReference.collection(shiftSplit[8]);
                      var dataRef = await databaseReference.collection(shiftSplit[8]).doc(shiftSplit[0]);
                      if (int.parse(shiftSplit[9]) != 0){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
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
                        ))); } else if (int.parse(shiftSplit[9]) == 0){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
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
                        )));
                      }
                    }, style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                        minimumSize: MaterialStateProperty.all(Size(150, 50)),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )
                        )),child: Text("Vagtdetaljer", style: TextStyle(fontSize: 16, color: Colors.black),)),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Expanded(child: IconButton(icon: const Icon(Icons.phone, color: Colors.white,), onPressed: (){launch("tel:" + shiftSplit[5]);},)),
                    Expanded(child: IconButton(icon: const Icon(Icons.message, color: Colors.white,), onPressed: (){launch("sms:" + shiftSplit[5]);},)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 20),)
              ],
            ), title: Row(
              children: [
                Icon(Icons.person, color: Colors.white),
                Padding(padding: EdgeInsets.only(right: 10)),
                Text(shiftSplit[6], style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
              color: Color(int.parse(shiftSplit[2])),
            )
        );
      }
    }

    if (sliderValue == 1){
      return todayList;
    } else if (sliderValue == 2){
      return tomorrowList;
    }
    return [];
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
            height: MediaQuery.of(context).size.height / 4.5,
              color: Colors.blue,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 12),
              child: const Center(
                  child: Text(
                    "Vikaroversigt",
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ))),
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
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 20),
                child: Text(
                  sliderValue == 1 ? DateFormat('dd-MM-yyyy').format(DateTime.now()) : DateFormat('dd-MM-yyyy').format(DateTime.now().add(Duration(days: 1))),
                  style: const TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 25, top: 20),
                child: CustomSlidingSegmentedControl(
                  onValueChanged: (value) {
                    setState(() {
                      sliderValue = int.parse(value.toString());
                    });
                  },
                  children: {
                    1: Text('I dag'),
                    2: Text('I morgen'),
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
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(top: 10),
              child: FutureBuilder(future: getUserInfo(), builder: (context, AsyncSnapshot<List> snapshot){
                IconButton button = IconButton(
                  onPressed: () {
                    setState((){});
                  },
                  color: Colors.blue, icon: Icon(Icons.refresh),
                );
                if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting){
                  return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                    color: Colors.blue,
                    size: 50,
                  ));
                } else if (snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(50),
                    child: const Center(child: Text(
                      "Ingen vikarer",
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),),
                  );
                }
                return ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 15, bottom: 5),
                          child: Text("Opdater", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)
                        ),
                        Spacer(),
                        Container(
                            padding: EdgeInsets.only(right: 10, bottom: 5),
                            child: button),
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index){
                          var shiftCard = snapshot.data?[index];
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                shiftCard
                              ],
                            ),
                          );
                        }
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
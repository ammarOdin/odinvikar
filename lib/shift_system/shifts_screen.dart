import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/card_assets.dart';
import 'package:odinvikar/shift_system/shift_details.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/date_week_extensions.dart';

import '../main_screens/dashboard.dart';
import '../main_screens/settings_screen.dart';


class ShiftScreen extends StatefulWidget {
  const ShiftScreen({Key? key}) : super(key: key);

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> with TickerProviderStateMixin {

  User? user = FirebaseAuth.instance.currentUser;
  get vagter => FirebaseFirestore.instance.collection("shifts").orderBy('date', descending: false);
  late String dropdownValue;
  late TabController _controller;

  void initState(){
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener((){
      setState(() {
      });
    });
    dropdownValue = getDropdownValue();
    super.initState();
  }


  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
  }

  String getDropdownValue(){
    if (DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday){
      var val = DateTime.now().weekOfYear + 1;
      return val.toString();
    } else {
      return DateTime.now().weekOfYear.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: kToolbarHeight + 2,
      ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(
                      color: Colors.blue
                  ),
                  child: Center(child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 22),))),
              ListTile(
                title: Text("Hjem"),
                leading: Icon(Icons.work_outline),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Dashboard()));
                },
              ),
              ListTile(
                title: Text("Vagtbanken", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ),),
                leading: Icon(Icons.work_outline),
                selected: true,
              ),
              ListTile(
                title: Text("Profil"),
                leading: Icon(Icons.account_box_outlined),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                },
              ),
            ],
          ),
        ),
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
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 12),
                    child: const Center(
                        child: Text(
                          "Vagter",
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                        ))),
              ],
            ),
          ),

          Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(labelColor: Colors.black, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue, controller: _controller, tabs: const [Tab(text: "Ledige vagter"), Tab(text: "Mine vagter",)])),

          Row(
            children: [
              Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.square_rounded, color: Colors.orange, size: 16,),
                  ),
                  Text(" Ledig", style: TextStyle(fontSize: 12),)
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

          /*Container(
            padding: EdgeInsets.only(left: 15, top: 10, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(child: Text("Uge  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),),
                DropdownButton<String>(
                  underline: Container(color: Colors.grey, height: 1,),
                  value: dropdownValue,
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });},
                  items: [for (var num = 0; num <= 52; num++) DropdownMenuItem(child: Text(num.toString()), value: num.toString())],
                  icon: Icon(Icons.keyboard_arrow_down), ),
                Spacer(),
                Container(
                  padding: EdgeInsets.only(right: 15),
                  child: Text(DateFormat('dd-MM').format(DateTime(DateTime.now().year, 1, 3, 0, 0).add(Duration(days: 7 * (int.parse(dropdownValue) - 1)))).toString()
                      + " til "
                      + DateFormat('dd-MM').format(DateTime(DateTime.now().year, 1, 3, 0, 0).add(Duration(days: 7 * (int.parse(dropdownValue) - 1) + 4))).toString()),
                ),
              ],
            ),
          ),*/

          const Divider(thickness: 1, height: 45,),

          Container(
            child: StreamBuilder(
                stream: vagter.snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData){
                    return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const CircularProgressIndicator.adaptive());
                  }else if (snapshot.data!.docs.isEmpty){
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
                        if (document['userID'] == user!.uid && _controller.index == 1 /*&& document['week'].toString() == dropdownValue.toString()*/){
                          return ShiftSystemCard(
                            icon: Icon(Icons.square_rounded,
                            color: Color(int.parse(document['color'])), size: 18,),
                            icon2: document['isAcute'] ? Icon(Icons.warning, color: Colors.red,) : Icon(Icons.warning, color: Colors.white,),
                            day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])),
                            text: document['date'],
                            time: document['time'],
                            onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftSystemDetailsScreen(
                              date: document['date'],
                              comment: document['comment'],
                              time: document['time'],
                              name: document['name'],
                              token: document['token'],
                              data: document.id,
                              status: document['status'],
                              awaitConfirmation: document['awaitConfirmation'],
                              acute: document['isAcute'],
                              color: document['color'] ,
                            )));
                          },);
                        } else if (document['awaitConfirmation'] != 2 /*&& document['week'] >= DateTime.now().weekOfYear*/ &&  _controller.index == 0 /*&& document['week'].toString() == dropdownValue.toString()*/){
                          return ShiftSystemCard(
                            icon: Icon(Icons.square_rounded, color: Color(int.parse(document['color'])), size: 18,),
                            icon2: document['isAcute'] ? Icon(Icons.warning, color: Colors.red,) : Icon(Icons.warning, color: Colors.white,),
                            day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])),
                            text: document['date'],
                            time: document['time'],
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftSystemDetailsScreen(
                                date: document['date'],
                                comment: document['comment'],
                                time: document['time'],
                                name: document['name'],
                                data: document.id,
                                status: document['status'],
                                awaitConfirmation: document['awaitConfirmation'],
                                acute: document['isAcute'],
                                color: document['color'] ,
                              )));
                            },);
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
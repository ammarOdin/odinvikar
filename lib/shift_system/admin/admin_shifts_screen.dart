import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:week_of_year/date_week_extensions.dart';
import '../../card_assets.dart';
import 'admin_add_shift.dart';
import 'admin_shift_system_details.dart';
import 'package:intl/intl.dart';


class AdminShiftsScreen extends StatefulWidget {
  const AdminShiftsScreen({Key? key}) : super(key: key);

  @override
  State<AdminShiftsScreen> createState() => _AdminShiftsScreenState();
}

class _AdminShiftsScreenState extends State<AdminShiftsScreen> with TickerProviderStateMixin {

  get vagter => FirebaseFirestore.instance.collection("shifts").orderBy('date', descending: false);
  late TabController _controller;
  final databaseReference = FirebaseFirestore.instance;
  late String dropdownValue;


  @override
  void initState(){
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener((){
      setState(() {
      });
    });
    dropdownValue = getDropdownValue();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getDropdownValue(){
    if (DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday){
      var val = DateTime.now().weekOfYear + 1;
      return val.toString();
    } else {
      return DateTime.now().weekOfYear.toString();
  }
}

  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
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
            height: MediaQuery.of(context).size.height / 3,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 20),
                    child: const Center(
                        child: Text(
                          "Vagtbanken",
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                        ))),
              ],
            ),
          ),

          Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(labelColor: Colors.black, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue, controller: _controller, tabs: const [Tab(text: "Ledige vagter"), Tab(text: "Bookede vagter",)])),

          Container(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.circle, color: Colors.orange, size: 16,),
                    ),
                    Text(" Ledig", style: TextStyle(fontSize: 12),)
                  ],
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.circle, color: Colors.red, size: 16,),
                    ),
                    Text(" Afventer accept", style: TextStyle(fontSize: 12),)
                  ],
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.circle, color: Colors.green, size: 16,),
                    ),
                    Text(" Godkendt vagt", style: TextStyle(fontSize: 12),)
                  ],
                ),
                Spacer(),
                IconButton(icon: Icon(Icons.add_circle, color: Colors.green, size: 30,), onPressed: () {
                  var weeknumber = int.parse(dropdownValue);
                  print("Start Date  " + DateTime(DateTime.now().year, 1, 3, 0, 0).add(Duration(days: 7 * (weeknumber - 1))).toString());
                  print("End Date  " + DateTime(DateTime.now().year, 1, 3, 0, 0).add(Duration(days: 7 * (weeknumber - 1) + 4)).toString());
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAddShiftScreen()));},)
              ],
            ),
          ),

          const Divider(thickness: 1, height: 5,),

          Container(
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
          ),

          Container(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: StreamBuilder(
                stream: vagter.snapshots() ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData){
                    return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitFoldingCube(color: Colors.blue,));
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
                      if (document["isTaken"] == true && _controller.index == 1 && document['week'].toString() == dropdownValue.toString()){
                        return ShiftSystemCard(
                          icon: Icon(Icons.circle,
                            color: Color(int.parse(document['color'])), size: 18,),
                          text: document['date'],
                          icon2: document['isAcute'] ? Icon(Icons.warning, color: Colors.red,) : Icon(Icons.warning, color: Colors.transparent,),
                          day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])),
                          time: document['time'],
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftSystemDetailsScreen(
                              userRef: FirebaseFirestore.instance.collection('user'),
                              date: document['date'],
                              token: document['token'],
                              name: document['name'],
                              time: document['time'],
                              acute: document['isAcute'],
                              data: document.id,
                              status: document['status'],
                              awaitConfirmation: document['awaitConfirmation'],
                              color: document['color'],
                              comment: document['comment'],
                            )));
                          },
                        );
                      } else if (document["isTaken"] == false && _controller.index == 0 && document['week'].toString() == dropdownValue.toString()) {
                        return ShiftSystemCard(
                          icon: Icon(Icons.circle, color: Color(int.parse(document['color'])), size: 18,),
                          text: document['date'],
                          day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])),
                          icon2: document['isAcute'] ? Icon(Icons.warning, color: Colors.red,) : Icon(Icons.warning, color: Colors.transparent,),
                          time: document['time'],
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftSystemDetailsScreen(
                              userRef: FirebaseFirestore.instance.collection('user'),
                              date: document['date'],
                              time: document['time'],
                              data: document.id,
                              status: document['status'],
                              acute: document['isAcute'],
                              awaitConfirmation: document['awaitConfirmation'],
                              color: document['color'],
                              comment: document['comment'],
                            )));
                          },
                        );
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

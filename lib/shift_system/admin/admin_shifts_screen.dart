import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  get vagter => FirebaseFirestore.instance.collection("shifts");
  late TabController _controller;
  final databaseReference = FirebaseFirestore.instance;

  @override
  void initState(){
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener((){
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

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                        "Vagter",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top:10),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.only(left: 20, ),
                child: const Text("Udbudte Vagter",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
              Spacer(),
              Container(
                child: IconButton(icon: Icon(Icons.add_circle, color: Colors.green, size: 30,), onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAddShiftScreen()));},) ,),
            ],
          ),
        ),
        const Divider(thickness: 1, height: 25,),

        Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(labelColor: Colors.black, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue, controller: _controller, tabs: const [Tab(text: "Ledige vagter"), Tab(text: "Bookede vagter",)])),


        StreamBuilder(
            stream: vagter.snapshots() ,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitFoldingCube(color: Colors.blue,));
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
                  if (document["isTaken"] == true && _controller.index == 1){
                    return AvailableShiftCard(icon: Icon(Icons.circle, color: Color(int.parse(document['color'])), size: 18,),text: document['date'], onPressed: () {
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
                    }, icon2: Icon(Icons.more_horiz), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])),);
                  } else if (document["isTaken"] == false && _controller.index == 0) {
                    return AvailableShiftCard(icon: Icon(Icons.circle, color: Color(int.parse(document['color'])), size: 18,),text: document['date'], onPressed: () {
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

                    }, day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), icon2: Icon(Icons.more_horiz),);
                  } else {
                    return Container();
                  }
                }).toList(),
              );

            }),
      ],
    );
  }
}

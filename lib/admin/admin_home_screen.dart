import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../card_assets.dart';


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminHomeScreen> with TickerProviderStateMixin {

  get users => FirebaseFirestore.instance.collection('user');
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
  late TabController _controller;

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

  Future<List> getNames() async {
    List<String> userID = [];
    List<String> userID2 = [];
    QuerySnapshot usersSnapshot = await usersRef.get();
    for (var users in usersSnapshot.docs){
      CollectionReference shiftRef = FirebaseFirestore.instance.collection(users.id);
      QuerySnapshot shiftSnapshot = await shiftRef.get();
      for (var shifts in shiftSnapshot.docs){
        if (shifts.id == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
          userID.add(shifts.get(FieldPath(const ['color']))+users.get(FieldPath(const ['phone']))+users.get(FieldPath(const ['name'])));
        } else if (shifts.id == DateFormat('dd-MM-yyyy').format(DateTime.now().add(const Duration(days: 1)))){
          userID2.add(shifts.get(FieldPath(const ['color']))+users.get(FieldPath(const ['phone']))+users.get(FieldPath(const ['name'])));
        }
      }
    }
    if (_controller.index == 0){
      return userID;
    } else if (_controller.index == 1){
      return userID2;
    }
    return [];
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
            children: [
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 30),
                  child: const Center(
                      child: Text(
                        "Vikar Oversigt",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
              Center(
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 40),
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  )
                ),
              ),
            ],
          ),
        ),
        Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(labelColor: Colors.black, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue, controller: _controller, tabs: const [Tab(text: "I dag",), Tab(text: "I Morgen",)])),

        Row(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.circle, color: Colors.orange, size: 16,),
                ),
                Text(" Tilgængelig", style: TextStyle(fontSize: 12),)
              ],
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.circle, color: Color(0xFF1167B1), size: 16,),
                ),
                Text(" Afventer Accept", style: TextStyle(fontSize: 12),)
              ],
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(Icons.circle, color: Colors.green, size: 16,),
                ),
                Text(" Godkendt Vagt", style: TextStyle(fontSize: 12),)
              ],
            ),
          ],
        ),

        const Divider(thickness: 1),


        Container(
          padding: EdgeInsets.only(top: 10),
          child: FutureBuilder(future: getNames(), builder: (context, AsyncSnapshot<List> snapshot){
            if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting){
              return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const CircularProgressIndicator.adaptive());
            } else if (snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(50),
                child: const Center(child: Text(
                  "Ingen Vikarer",
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),),
              );
            }
            return Column(children: snapshot.data!.map<Widget>((e) => AvailableShiftCard(text: e.substring(18), icon:Icon(Icons.circle, color: Color(int.parse(e.substring(0,10))), size: 20,), subtitle: "Se mere", onPressed: () {
              showDialog(context: context, builder: (BuildContext context){
                return SimpleDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), title: Center(child: Text("Kontakt - " + e.substring(18)),), children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("Opkald") , icon: const Icon(Icons.phone), onPressed: (){launch("tel://" + e.substring(10,18));},), ),),
                      SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("SMS") , icon: const Icon(Icons.message), onPressed: (){launch("sms:" + e.substring(10,18));},), ),),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text("Naviger til kalendersiden for yderligere info."
                        ""),
                  ),
                ],);
              });
              }),
            ).toList());
          }),
        ),
      ],
    );
  }
}


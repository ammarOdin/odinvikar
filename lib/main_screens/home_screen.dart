import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:week_of_year/week_of_year.dart';

import '../card_assets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<HomeScreen> with TickerProviderStateMixin {

  User? user = FirebaseAuth.instance.currentUser;
  get shift => FirebaseFirestore.instance.collection(user!.uid).orderBy('month', descending: false).orderBy('date', descending: false);
  get unsortedShift => FirebaseFirestore.instance.collection(user!.uid).orderBy('month', descending: false);
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
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 30),
                  child: const Center(
                      child: Text(
                        "Dine Dage",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 40),
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
        StreamBuilder(
            stream: unsortedShift.snapshots() ,
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
              if (_controller.index == 0){
                return Column(
                  children: snapshot.data!.docs.map((document){
                    if (document['week'] == DateTime.now().weekOfYear) {
                      return AvailableShiftCard(icon: Icon(Icons.circle, color: Color(int.parse(document['color'])), size: 20,), text: document['date'], subtitle: " Se Mere", onPressed: () {
                        showDialog(context: context, builder: (BuildContext context){
                          return AlertDialog(title: Text("Dato: " + document['date']),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            content: Text("Kan arbejde: " + document['time'] + "\n\nKommentar: " + document['comment'] + "\n\nStatus: " + document['status']),
                            actions: [TextButton(onPressed: () {Navigator.pop(context);}
                                , child: const Text("OK"))],);});
                      });
                    } else {
                      return Container();
                    }
                  }).toList(),
                );
              } else if (_controller.index == 1){
                return Column(
                  children: snapshot.data!.docs.map((document){
                    var docDate = DateFormat('dd-MM-yyyy').parse(document['date']).add(const Duration(days: 1));
                    if (document['month'] == DateTime.now().month && DateTime.now().isBefore(docDate)) {
                      return AvailableShiftCard(icon: Icon(Icons.circle, color: Color(int.parse(document['color'])), size: 20,), text: document['date'], subtitle: " Se Mere", onPressed: () {
                        showDialog(context: context, builder: (BuildContext context){
                          return AlertDialog(title: Text("Dato: " + document['date']),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            content: document['isAccepted'] == true ? Text("Kan arbejde: " + document['time'] + "\n\nEgen kommentar: " + document['comment'] + "\n\nStatus: " + document['status']+ "\nDetaljer: " + document['details']) :
                            Text("Kan arbejde: " + document['time'] + "\n\nEgen kommentar: " + document['comment'] + "\n\nStatus: " + document['status'] + "\n\nHvis du ikke er tildelt en vagt, kan du stadig blive kontakt på dagen."),
                            actions: [TextButton(onPressed: () {Navigator.pop(context);}
                                , child: const Text("OK"))],);});

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
      ],
    );
  }
}




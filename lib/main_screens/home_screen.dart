import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:week_of_year/week_of_year.dart';

import '../card_assets.dart';
import 'edit_shift_screen.dart';

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

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
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
                        "Dine dage",
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
        Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(labelColor: Colors.black, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue, controller: _controller, tabs: const [Tab(text: "Måned"), Tab(text: "Uge",)])),

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
          ],
        ),

        const Divider(thickness: 1),

        if (_controller.index == 0) Container(
            padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
            child: Text(months[DateTime.now().month.toInt() - 1], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
        if (_controller.index == 1) Container(
            padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
            child: Text("Uge " + DateTime.now().weekOfYear.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),

        Container(
          padding: EdgeInsets.only(top: 10),
          child: StreamBuilder(
              stream: unsortedShift.snapshots() ,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if (!snapshot.hasData){
                  return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitCubeGrid(
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
                if (_controller.index == 1){
                  return Column(
                    children: snapshot.data!.docs.map((document){
                      if (document['week'] == DateTime.now().weekOfYear) {
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (BuildContext context) {
                                  if (document['awaitConfirmation'] == 1 || document['awaitConfirmation'] == 2){
                                    showDialog(context: context, builder: (BuildContext context){return AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      title: Text("Slet dag"),
                                      content: const Text("En vagt er tildelt på dagen. Du kan ikke slette den."),
                                      actions: [
                                        TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")) ,
                                      ],
                                    );});
                                  } else {
                                    showDialog(context: context, builder: (BuildContext context){return AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      title: Text("Slet dag"),
                                      content: const Text("Er du sikker på at slette dagen?"),
                                      actions: [
                                        TextButton(onPressed: () {
                                          document.reference.delete();
                                          Navigator.pop(context);
                                          _showSnackBar(context, "Vagt slettet", Colors.green);}, child: const Text("Slet")),
                                        TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Annuller")),
                                      ],
                                    );});
                                  }
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Slet',
                              ),
                              SlidableAction(
                                onPressed: (BuildContext context) {
                                  if (document['awaitConfirmation'] == 1 || document['awaitConfirmation'] == 2){
                                    showDialog(context: context, builder: (BuildContext context){return AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      title: Text("Rediger dag"),
                                      content: const Text("En vagt er tildelt på dagen. Du kan ikke redigere den."),
                                      actions: [
                                        TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")) ,
                                      ],
                                    );});
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditShiftScreen(date: document['date'], userRef: FirebaseFirestore.instance.collection(user!.uid), details: document['time']))).then((value) {setState(() {
                                    });});
                                  }
                                },
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Rediger',
                              ),
                            ],
                          ),
                          child: AvailableShiftCard(icon: Icon(Icons.circle, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(title: Center(child: Text("Dato: " + document['date'])),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                content: document['isAccepted'] == true ?
                                Text("Status: " + document['status']+ "\n\nTidsrum: " + document['details'] + "\n\nEgen kommentar: " + document['comment']) :
                                Text("\n\nStatus: " + document['status'] + "\n\nKan arbejde: " + document['time'] + "\n\nEgen kommentar: " + document['comment'] + "\n\nHvis du ikke er tildelt en vagt, kan du stadig blive kontaktet på dagen."),
                                actions: [TextButton(onPressed: () {Navigator.pop(context);}
                                    , child: const Text("OK"))],);});
                          }),
                        );
                      } else {
                        return Container();
                      }
                    }).toList(),
                  );
                } else if (_controller.index == 0){
                  return Column(
                    children: snapshot.data!.docs.map((document){
                      var docDate = DateFormat('dd-MM-yyyy').parse(document['date']).add(const Duration(days: 1));
                      if (document['month'] == DateTime.now().month && DateTime.now().isBefore(docDate)) {
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (BuildContext context) {
                                  if (document['awaitConfirmation'] == 1 || document['awaitConfirmation'] == 2){
                                    showDialog(context: context, builder: (BuildContext context){return AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      title: Text("Slet dag"),
                                      content: const Text("En vagt er tildelt på dagen. Du kan ikke slette den."),
                                      actions: [
                                        TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")) ,
                                      ],
                                    );});
                                  } else {
                                    showDialog(context: context, builder: (BuildContext context){return AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      title: Text("Slet dag"),
                                      content: const Text("Er du sikker på at slette dagen?"),
                                      actions: [
                                        TextButton(onPressed: () {
                                          document.reference.delete();
                                          Navigator.pop(context);
                                          _showSnackBar(context, "Vagt slettet", Colors.green);}, child: const Text("Slet")),
                                        TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Annuller")),
                                      ],
                                    );});
                                  }
                                  },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Slet',
                              ),
                              SlidableAction(
                                onPressed: (BuildContext context) {
                                  if (document['awaitConfirmation'] == 1 || document['awaitConfirmation'] == 2){
                                    showDialog(context: context, builder: (BuildContext context){return AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      title: Text("Rediger dag"),
                                      content: const Text("En vagt er tildelt på dagen. Du kan ikke redigere den."),
                                      actions: [
                                        TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")) ,
                                      ],
                                    );});
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditShiftScreen(date: document['date'], userRef: FirebaseFirestore.instance.collection(user!.uid), details: document['time']))).then((value) {setState(() {
                                    });});
                                  }
                                  },
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Rediger',
                              ),
                            ],
                          ),
                          child: AvailableShiftCard(icon: Icon(Icons.circle, color: Color(int.parse(document['color'])), size: 18,), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'].substring(0,5), icon2: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20,), onPressed: () {
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(title: Center(child: Text("Dato: " + document['date'])),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                content: document['isAccepted'] == true ?
                                Text("Status: " + document['status']+ "\n\nTidsrum: " + document['details'] + "\n\nEgen kommentar: " + document['comment']) :
                                Text("\n\nStatus: " + document['status'] + "\n\nKan arbejde: " + document['time'] + "\n\nEgen kommentar: " + document['comment'] + "\n\nHvis du ikke er tildelt en vagt, kan du stadig blive kontaktet på dagen."),
                                actions: [TextButton(onPressed: () {Navigator.pop(context);}
                                    , child: const Text("OK"))],);});
                          }),
                        );
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
    );
  }
}




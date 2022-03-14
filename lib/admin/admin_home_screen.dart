import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odinvikar/main_screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';


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
          userID.add(users.get(FieldPath(const ['phone']))+users.get(FieldPath(const ['name'])));
        } else if (shifts.id == DateFormat('dd-MM-yyyy').format(DateTime.now().add(const Duration(days: 1)))){
          userID2.add(users.get(FieldPath(const ['phone']))+users.get(FieldPath(const ['name'])));
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

        FutureBuilder(future: getNames(), builder: (context, AsyncSnapshot<List> snapshot){
          if (!snapshot.hasData){
            return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const CircularProgressIndicator.adaptive());
          } else if (snapshot.data!.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(50),
              child: const Center(child: Text(
                "Ingen Vikarer",
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting){
            return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const CircularProgressIndicator.adaptive());
          }
          return Column(children: snapshot.data!.map<Widget>((e) => CardFb2(text: e.substring(8), imageUrl: "assets/aula-logo.jpg", subtitle: "Kontakt", onPressed: () {
            showDialog(context: context, builder: (BuildContext context){
              return SimpleDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), title: Center(child: Text("Kontakt - " + e.substring(8)),), children: [
                SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("Opkald") , icon: const Icon(Icons.phone), onPressed: (){launch("tel://" + e.substring(0,8));},), ),),
                SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("SMS") , icon: const Icon(Icons.message), onPressed: (){launch("sms:" + e.substring(0,8));},), ),),
              ],);
            });
            }),
          ).toList());
        }),
      ],
    );
  }
}


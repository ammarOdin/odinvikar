import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../card_assets.dart';

class ShiftBankScreen extends StatefulWidget {
  const ShiftBankScreen({Key? key}) : super(key: key);

  @override
  State<ShiftBankScreen> createState() => _ShiftBankScreenState();
}

class _ShiftBankScreenState extends State<ShiftBankScreen> {

  @override
  void initState() {
    super.initState();
  }

  User? user = FirebaseAuth.instance.currentUser;
  get vagter => FirebaseFirestore.instance.collection("shifts");

  final CollectionReference vagterRef = FirebaseFirestore.instance.collection("shifts");
  final CollectionReference userInfo = FirebaseFirestore.instance.collection('user');



  String? getName()  {
    String name = "";
    var userInfo = FirebaseFirestore.instance.collection('user').doc(user!.uid);
    userInfo.get().then((value) {
      name = value['name'];
      return name;
    });
    if (kDebugMode){
      print(name);
    }
  }

  Future<String> getUser() async {
    String name = "";
    QuerySnapshot usersSnapshot = await userInfo.get();
    for (var users in usersSnapshot.docs){
      if(users.id == user!.uid){
        name = users.get(FieldPath(const['name']));
      }
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: kToolbarHeight + 2,
        leading: const BackButton(color: Colors.white,),
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: const Text("Ledige Vagter",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
          const Divider(thickness: 1, height: 25,),

          StreamBuilder(
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
                    if (document['isTaken'] == false){
                      return FutureBuilder(future: getUser(), builder: (context, AsyncSnapshot<String> snapshot){
                        return AvailableShiftCard(icon: Icon(Icons.circle, color: Colors.green, size: 20,), text: "Ledig: " + document['date'], onPressed: () {
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(
                              title: Text("Vagt Detaljer: " + document['date']),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              content: Text("Tid: " + document['time'] + "\n\nKommentar: " + document['comment']),
                              actions: [TextButton(onPressed: () {
                                showDialog(context: context, builder: (BuildContext context){
                                  return AlertDialog(
                                    title: Text("Vagt Detaljer: " + document['date']),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    content: Text("Er du sikker på at tage vagten? Fortryder du, skal du kontakte din leder."),
                                    actions: [TextButton(onPressed: () async {
                                      // assign shift to user
                                      await vagterRef.doc(document.id).update({"isTaken": true, "userID": user!.uid, "name": document['name']});
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }, child: const Text("OK"))],);});
                              }, child: const Text("Tag Vagt"))],);});
                        }, icon2: Icon(Icons.more_horiz), day: 'Test',);
                      });
                    } else {
                      return Container();
                    }

                  }).toList(),
                );

              }),
       /*   ElevatedButton(onPressed: () async {
            await getUser();
          }, child: Text("test")),*/
        ],
      ),
    );
  }
}

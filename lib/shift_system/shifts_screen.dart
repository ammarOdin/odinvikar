import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/card_assets.dart';
import 'package:odinvikar/shift_system/shifts_bank.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({Key? key}) : super(key: key);

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  get vagter => FirebaseFirestore.instance.collection("shifts");


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
                  child: const Text("Mine Vagter",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
                Spacer(),
                Container(
                  child: IconButton(icon: Icon(Icons.work_outline, color: Colors.blue,), onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftBankScreen()));},) ,),
              ],
            ),
          ),
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
                      if (document['userID'] == user!.uid){
                        return ShiftCard(text: document['date'], subtitle: "Detaljer", onPressed: () {

                        });
                      } else {
                        return Container();
                      }
                    }).toList(),
                  );

              }),
        ],
      ),
    );

  }
}
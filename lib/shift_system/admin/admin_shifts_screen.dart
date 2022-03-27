import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/shift_system/admin/admin_add_shift.dart';

import '../../card_assets.dart';

class AdminShiftsScreen extends StatefulWidget {
  const AdminShiftsScreen({Key? key}) : super(key: key);

  @override
  State<AdminShiftsScreen> createState() => _AdminShiftsScreenState();
}

class _AdminShiftsScreenState extends State<AdminShiftsScreen> {

  get vagter => FirebaseFirestore.instance.collection("shifts");

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
                child: IconButton(icon: Icon(Icons.add_circle, color: Colors.blue,), onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAddShiftScreen()));},) ,),
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
                  if (document["isTaken"] == true){
                    return AvailableShiftCard(icon: Icon(Icons.circle, color: Colors.red, size: 20,),text: document['date'], subtitle: "Detaljer", onPressed: () {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Vagt Detaljer: " + document['date']),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          content: Text("Tid: " + document['time'] + "\n\nKommentar: " + document['comment'] + "\n\nTaget af: " + document['name']),
                          actions: [
                            TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")),
                            TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("SLET", style: TextStyle(color: Colors.red),))
                          ],);});
                    });
                  } else if (document["isTaken"] == false) {
                    return AvailableShiftCard(icon: Icon(Icons.circle, color: Colors.green, size: 20,),text: document['date'], subtitle: "Detaljer", onPressed: () {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Vagt Detaljer: " + document['date']),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          content: Text("Tid: " + document['time'] + "\n\nKommentar: " + document['comment']),
                          actions: [
                            TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")),
                            TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("SLET", style: TextStyle(color: Colors.red),))
                          ],);});
                    });
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
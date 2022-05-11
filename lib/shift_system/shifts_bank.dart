import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odinvikar/shift_system/shift_details.dart';
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
  get vagter => FirebaseFirestore.instance.collection("shifts").orderBy('date', descending: false);

  final CollectionReference vagterRef = FirebaseFirestore.instance.collection("shifts");
  final CollectionReference userInfo = FirebaseFirestore.instance.collection('user');

  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: kToolbarHeight + 2,
        title: Text("Ledige vagter"),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white,),),
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
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
                      if (document['awaitConfirmation'] != 2){
                        return AvailableShiftCard(icon: Icon(Icons.circle, color: Color(int.parse(document['color'])), size: 18,), icon2: Icon(Icons.more_horiz), day: getDayOfWeek(DateFormat('dd-MM-yyyy').parse(document['date'])), text: document['date'], onPressed: (){
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

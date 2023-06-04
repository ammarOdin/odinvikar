import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({super.key});

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  get getUserInfo => FirebaseFirestore.instance.collection('user').doc(user!.uid);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: false,
        backgroundColor: Colors.blue,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Text("Kontaktoplysninger",  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 18,),),
      ),
      body: ListView(
        shrinkWrap: true,
        primary: false,
        children: [
          Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 30), child: const Center(child: Text("Mine Oplysninger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),),
          Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 15, left: 10), child: Align(alignment: Alignment.centerLeft, child: Row(
            children: [
              const Text("Telefonnummer: ", style: TextStyle(fontWeight: FontWeight.bold),),
              StreamBuilder(
                  stream: getUserInfo.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData){
                      var name = snapshot.data as DocumentSnapshot;
                      return Center(
                          child: Text(name['phone'].toString(), style: const TextStyle(color: Colors.black),));
                    }
                    return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                      color: Colors.blue,
                      size: 50,
                    )));
                  }
              ),
            ],
          ),),),
          Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, left: 10), child: Align(alignment: Alignment.centerLeft, child: Row(
            children: [
              const Text("E-mail: ", style: TextStyle(fontWeight: FontWeight.bold),),
              StreamBuilder(
                  stream: getUserInfo.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData){
                      var name = snapshot.data as DocumentSnapshot;
                      return Center(
                          child: Text(name['email'].toString(), style: const TextStyle(color: Colors.black),));
                    }
                    return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                      color: Colors.blue,
                      size: 50,
                    )));
                  }
              ),
            ],
          ),),),
          Container(padding: const EdgeInsets.all(10),),
        ],
      ),
    );
  }
}

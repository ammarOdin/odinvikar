import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/login.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SettingsScreen> {

  get getUserInfo => FirebaseFirestore.instance.collection('user');


  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 0),
      children: [
        Container(
          color: Colors.blue,
          margin: const EdgeInsets.only(bottom: 10),
          height: MediaQuery
              .of(context)
              .size
              .height / 3,
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .size
                        .height / 30),
                child: const Center(
                    child: Text(
                      "Profil",
                      style: TextStyle(color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .size
                        .height / 30),
                child: Center(
                    child: StreamBuilder(
                        stream: getUserInfo.snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData){
                            return const Center(child: CircularProgressIndicator(),);
                          } else if (snapshot.data!.docs.isEmpty){
                            return const Center(child: Text(
                              "Ukendt",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),);
                          } else {return Center(
                              child: snapshot.data!.docs.map((document){
                                return Text(
                                  document['name'],
                                  style: const TextStyle(color: Colors.white, fontSize: 26),
                                );
                              }).first);}
                        }
                    ),),
              ),
            ],
          ),
        ),
        Container(padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20),
          child: const Text("Indstillinger",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {showContactInfo();}, icon: const Icon(Icons.contact_page, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Kontaktoplysninger", style: TextStyle(color: Colors.white),)),),),

        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Log ud"), content: const Text("Er du sikker på at logge ud?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {Navigator.pop(context); await FirebaseAuth.instance.signOut(); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));}, child: const Text("Log ud"))],);});}, icon: const Icon(Icons.logout, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Log ud", style: TextStyle(color: Colors.white),)),),),



      ],
    );

  }
  Future showContactInfo () => showSlidingBottomSheet(
    context,
    builder: (context) => SlidingSheetDialog(
      duration: const Duration(milliseconds: 450),
      snapSpec: const SnapSpec(
          snappings: [0.4, 0.7, 1], initialSnap: 0.4
      ),
      builder: showContact,
      /////headerBuilder: buildHeader,
      avoidStatusBar: true,
      cornerRadius: 15,
    ),
  );

  Widget buildHeader(BuildContext context, SheetState state) => Material(child: Stack(children: <Widget>[Container(height: MediaQuery.of(context).size.height / 3 , color: Colors.blue,),Positioned(bottom: 20, child: SizedBox(width: MediaQuery.of(context).size.width, height: 40, child: Image.network("https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", height: 59, fit: BoxFit.contain)))],),);

  Widget showContact(context, state) => Material(
    child: ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 30), child: const Center(child: Text("Kontaktoplysninger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),),
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 15, left: 10), child: Align(alignment: Alignment.centerLeft, child: Row(
          children: [
            const Text("Telefonnummer: ", style: TextStyle(fontWeight: FontWeight.bold),),
            StreamBuilder(
                stream: getUserInfo.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData){
                    return const Center(child: CircularProgressIndicator(),);
                  } else if (snapshot.data!.docs.isEmpty){
                    return const Center(child: Text(
                      "Ukendt",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),);
                  } else {return Center(
                      child: snapshot.data!.docs.map((document){
                        return Text(
                          document['phone'],
                          style: const TextStyle(color: Colors.black),
                        );
                      }).first);}
                }
            ),
          ],
        ),),),
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, left: 10), child: Align(alignment: Alignment.centerLeft, child: Row(
          children: [
            const Text("E-mail: ", style: TextStyle(fontWeight: FontWeight.bold),),
            StreamBuilder(
                stream: getUserInfo.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData){
                    return const Center(child: CircularProgressIndicator(),);
                  } else if (snapshot.data!.docs.isEmpty){
                    return const Center(child: Text(
                      "Ukendt",
                      style: TextStyle(color: Colors.black),
                    ),);
                  } else {return Center(
                      child: snapshot.data!.docs.map((document){
                        return Text(
                          document['email'],
                          style: const TextStyle(color: Colors.black),
                        );
                      }).first);}
                }
            ),
          ],
        ),),),
        Container(padding: const EdgeInsets.all(10),),
        //Container(margin: const EdgeInsets.only(left: 10, right: 10), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 1)), onPressed: () => Navigator.of(context).pop(), child: const Text("Close")))
      ],
    ),
  );
}


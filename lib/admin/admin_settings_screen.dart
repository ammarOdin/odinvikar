import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/login.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminSettingsScreen> {

  get getUserInfo => FirebaseFirestore.instance.collection('user').doc(user!.uid);
  User? user = FirebaseAuth.instance.currentUser;

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

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
                      "Administrator Profil",
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
                        builder: (context, snapshot) {
                          if (snapshot.hasData){
                            var name = snapshot.data as DocumentSnapshot;
                            return Center(
                                child: Text(name['name'].toString(), style: const TextStyle(color: Colors.white, fontSize: 22),));
                          }
                          return const CircularProgressIndicator.adaptive();
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
          child: ElevatedButton.icon(onPressed: () {showContactInfo();}, icon: const Icon(Icons.contact_page, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Mine Oplysninger", style: TextStyle(color: Colors.white),)),),),

        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.supervised_user_circle, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Vikarer", style: TextStyle(color: Colors.white),)),),),


        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Log ud"), content: const Text("Er du sikker på at logge ud?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {Navigator.pop(context); await FirebaseAuth.instance.signOut(); _showSnackBar(context, "Logget Ud", Colors.grey); Future.delayed(const Duration(seconds: 2)); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));}, child: const Text("Log Ud"))],);});}, icon: const Icon(Icons.logout, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Log Ud", style: TextStyle(color: Colors.white),)),),),



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
                  return const CircularProgressIndicator.adaptive();
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
                  return const CircularProgressIndicator.adaptive();
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


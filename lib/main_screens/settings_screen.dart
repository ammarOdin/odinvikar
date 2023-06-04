import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:odinvikar/auth/login.dart';
import 'package:odinvikar/main_screens/contact_info_screen.dart';
import 'package:odinvikar/main_screens/shift_history.dart';
import 'package:odinvikar/main_screens/shiftinfo_sync.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SettingsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  get getUserInfo => FirebaseFirestore.instance.collection('user').doc(user!.uid);
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
  final feedbackReference = FirebaseFirestore.instance.collection("feedback");

  final feedbackController = TextEditingController();

  bool isSynced = false;
  bool loading = true;

  @override
  initState(){
    super.initState();
    _getSyncStatus();
  }

  String? validateFeedbackField(String? input){
    if (input == null || input.isEmpty){
      return "Feltet må ikke være tomt";
    } else if (!input.contains(new RegExp(r'^[a-zA-Z0-9,. !?+-]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    }
  }

  _getSyncStatus() {
    FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      setState((){
        value['isSynced'] == true ? isSynced = true : null;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: false,
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Velkommen', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),),
            Padding(padding: EdgeInsets.only(top: 10)),
            StreamBuilder(
                stream: getUserInfo.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    var name = snapshot.data as DocumentSnapshot;
                    return Text(name['name'].toString(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),);
                  }
                  return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                    color: Colors.blue,
                    size: 50,
                  )));
                }
            ),
          ],
        ),
        toolbarHeight: 125,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: IconButton(onPressed: (){
        showAboutDialog(
          context: context,
          applicationIcon: Image.asset("assets/icon_android.png", fit: BoxFit.contain,),
          applicationName: 'Vikarly',
          applicationVersion: '2.5.2',
          applicationLegalese: 'vikarly.dk',
          children: [
            Padding(padding: EdgeInsets.only(top: 20),),
            Text("Udviklet af WebFinity. Alle rettigheder forbeholdt.")
          ]
        );
      }, icon: Icon(Icons.info_outline, color: Colors.blue,),),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: loading? Center(
        child: SpinKitRing(
          size: 50,
          color: Colors.blue,
        ),
      ) :
      ListView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 15, top: 20, bottom: 20),
              child: Text("Profilindstillinger",
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),)),
          GestureDetector(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserContactInfoScreen()));
            },
            child: Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              decoration: BoxDecoration(
              ),
              child:  Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Text("Personlige oplysninger", style: TextStyle(fontWeight: FontWeight.w500 ),)),
                      const Spacer(),
                      Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.arrow_forward_ios, size: 20,))
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftHistoryScreen()));
            },
            child: Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              decoration: BoxDecoration(
              ),
              child:  Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Text("Mine timer", style: TextStyle(fontWeight: FontWeight.w500 ),)),
                      const Spacer(),
                      Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.arrow_forward_ios, size: 20,))
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftInfoSyncScreen()));
              },
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                decoration: BoxDecoration(
                ),
                child:  Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Text("Vagtsynkronisering", style: TextStyle(fontWeight: FontWeight.w500 ),)),
                        Padding(padding: EdgeInsets.only(left: 10)),
                        isSynced? Icon(Icons.check, color: Colors.green, size: 24,) : Icon(Icons.error, color: Colors.red, size: 24,),
                        const Spacer(),
                        Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.arrow_forward_ios, size: 20,))
                      ],
                    ),
                  ],
                ),
              ),
            ),

          Padding(padding: EdgeInsets.only(top: 70),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                try{
                  Dialogs.bottomMaterialDialog(
                      msg: "Du er ved at logge ud",
                      title: 'Log ud',
                      context: context,
                      actions: [
                        IconsOutlineButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          text: 'Annuller',
                          iconData: Icons.cancel_outlined,
                          textStyle: TextStyle(color: Colors.grey),
                          iconColor: Colors.grey,
                        ),
                        IconsButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },
                          text: 'Log ud',
                          iconData: Icons.logout,
                          color: Colors.black.withOpacity(0.5),
                          textStyle: TextStyle(color: Colors.white),
                          iconColor: Colors.white,
                        ),
                      ]);
                } on FirebaseAuthException catch (e){
                  Flushbar(
                      margin: EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(10),
                      title: 'Log ud',
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                      message: 'Kunne ikke udføre handlingen. Prøv igen',
                      flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                }
              },
                child: Text("Log ud", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black)),
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(130, 50)),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    elevation: MaterialStateProperty.all(3),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                ),),
            ],
          ),
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text("Appversion: 2.5.2",
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),)),
        ],
      ),
    );
  }
}
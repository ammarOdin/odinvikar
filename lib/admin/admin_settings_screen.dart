import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/admin/admin_dashboard.dart';
import 'package:odinvikar/admin/admin_users_screen.dart';
import 'package:odinvikar/auth/login.dart';
import 'package:odinvikar/shift_system/admin/admin_shifts_screen.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:validators/validators.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'admin_home_screen.dart';
import 'admin_total_hours.dart';
import 'generate_pdf_invoice.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminSettingsScreen> {

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
  get getUserInfo => FirebaseFirestore.instance.collection('user').doc(user!.uid);
  final feedbackReference = FirebaseFirestore.instance.collection("feedback");
  User? user = FirebaseAuth.instance.currentUser;


  final GlobalKey<FormState> _feedbackKey = GlobalKey<FormState>();
  final feedbackController = TextEditingController();

  @override
  void  initState() {
    super.initState();
    setState(() {
    });
  }

  String? validateFeedbackField(String? input){
    if (input == null || input.isEmpty){
      return "Feltet må ikke være tomt";
    } else if (!input.contains(new RegExp(r'^[a-zA-Z0-9,. !?+-]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: kToolbarHeight + 2,
        //iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
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
                          .height / 10),
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
                          builder: (context, snapshot) {
                            if (snapshot.hasData){
                              var name = snapshot.data as DocumentSnapshot;
                              return Center(
                                  child: Text(name['name'].toString(), style: const TextStyle(color: Colors.white, fontSize: 22),));
                            }
                            return SpinKitRing(
                              color: Colors.blue,
                              size: 50,
                            );
                          }
                      ),),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(padding: const EdgeInsets.only(left: 20),
                child: const Text("Indstillinger",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
              const Spacer(),
              Container(
                child: IconButton(onPressed: () {
                  showDialog(context: context, builder: (BuildContext context){
                    return Form(
                      key: _feedbackKey,
                      child: AlertDialog(title: const Text("Feedback"),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        content: const Text("Er der fejl eller mangler? Eller har du forslag til forbedringer? Brug nedenstående felt."),
                        actions: [
                          TextFormField(validator: validateFeedbackField, controller: feedbackController, decoration: const InputDecoration(icon: Icon(Icons.feedback), hintText: "Besked"),),
                          TextButton(onPressed: () async {
                            if (_feedbackKey.currentState!.validate()){
                              try {
                                feedbackReference.doc().set({'message': feedbackController.text});
                                Navigator.pop(context);
                                showTopSnackBar(
                                  context,
                                  CustomSnackBar.info(
                                    message:
                                    "Feedback afsendt",
                                  ),
                                );
                              } catch (e) {
                                showTopSnackBar(
                                  context,
                                  CustomSnackBar.error(
                                    message:
                                    "Kunne ikke sende meddelelse. Prøv igen",
                                  ),
                                );
                              }
                            }

                          }, child: const Text("Send"))
                        ],),
                    );
                  });} , icon: const Icon(Icons.feedback_outlined, color: Colors.blue,)),),
              Container(
                child: IconButton(onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminTotalHours()));
                } , icon: const Icon(Icons.access_time_outlined, color: Colors.blue,)),),

            ],
          ),
          const Divider(thickness: 1, height: 15),

          Container(
            height: 50,
            width: 150,
            margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 20),
            //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
            child: ElevatedButton.icon(onPressed: () {showContactInfo();}, icon: const Icon(Icons.contact_page, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Mine oplysninger", style: TextStyle(color: Colors.white),)),style: ButtonStyle(shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.blue)
                )
            )),),),

          Container(
            height: 50,
            width: 150,
            margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
            //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
            child: ElevatedButton.icon(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => AdminUsersScreen())); /*FirebaseMessaging.instance.getToken().then((value) {if (kDebugMode){print(value);}});*/}, icon: const Icon(Icons.supervised_user_circle, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Brugere", style: TextStyle(color: Colors.white),)), style: ButtonStyle(shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.blue)
                )
            )),),),


          Container(
            height: 50,
            width: 150,
            margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
            //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
            child: ElevatedButton.icon(onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Log ud"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), content: const Text("Er du sikker på at logge ud?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {Navigator.pop(context); await FirebaseAuth.instance.signOut(); showTopSnackBar(
              context,
              CustomSnackBar.success(
                message:
                "Logget ud",
              ),
            ); Future.delayed(const Duration(seconds: 2)); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));}, child: const Text("Log ud"))],);});}, icon: const Icon(Icons.logout, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Log ud", style: TextStyle(color: Colors.white),)), style: ButtonStyle(shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.blue)
                )
            )),),),
        ],
      ),
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


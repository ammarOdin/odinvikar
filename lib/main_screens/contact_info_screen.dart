import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:validators/validators.dart';

import 'authenticate_email_screen.dart';

class UserContactInfoScreen extends StatefulWidget {
  const UserContactInfoScreen({super.key});

  @override
  State<UserContactInfoScreen> createState() => _UserContactInfoScreenState();
}

class _UserContactInfoScreenState extends State<UserContactInfoScreen> {
  final GlobalKey<FormState> _updateInfokey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
  get getUserInfo => FirebaseFirestore.instance.collection('user').doc(user!.uid);



  final emailController = TextEditingController();
  final updatedEmailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? validatePassword(String? password){
    if (password == null || password.isEmpty){
      return "Indsæt password";
    }
  }

  String? validateEmail(String? email){
    if (email == null || email.isEmpty){
      return "Indsæt e-mail";
    } else if (!email.contains("@") || !email.contains(".")){
      return "Ugyldig e-mail";
    }
  }

  String? validateUpdateField(String reference , String? input){
    switch(reference){
      case "phone": {
        if (isNumeric(input!) == false || input == "" || input.isEmpty){
          return "Telefon skal kun indeholde numre!";
        } else if (input.length < 8 || input.length > 8){
          return "Nummeret skal være 8 cifre langt!";
        }
      }
      break;
      case "email": {
        if (input == null || input.isEmpty){
          return "Indsæt e-mail";
        } else if (!input.contains("@") || !input.contains(".")){
          return "Ugyldig e-mail";
        }
      }
      break;
    }
  }

  updateUserField(String uid, String reference, String field, TextEditingController controller) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10, left: 10, top: 5,bottom: 5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.8),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                Scaffold(resizeToAvoidBottomInset: false, appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const BackButton(color: Colors.black),
                ),
                  body: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _updateInfokey,
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(top: 50, left: 15, right: 20),
                            child: Align(
                              alignment: Alignment.center,
                              child: TextFormField(
                                  validator: (input) => validateUpdateField(reference, controller.text),
                                  controller: controller,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.edit,
                                      color: Colors.grey.withOpacity(0.75),
                                    ),
                                    fillColor: Colors.grey.withOpacity(0.25),
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(15)),
                                    labelText: 'Rediger',
                                    labelStyle: TextStyle(color: Colors.black),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(15)),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    hintText: "Indtast nye oplysninger",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  )) ,)),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
                          child: ElevatedButton.icon(onPressed: () async {
                            final validForm = _updateInfokey.currentState!.validate();
                            if (validForm){
                              switch(reference){
                                case "phone":{
                                  try{
                                    usersRef.doc(uid).update({reference:controller.text});
                                    Navigator.pop(context);
                                    Flushbar(
                                        margin: EdgeInsets.all(10),
                                        borderRadius: BorderRadius.circular(10),
                                        title: 'Telefonnummer',
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                        message: "Telefonnummer gemt",
                                        flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                                  }
                                  catch(e){
                                    Flushbar(
                                        margin: EdgeInsets.all(10),
                                        borderRadius: BorderRadius.circular(10),
                                        title: 'Telefonnummer',
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                        message: "Kunne ikke gemme telefonnummer",
                                        flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                                  }
                                }
                                break;
                                case "email":{
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AuthenticateEmailScreen()));
                                }
                                break;
                              }
                            }
                          },
                            icon: const Icon(Icons.save, color: Colors.white,),
                            label: const Align(alignment: Alignment.centerLeft,
                                child: Text("Gem", style: TextStyle(color: Colors.white),)),),),
                      ],
                    ),),)));}, child: Center(
              child: Row(children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(field, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
                const Spacer(),
                const Align(alignment: Alignment.centerRight, child: Icon(Icons.edit, color: Colors.blue,))
              ]
              )
          )
          ),
        ),
      ],
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.only(bottom: 20), child: const Center(child: Text("Mine oplysninger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),),
              Container(padding: const EdgeInsets.only(bottom: 20), child: Center(child: TextButton(onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Scaffold(resizeToAvoidBottomInset: false, appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const BackButton(color: Colors.black),
                ),
                  body: Column(
                    children: [
                      Container(padding: const EdgeInsets.only(bottom: 20, top: 20) , child: const Center(child: Text("Rediger bruger", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
                      updateUserField(user!.uid, 'phone', "Telefon", phoneController),
                      updateUserField(user!.uid, 'email', "E-mail", updatedEmailController),
                    ],
                  ),)));
              }, child: const Text("Rediger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),),),),
            ],
          ),
          Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 15, left: 10), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.only(bottom: 5), child: const Text("Telefonnummer", style: TextStyle(color: Colors.grey),)),
              StreamBuilder(
                  stream: getUserInfo.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData){
                      var name = snapshot.data as DocumentSnapshot;
                      return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(name['phone'].toString(), style: const TextStyle(color: Colors.black),));
                    }
                    return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                      color: Colors.blue,
                      size: 50,
                    )));
                  }
              ),
            ],
          ),),
          Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(left: 10), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.only(bottom: 5), child: const Text("E-mail", style: TextStyle(color: Colors.grey),)),
              StreamBuilder(
                  stream: getUserInfo.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData){
                      var name = snapshot.data as DocumentSnapshot;
                      return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(name['email'].toString(), style: const TextStyle(color: Colors.black),));
                    }
                    return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                      color: Colors.blue,
                      size: 50,
                    )));
                  }
              ),
            ],
          ),),
          StreamBuilder(
              stream: getUserInfo.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData){
                  var name = snapshot.data as DocumentSnapshot;
                  return Row(
                    children: [
                      Container(padding: const EdgeInsets.all(3), child: Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () async {
                        Dialogs.bottomMaterialDialog(
                            msg: "Du er ved at nulstille din adgangskode. En e-mail vil blive sendt til " + name['email'] + " med yderligere instrukser",
                            title: 'Nulstil adgangskode',
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
                                  await FirebaseAuth.instance.sendPasswordResetEmail(email: name['email']);
                                  Navigator.pop(context);
                                  Flushbar(
                                      margin: EdgeInsets.all(10),
                                      borderRadius: BorderRadius.circular(10),
                                      title: 'Nulstil adgangskode',
                                      backgroundColor: Colors.blue,
                                      duration: Duration(seconds: 3),
                                      message: 'E-mail afsendt',
                                      flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                                },
                                text: 'Send',
                                iconData: Icons.outgoing_mail,
                                color: Colors.blue,
                                textStyle: TextStyle(color: Colors.white),
                                iconColor: Colors.white,
                              ),
                            ]);
                      },
                          child: const Text("Nulstil adgangskode")))),
                      /*Container(padding: const EdgeInsets.all(3), child: Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () async {showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(title: const Text("SLET BRUGER"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), content: Text("Du er ved at slette din bruger permanent. Denne handling kan ikke fortrydes!"), actions: [
                          TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,
                          TextButton(onPressed: () async {
                            Navigator.pop(context);
                            showDialog(context: context, builder: (BuildContext context){
                              emailController.clear();
                              return Form(
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                key: _authUserkey,
                                child: AlertDialog(title: const Text("Autentificer konto"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), content: const Text("Du bedes indtaste din nuværende e-mail og adgangskode for at komme videre."), actions: [
                                  TextFormField(validator: validateEmail, controller: emailController, decoration: const InputDecoration(icon: Icon(Icons.email), hintText: "E-mail", hintMaxLines: 10,),),
                                  TextFormField(validator: validatePassword, controller: passwordController, obscureText: true, decoration: const InputDecoration(icon: Icon(Icons.password), hintText: "Adgangskode", hintMaxLines: 10,),),
                                  TextButton(onPressed: () async {
                                    if (_authUserkey.currentState!.validate()){
                                      try{
                                        await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                                        FirebaseAuth.instance.currentUser?.delete();
                                        Navigator.pop(context); Navigator.pop(context);
                                        _showSnackBar(context, "Bruger Slettet", Colors.green);
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
                                      }
                                      on FirebaseAuthException catch(e){if(e.code == "wrong-password"){_showSnackBar(context, "Forkert adgangskode!", Colors.red);} else if (e.code == "invalid-email"){ _showSnackBar(context, "Forkert E-mail!", Colors.red);} else if (e.code == "user-not-found"){_showSnackBar(context, "Bruger eksisterer ikke!", Colors.red);} else { _showSnackBar(context, "Fejlkode " + e.code, Colors.red);}}
                                    }
                                  }, child: const Text("Godkend")),
                                ],),
                              );});}, child: const Text("SLET BRUGER", style: TextStyle(color: Colors.red),))],);});},
                          child: const Text("SLET BRUGER", style: TextStyle(color: Colors.red),)))),*/
                    ],
                  );
                }
                return Container();
              }
          ),
        ],
      ),
    );
  }
}

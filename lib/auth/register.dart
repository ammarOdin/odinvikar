import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/dashboard.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }


  String? validateEmail(String? email){
    if (email == null || email.isEmpty){
      return "Indsæt e-mail";
    } else if (!email.contains("@") || !email.contains(".")){
      return "Ugyldig e-mail";
    }
  }

  String? validatePassword(String? password){
    if (password == null || password.isEmpty){
      return "Indsæt password";
    }
  }

  String? validateName(String? name){
    if (name == null || name.isEmpty || name == ""){
      return "Indsæt navn";
    }
  }

  String? validatePhone(String? number){
    if (isNumeric(number!) == false || number == "" || number.isEmpty){
      return "Telefon skal kun indeholde numre!";
    } else if (number.length < 8 || number.length > 8){
      return "Nummeret skal være 8 cifre langt!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showTopSnackBar(context, CustomSnackBar.info(message: "Tryk på tilbage-knappen for at navigere tilbage til hjemmeskærmen",),);
        return false;
        },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();
            showTopSnackBar(context, CustomSnackBar.info(message: "Brugeroprettelse afbrudt",),);

            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20,),),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          children: [
            Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height / 3.5,
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 100, left: MediaQuery.of(context).size.width / 200),
                      child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "\nRegistrer bruger\n",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 30, fontWeight: FontWeight.bold),
                          ))),
                ],
              ),
            ),
            Form(
              key: _key,
              child: Column(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: const EdgeInsets.only(bottom: 10, top: 10, left: 5, right: 15),
                      margin: const EdgeInsets.only(top: 10),
                      child: TextFormField(validator: validateEmail, keyboardType: TextInputType.emailAddress, controller: emailController, decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
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
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15)),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: "Indtast e-mail",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),)),
                  Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: const EdgeInsets.only(bottom: 10, top: 10, left: 5, right: 15),
                      child: TextFormField(validator: validatePassword, controller: passwordController, keyboardType: TextInputType.text, obscureText: true, decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
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
                        labelText: 'Adgangskode',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15)),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: "Indtast adgangskode",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),)),
                  Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: const EdgeInsets.only(bottom: 10, top: 10, left: 5, right: 15),
                      child: TextFormField(validator: validateName, controller: nameController, keyboardType: TextInputType.text, decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_add,
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
                        labelText: 'Navn',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15)),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: "Indtast dit navn",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),)),
                  Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: const EdgeInsets.only(bottom: 10, top: 10, left: 5, right: 15),
                      child: TextFormField(validator: validatePhone, controller: phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
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
                        labelText: 'Telefon',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15)),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: "Indtast telefonnummer",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),)),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 50, left: 10, right: 10, top: 40),
                    child: ElevatedButton(onPressed: () async {
                      if (_key.currentState!.validate()){
                        try{
                          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                          usersRef.doc(userCredential.user?.uid).get().then((DocumentSnapshot documentSnapshot) async {
                            if (documentSnapshot.exists) {
                              showTopSnackBar(context, CustomSnackBar.error(message: "Bruger eksisterer allerede",),);
                            } else if (!documentSnapshot.exists) {
                              // get token
                              var token;
                              await FirebaseMessaging.instance.getToken().then((value) {token = value;});

                              // save user cred to db
                              await usersRef.doc(userCredential.user?.uid).set({
                                'email': emailController.text,
                                'isAdmin': false,
                                'isSynced': false,
                                'name': nameController.text,
                                'phone': phoneController.text,
                                'token': token,
                                'syncURL': "",
                              });

                              // regen new OTP and save
                              const _chars = '1234567890';
                              Random _rnd = Random();
                              String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
                                  length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

                              var otp = getRandomString(8);
                              await FirebaseFirestore.instance.collection('auth').doc('authInfo').set({'OTP': otp});
                              showTopSnackBar(context, CustomSnackBar.success(message: "Logget ind",),);
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Dashboard()));
                            }
                          });
                          //launch("https://vikarly.dk/?page_id=1685");
                        } on FirebaseAuthException catch(e){
                          showTopSnackBar(context, CustomSnackBar.error(message: "Fejl ved oprettelse - ${e.code}",),);
                        }
                      }},child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: const Align(alignment: Alignment.center, child: Text("Opret bruger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),))), style: ButtonStyle(shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(color: Colors.blue)
                        )
                    )),),),
                  TextButton(onPressed: () async {
                    launch("https://vikarly.dk/");
                  }, child: const Text("vikarly.dk")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

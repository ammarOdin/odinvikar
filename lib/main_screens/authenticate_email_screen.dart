import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class AuthenticateEmailScreen extends StatefulWidget {
  const AuthenticateEmailScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticateEmailScreen> createState() => _AuthenticateEmailScreenState();
}

class _AuthenticateEmailScreenState extends State<AuthenticateEmailScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _authUserkey = GlobalKey<FormState>();
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: false,
        backgroundColor: Colors.blue,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Text("Autentificer konto",  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),),
        leading: BackButton(),
      ),
      body: Form(
        key: _authUserkey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15, top: 20, bottom: 20, right: 15),
                child: Text("Du bedes indtaste din e-mail og adgangskode for at komme videre.",
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),)),
            Container(
                padding: EdgeInsets.only(left: 15, right: 20, top: 20),
                child: TextFormField(
                  validator: validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(prefixIcon: Icon(Icons.mail, color: Colors.grey.withOpacity(0.75),), fillColor: Colors.grey.withOpacity(0.25), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(15)), labelText: 'E-mail', labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black,),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Indtast din nuværende e-mail...", hintStyle: TextStyle(color: Colors.grey),),)),
            Container(
                padding: EdgeInsets.only(left: 15, right: 20, top: 20),
                child: TextFormField(
                  validator: validatePassword,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(prefixIcon: Icon(Icons.lock, color: Colors.grey.withOpacity(0.75),), fillColor: Colors.grey.withOpacity(0.25), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(15)), labelText: 'Adgangskode', labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black,),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Indtast adgangskode...", hintStyle: TextStyle(color: Colors.grey),),)),

            Container(
              padding: EdgeInsets.only(right: 10, top: 40, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: () async {
                    if (_authUserkey.currentState!.validate()){
                      try{
                        await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                        FirebaseAuth.instance.currentUser?.updateEmail(emailController.text);
                        usersRef.doc(FirebaseAuth.instance.currentUser?.uid).update({'email':emailController.text});
                        emailController.clear();
                        Navigator.pop(context);
                        Flushbar(
                            margin: EdgeInsets.all(10),
                            borderRadius: BorderRadius.circular(10),
                            title: 'Nye oplysninger',
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                            message: "Dine nye oplysninger er blevet gemt",
                            flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                      } on FirebaseAuthException catch(e){
                        if(e.code == "wrong-password"){
                          Flushbar(
                              margin: EdgeInsets.all(10),
                              borderRadius: BorderRadius.circular(10),
                              title: 'Fejl',
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              message: "Forkert adgangskode",
                              flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                        } else if (e.code == "invalid-email") {
                          Flushbar(
                              margin: EdgeInsets.all(10),
                              borderRadius: BorderRadius.circular(10),
                              title: 'Fejl',
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              message: "Forkert e-mail",
                              flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                        } else if (e.code == "user-not-found"){
                          Flushbar(
                              margin: EdgeInsets.all(10),
                              borderRadius: BorderRadius.circular(10),
                              title: 'Fejl',
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              message: "Bruger eksisterer ikke",
                              flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                        } else {
                          Flushbar(
                              margin: EdgeInsets.all(10),
                              borderRadius: BorderRadius.circular(10),
                              title: 'Fejl',
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              message: "Fejlkode ${e.code}",
                              flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                        }
                      }
                    }
                  },
                    child: Text("Autentificer", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(const Size(230, 50)),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        elevation: MaterialStateProperty.all(3),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                    ),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

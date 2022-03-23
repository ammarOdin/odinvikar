import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odinvikar/admin/admin_dashboard.dart';
import 'package:odinvikar/main_screens/dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetKey = GlobalKey<FormState>();

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
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

  isAdmin() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot){
      if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == true){
        return true;
      } else if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == false){
        return false;
      } else {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
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
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 100, left: MediaQuery.of(context).size.width / 20 ),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                        child: Text(
                          "Vikarly \nOdinskolen",
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                        ))),
              ],
            ),
          ),
          Form(
            key: _key,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
                    margin: const EdgeInsets.only(top: 10),
                    child: TextFormField(validator: validateEmail, controller: emailController, decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'E-mail',),)),
                Container(
                    padding: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
                    child: TextFormField(validator: validatePassword, controller: passwordController, obscureText: true, decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Adgangskode',),)),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
                  child: ElevatedButton.icon(onPressed: () async {
                    if (_key.currentState!.validate()){
                      try{
                        await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                        _showSnackBar(context, "Logget Ind", Colors.green);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AuthenticationWrapper()));
                      } on FirebaseAuthException catch(e){
                        if(e.code == "user-not-found"){
                          _showSnackBar(context, "Bruger eksisterer ikke!", Colors.red);
                        } else {
                          _showSnackBar(context, "Forkert e-mail eller adgangskode", Colors.red);}
                      }
                    }}, icon: const Icon(Icons.login), label: const Align(alignment: Alignment.centerLeft, child: Text("Log ind")), style: ButtonStyle(shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(color: Colors.blue)
                      )
                  )),),),
                Form(
                  key: _resetKey,
                  child: TextButton(onPressed: () async {
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(title: const Text("Nulstil Adgangskode"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), content: Text("Du er ved at nulstille din adgangskode. Hvis du har en konto, vil en e-mail vil blive sendt til dig med yderligere instrukser."), actions: [
                        TextFormField(validator: validateEmail, controller: emailController, decoration: const InputDecoration(icon: Icon(Icons.email), hintText: "E-mail", hintMaxLines: 10,),),
                        TextButton(onPressed: () async {
                          if(_resetKey.currentState!.validate()){
                            try{
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text); Navigator.pop(context); _showSnackBar(context, "E-mail sendt!", Colors.green);
                            } on FirebaseAuthException catch (e){
                              if(e.code == "user-not-found"){
                                _showSnackBar(context, "Bruger eksisterer ikke!", Colors.red);
                              } else {
                                _showSnackBar(context, "Fejl", Colors.red);}
                            }

                          }}, child: const Text("Send E-mail"))],);});
                  }, child: Text("Glemt Adgangskode")),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 80),
            child: Center(child: Text("Har du problemer med din konto, kan du kontakte os via telefon")),
          ),
          TextButton(onPressed: (){launch("tel://60 51 02 97");}, child: Text("60 51 02 97")),
        ],
      ),
    );
  }
}

class AuthenticationLogin extends StatelessWidget {
  const AuthenticationLogin({Key? key}) : super(key: key);

  isAdmin() async {
    var login = await
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot){
      if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == true){
        return true;
      } else if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == false){
        return false;
      }
    });
    return login;
  }
  @override
  Widget build(BuildContext context)  {
    return FutureBuilder(future: isAdmin(), builder: (context, snapshot) => snapshot.data == true? const AdminDashboard(): const Dashboard());
  }
}
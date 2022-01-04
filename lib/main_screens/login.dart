import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odinvikar/main_screens/dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
        //physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(
            color: Colors.blue,
            height: MediaQuery.of(context).size.height / 3,
            child: ListView(
              children: [
                Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 100, left: MediaQuery.of(context).size.width / 20 ),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                        child: Text(
                          "OdinVikar \nLogin",
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                        ))),
              ],
            ),
          ),

          Form(
            key: _key,
            child: Column(
              children: [
                Container(padding: const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10), margin: const EdgeInsets.only(top: 10), child: TextFormField(validator: validateEmail, controller: emailController, decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))), labelText: 'E-mail',),)),
                Container(padding: const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10), child: TextFormField(validator: validatePassword, controller: passwordController, obscureText: true, decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))), labelText: 'Adgangskode',),)),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
                  child: ElevatedButton.icon(onPressed: () async {if (_key.currentState!.validate()){try{await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text); _showSnackBar(context, "Login succesfuld"); Future.delayed(const Duration(seconds: 2)); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Dashboard()));} on FirebaseAuthException catch(e){if(e.message == "user-not-found"){_showSnackBar(context, "Bruger ikke fundet");} else {_showSnackBar(context, "Forkert e-mail eller adgangskode");}}} }, icon: const Icon(Icons.login), label: const Align(alignment: Alignment.centerLeft, child: Text("Log ind")), style: ElevatedButton.styleFrom(primary: Colors.blue),),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
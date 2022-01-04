import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();


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

          Container(padding: const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10), margin: const EdgeInsets.only(top: 10), child: TextFormField(controller: emailController, decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))), labelText: 'E-mail',),)),
          Container(padding: const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10), child: TextFormField(controller: passwordController, obscureText: true, decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))), labelText: 'Adgangskode',),)),
          Container(
            height: 45,
            width: 150,
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
            child: ElevatedButton.icon(onPressed: () async {await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text); setState(() {});}, icon: const Icon(Icons.login), label: const Align(alignment: Alignment.centerLeft, child: Text("Log ind")), style: ElevatedButton.styleFrom(primary: Colors.blue),),),
        ],
      ),
    );
  }
}
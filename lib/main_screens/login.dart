import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(children: [
        Container(padding: const EdgeInsets.only(left: 20), child: const Align(alignment: Alignment.centerLeft, child: Text("OdinVikar Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),))),
      ],),
    );
    //return ListView(padding: EdgeInsets.zero, children: [Text("Login"), Text("Yes")],);
  }
}
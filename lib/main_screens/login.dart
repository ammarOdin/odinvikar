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
                        top: MediaQuery.of(context).size.height / 30),
                    child: Image(image: NetworkImage("")) ),
              ],
            ),
          ),

        ],
      ),
    );
    //return ListView(padding: EdgeInsets.zero, children: [Text("Login"), Text("Yes")],);
  }
}
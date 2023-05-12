import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth/login.dart';
import 'main.dart';

class OnLaunchLoadingScreen extends StatefulWidget {
  const OnLaunchLoadingScreen({Key? key}) : super(key: key);

  @override
  State<OnLaunchLoadingScreen> createState() => _OnLaunchLoadingScreenState();
}

class _OnLaunchLoadingScreenState extends State<OnLaunchLoadingScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  checkHome() async {
    if (user != null){
      return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthenticationWrapper()));
    } else {
      return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkHome();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CircularProgressIndicator.adaptive()
      ),
    );
  }
}

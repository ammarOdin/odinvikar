import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/admin/admin_dashboard.dart';
import 'package:odinvikar/main_screens/dashboard.dart';
import 'auth/login.dart';

class OnLaunchLoadingScreen extends StatefulWidget {
  const OnLaunchLoadingScreen({Key? key}) : super(key: key);

  @override
  State<OnLaunchLoadingScreen> createState() => _OnLaunchLoadingScreenState();
}

class _OnLaunchLoadingScreenState extends State<OnLaunchLoadingScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  checkLoginState() async {
    if (user != null) {
      checkUserPermissions(user);
    } else {
      return Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  void checkUserPermissions(User? user) async {
    await FirebaseFirestore.instance.collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == true) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminDashboard()));
      } else if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == false) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Dashboard()));
      }
    });
  }


  @override
  void initState() {
    super.initState();
    checkLoginState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: CircularProgressIndicator.adaptive()
      ),
    );
  }
}

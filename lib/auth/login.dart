import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/admin/admin_dashboard.dart';
import 'package:odinvikar/main_screens/dashboard.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'auth_register.dart';

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

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Indsæt e-mail";
    } else if (!email.contains("@") || !email.contains(".")) {
      return "Ugyldig e-mail";
    }
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Indsæt password";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: "Du kan ikke navigere tilbage",
          ),
        );
        return false;
      },
      child: Scaffold(
        body: ListView(
          physics: const ClampingScrollPhysics(),
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
                          top: MediaQuery.of(context).size.height / 10,
                          left: MediaQuery.of(context).size.width / 20),
                      child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Vikarly \nOdinskolen",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.only(
                          bottom: 10, top: 40, left: 15, right: 15),
                      margin: const EdgeInsets.only(top: 10),
                      child: TextFormField(
                          validator: validateEmail,
                          controller: emailController,
                          decoration: InputDecoration(
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
                          ))),
                  Container(
                      padding: const EdgeInsets.only(
                          bottom: 10, top: 10, left: 15, right: 15),
                      child: TextFormField(
                          validator: validatePassword,
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
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
                          ))),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            onPressed: () async {
                              if (_key.currentState!.validate()) {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        content: SpinKitRing(
                                          color: Colors.blue,
                                        ),
                                      );
                                    });
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: emailController.text,
                                          password: passwordController.text);
                                  User? user = FirebaseAuth.instance.currentUser;
                                  FirebaseMessaging.instance.getToken().then((value) {
                                    FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(user!.uid)
                                        .update({'token': value});
                                  });
                                  Navigator.pop(context);
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AuthenticationWrapper()));
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == "user-not-found") {
                                    Navigator.pop(context);
                                    showTopSnackBar(
                                      context,
                                      CustomSnackBar.error(
                                        message: "Bruger eksisterer ikke",
                                      ),
                                    );
                                  } else {
                                    Navigator.pop(context);
                                    showTopSnackBar(
                                      context,
                                      CustomSnackBar.error(
                                        message: "Forkert e-mail eller adgangskode",
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.login),
                            label: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Log ind", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white))),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                  elevation: MaterialStateProperty.all(3),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                              )
                          ),
                      ],
                    ),
                  ),

                  Form(
                    key: _resetKey,
                    child: TextButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Nulstil adgangskode"),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  content: Text(
                                      "Du er ved at nulstille din adgangskode. Hvis du har en konto, vil en e-mail vil blive sendt til dig med yderligere instrukser."),
                                  actions: [
                                    TextFormField(
                                      validator: validateEmail,
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.email),
                                        hintText: "E-mail",
                                        hintMaxLines: 10,
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () async {
                                          if (_resetKey.currentState!
                                              .validate()) {
                                            try {
                                              await FirebaseAuth.instance
                                                  .sendPasswordResetEmail(
                                                      email:
                                                          emailController.text);
                                              Navigator.pop(context);
                                              showTopSnackBar(
                                                context,
                                                CustomSnackBar.success(
                                                  message: "E-mail afsendt",
                                                ),
                                              );
                                            } on FirebaseAuthException catch (e) {
                                              if (e.code == "user-not-found") {
                                                showTopSnackBar(
                                                  context,
                                                  CustomSnackBar.error(
                                                    message:
                                                        "Bruger eksisterer ikke",
                                                  ),
                                                );
                                              } else {
                                                showTopSnackBar(
                                                  context,
                                                  CustomSnackBar.error(
                                                    message:
                                                        "En fejl opstod. Prøv igen",
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        child: const Text("Send e-mail"))
                                  ],
                                );
                              });
                        },
                        child: Text("Glemt adgangskode")),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AuthRegisterPage()));
                      },
                      child: Text("Ny vikar? Opret bruger")),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Center(
                  child: Text(
                      "Har du problemer med din konto, kan du kontakte os via telefon")),
            ),
            TextButton(
                onPressed: () {
                  launch("tel://42750701");
                },
                child: Text("42 75 07 01")),
          ],
        ),
      ),
    );
  }
}

class AuthenticationLogin extends StatelessWidget {
  const AuthenticationLogin({Key? key}) : super(key: key);

  isAdmin() async {
    var login = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == true) {
        return true;
      } else if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == false) {
        return false;
      }
    });
    return login;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isAdmin(),
        builder: (context, snapshot) =>
            snapshot.data == true ? const AdminDashboard() : const Dashboard());
  }
}

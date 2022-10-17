import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/auth/register.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({Key? key}) : super(key: key);

  @override
  State<AuthRegisterPage> createState() => _AuthRegisterPageState();
}

class _AuthRegisterPageState extends State<AuthRegisterPage> {

  final emailauthController = TextEditingController();
  final passwordauthController = TextEditingController();
  final GlobalKey<FormState> _authkey = GlobalKey<FormState>();

  String? validatePassword(String? password){
    if (password == null || password.isEmpty){
      return "Indtast kode";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: false,
        backgroundColor: Colors.blue,
        toolbarHeight: 75,
        automaticallyImplyLeading: false,
        title: Text("Opret bruger", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20,), color: Colors.white),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.only(left: 15, top: 30),
            child: Text("For at oprette dig som bruger, skal du først autentificeres. Indtast kodeordet som du har modtaget fra din institution.",
              style: TextStyle(fontSize: 14, color: Colors.grey),),
          ),
          Form(
            key: _authkey, child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 30, left: 15, right: 15),
                  child: TextFormField(validator: validatePassword, controller: passwordauthController, keyboardType: TextInputType.number, decoration: InputDecoration(
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
                    labelText: 'Engangskode',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(15)),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Indtast kode",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),)),
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 15),
                child: ElevatedButton.icon(onPressed: () async {
                  if (_authkey.currentState!.validate()) {
                    showDialog(barrierDismissible: false, context: context, builder: (BuildContext context){
                      return AlertDialog(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        content: SpinKitRing(
                          color: Colors.blue,
                        ),
                      );
                    });
                    try{
                      var getAuthInfo = await FirebaseFirestore.instance.collection('auth').doc('authInfo').get();
                      //await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailauthController.text, password: passwordauthController.text);
                      if (passwordauthController.text.trim() == getAuthInfo.data()!['OTP']){
                        showTopSnackBar(context, CustomSnackBar.success(message: "Forespørgsel godkendt",),);
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RegisterPage()));
                      } else {
                        Navigator.pop(context);
                        showTopSnackBar(context, CustomSnackBar.error(message: "Forkert kode",),);
                      }
                    } catch(e){
                      Navigator.pop(context);
                      showTopSnackBar(context, CustomSnackBar.error(message: "Forkert kode",),);
                    }
                  }}, icon: const Icon(Icons.check_circle_outline), label: const Align(alignment: Alignment.centerLeft, child: Text("Autentificer")), style: ButtonStyle(shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Colors.blue)
                    )
                )),),
              ),
            ],
          ),
          ),

        ],
      ),
    );
  }
}

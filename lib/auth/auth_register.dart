import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odinvikar/auth/register.dart';

class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({Key? key}) : super(key: key);

  @override
  State<AuthRegisterPage> createState() => _AuthRegisterPageState();
}

class _AuthRegisterPageState extends State<AuthRegisterPage> {

  final emailauthController = TextEditingController();
  final passwordauthController = TextEditingController();
  final GlobalKey<FormState> _authkey = GlobalKey<FormState>();

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

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Opret bruger"),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20,), color: Colors.white),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, top: 40),
            child: Text("For at oprette dig som bruger, skal du først autentificeres. Indtast e-mail og kodeord som du har modtaget fra din institution. "
                "Du vil blive viderestillet til en skærm hvor du kan oprette dig selv som bruger.",
              style: TextStyle(fontSize: 14, color: Colors.grey),),
          ),
          Form(
            key: _authkey, child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 20, left: 15, right: 15),
                  margin: const EdgeInsets.only(top: 10),
                  child: TextFormField(validator: validateEmail, controller: emailauthController, decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'E-mail',),)),
              Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
                  child: TextFormField(validator: validatePassword, controller: passwordauthController, obscureText: true, decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Adgangskode',),)),
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
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
                      if (emailauthController.text.trim() == getAuthInfo.data()!['email']  && passwordauthController.text.trim() == getAuthInfo.data()!['password']){
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RegisterPage()));
                      } else {
                        Navigator.pop(context);
                        _showSnackBar(context, "Forkert e-mail eller adgangskode", Colors.red);
                      }
                    } catch(e){
                      Navigator.pop(context);
                      _showSnackBar(context, "Forkert e-mail eller adgangskode", Colors.red);
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

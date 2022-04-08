import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');

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

  String? validateName(String? name){
    if (name == null || name.isEmpty || name == ""){
      return "Indsæt navn";
    }
  }

  String? validatePhone(String? number){
    if (isNumeric(number!) == false || number == "" || number.isEmpty){
      return "Telefon skal kun indeholde numre!";
    } else if (number.length < 8 || number.length > 8){
      return "Nummeret skal være 8 cifre langt!";
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
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(
            color: Colors.transparent,
            height: MediaQuery.of(context).size.height / 3,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 100, left: MediaQuery.of(context).size.width / 20 ),
                    child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "\nRegistrer Bruger\n",
                          style: TextStyle(color: Colors.blueGrey, fontSize: 30, fontWeight: FontWeight.bold),
                        ))),
              ],
            ),
          ),
          Form(
            key: _key,
            //autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
                    margin: const EdgeInsets.only(top: 10),
                    child: TextFormField(validator: validateEmail, controller: emailController, decoration: const InputDecoration(icon: Icon(Icons.email), border: UnderlineInputBorder(), labelText: 'E-mail',),)),
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
                    child: TextFormField(validator: validatePassword, controller: passwordController, obscureText: true, decoration: const InputDecoration(icon: Icon(Icons.password_rounded), border: UnderlineInputBorder(), labelText: 'Adgangskode',),)),
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
                    child: TextFormField(validator: validateName, controller: nameController, decoration: const InputDecoration(icon: Icon(Icons.person), border: UnderlineInputBorder(), labelText: 'Navn',),)),
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
                    child: TextFormField(validator: validatePhone, controller: phoneController, decoration: const InputDecoration(icon: Icon(Icons.phone), border: UnderlineInputBorder(), labelText: 'Telefon',),)),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 50, left: 10, right: 10, top: 150),
                  child: ElevatedButton(onPressed: () async {
                    if (_key.currentState!.validate()){
                      try{
                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                        usersRef.doc(userCredential.user?.uid).get().then((DocumentSnapshot documentSnapshot) async {
                          if (documentSnapshot.exists) {
                            _showSnackBar(context, "Bruger findes allerede!", Colors.red);
                          } else if (!documentSnapshot.exists) {
                            await usersRef.doc(userCredential.user?.uid).set({'email': emailController.text, 'isAdmin':false, 'name': nameController.text, 'phone': phoneController.text});
                            emailController.clear();
                            passwordController.clear();
                            nameController.clear();
                            phoneController.clear();
                          }
                        });
                        launch("https://vikarly.dk/?page_id=1685");
                      } on FirebaseAuthException catch(e){
                        _showSnackBar(context, "Fejl ved oprettelse - " + e.code, Colors.red);}
                    }},child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: const Align(alignment: Alignment.center, child: Text("Opret Bruger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),))), style: ButtonStyle(shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(color: Colors.blue)
                      )
                  )),),),
                TextButton(onPressed: () async {
                  launch("https://vikarly.dk/");
                }, child: const Text("vikarly.dk")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

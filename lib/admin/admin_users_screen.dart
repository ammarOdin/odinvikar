import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:validators/validators.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');

  final GlobalKey<FormState> _updatekey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool validName = false;
  bool validPhone = false;
  bool validEmail = false;
  bool validPassword = false;

  @override
  void initState() {
    super.initState();
  }

  // Register user through auth without logging current user out
  Future<void> register(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(name: 'Secondary', options: Firebase.app().options);
    try {
      // initialize another app to prevent current user from logging out on creation of a new user
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: password);

      usersRef.doc(userCredential.user?.uid).get().then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists){
          Flushbar(
              margin: EdgeInsets.all(10),
              borderRadius: BorderRadius.circular(10),
              title: 'Login',
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              message: 'Bruger eksisterer allerede',
              flushbarPosition: FlushbarPosition.BOTTOM).show(context);
        } else if (!documentSnapshot.exists){
          await usersRef.doc(userCredential.user?.uid).set({'email': emailController.text, 'isAdmin':false, 'name': nameController.text, 'phone': phoneController.text, 'token': ''});
          Flushbar(
              margin: EdgeInsets.all(10),
              borderRadius: BorderRadius.circular(10),
              title: 'Bruger',
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              message: 'Bruger oprettet',
              flushbarPosition: FlushbarPosition.BOTTOM).show(context);
          emailController.clear();
          passwordController.clear();
          nameController.clear();
          phoneController.clear();
        }
      });

      // killing the app after use
      await app.delete();
      return Future.sync(() => userCredential);
    }
    on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email"){
        Flushbar(
            margin: EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(10),
            title: 'Bruger',
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            message: 'Ugyldig e-mail',
            flushbarPosition: FlushbarPosition.BOTTOM).show(context);
      } else {
        Flushbar(
            margin: EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(10),
            title: 'Bruger',
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            message: 'Bruger kunne ikke oprettes. Prøv igen',
            flushbarPosition: FlushbarPosition.BOTTOM).show(context);
      }
      /*if (kDebugMode) {
        print(e.toString());
      }*/
    }
    // making sure the app is killed, even if failed operation above
    //await app.delete();
    //return FirebaseAuth.instance.currentUser as UserCredential;
  }

  // Delete user with admin sdk cloud function
  Future<void> deleteUser(String uid) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('deleteUser');
    await callable.call(<String, dynamic>{
      'user': uid,
    });
  }

  // update the selected field for a specific user
  updateUserField(String uid, String reference, String field, TextEditingController controller, String name) {
    return Column(
      children: [
        Container(
          margin:const EdgeInsets.only(right: 10, left: 10, top: 5,bottom: 5),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent), onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Scaffold(resizeToAvoidBottomInset: false, appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
          ),
            body: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _updatekey,
              child: Column(
                children: [
                  Container(padding: const EdgeInsets.only(top: 50, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: (input) => validateUpdateField(reference, controller.text), controller: controller, decoration: InputDecoration(icon: const Icon(Icons.edit), hintText: field, hintMaxLines: 10,),) ,)),
                  Container(height: 50, width: MediaQuery.of(context).size.width, margin: const EdgeInsets.only(top: 50, left: 20, right: 20), child: ElevatedButton.icon(onPressed: () async {
                    final validForm = _updatekey.currentState!.validate();
                    if (validForm){
                      switch(reference){
                        case "email":{
                          try{
                            updateUserEmail(uid, controller.text);
                            usersRef.doc(uid).update({reference:controller.text});
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Bruger',
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                                message: 'Ny e-mail gemt',
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                            Navigator.pop(context);
                          } on FirebaseAuthException catch(e) {
                            if(e.code == 'invalid-email'){
                              Flushbar(
                                  margin: EdgeInsets.all(10),
                                  borderRadius: BorderRadius.circular(10),
                                  title: 'Bruger',
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                  message: 'Ugyldig e-mail',
                                  flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                            } else {
                              Flushbar(
                                  margin: EdgeInsets.all(10),
                                  borderRadius: BorderRadius.circular(10),
                                  title: 'Bruger',
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                  message: 'En fejl opstod. Prøv igen',
                                  flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                            }
                          }
                        }
                        break;
                        case "password":{
                          try{
                            updateUserPassword(uid, controller.text);
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Bruger',
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                                message: 'Ny adgangskode gemt',
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                            Navigator.pop(context);
                          } catch(e) {
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Bruger',
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: 'En fejl opstod. Prøv igen',
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                          }
                        }
                        break;
                        case "phone":{
                          try{
                            usersRef.doc(uid).update({reference:controller.text});
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Bruger',
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                                message: 'Telefonnummer gemt',
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                            Navigator.pop(context);
                          } catch(e) {
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Bruger',
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: 'En fejl opstod. Prøv igen',
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                          }
                        }
                        break;
                        case "name":{
                          try{
                            usersRef.doc(uid).update({reference:controller.text});
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Bruger',
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                                message: 'Nyt navn gemt',
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                            Navigator.pop(context);
                          } catch(e) {
                            Flushbar(
                                margin: EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(10),
                                title: 'Bruger',
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: 'En fejl opstod. Prøv igen',
                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                          }
                        }
                        break;
                      }
                    }
                  }, icon: const Icon(Icons.save, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Gem", style: TextStyle(color: Colors.white),)),),),
                ],
              ),
            ),)));
        }, child: Center(child: Row(children: [Align(alignment: Alignment.centerLeft, child: Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), const Spacer(), const Align(alignment: Alignment.centerRight, child: Icon(Icons.edit, color: Colors.blue,))]),),),
        ),
      ],
    );
  }

  // Update user email with input details from admin through cloud function
  Future<void> updateUserEmail(String uid, String email) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateUserEmail');
    await callable.call(<String, dynamic>{
      'user': uid,
      'email': email,
    });
  }

  // Update user password with input details from admin through cloud function
  Future<void> updateUserPassword(String uid, String password) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateUserPass');
    await callable.call(<String, dynamic>{
      'user': uid,
      'password': password,
    });
  }

  // Below explain themselves
  String? validateUpdateField(String reference , String? input){
    switch(reference){
      case "name": {
        if (input == null || input.isEmpty || input == ""){
          return "Indsæt navn";
        } else {
          validName == true;
        }
      }
      break;
      case "email": {
        if (input == null || input.isEmpty){
          return "Indsæt e-mail";
        } else if (!input.contains("@") || !input.contains(".")){
          return "Ugyldig e-mail";
        } else {
          validEmail == true;
        }
      }
      break;
      case "password": {
        if (input == null || input.isEmpty || input == ""){
          return "Ugyldig password";
        } else if (input.length < 6){
          return "Password skal indeholde mindst 6 tegn!";
        } else {
          validPassword == true;
        }
      }
      break;
      case "phone": {
        if (isNumeric(input!) == false || input == "" || input.isEmpty){
          return "Telefon skal kun indeholde numre!";
        } else if (input.length < 8 || input.length > 8){
          return "Nummeret skal være 8 cifre langt!";
        } else {
          validPhone == true;
        }
      }
      break;
    }
  }

  String? validateName(String? name){
    if (name == null || name.isEmpty || name == ""){
      return "Indsæt navn";
    } else {
      validName = true;
    }

  }
  String? validateEmail(String? email){
    if (email == null || email.isEmpty){
      return "Indsæt e-mail";
    } else if (!email.contains("@") || !email.contains(".")){
      return "Ugyldig e-mail";
    } else {
      validEmail = true;
    }
  }

  String? validatePassword(String? password){
    if (password == null || password.isEmpty || password == ""){
      return "Ugyldig password";
    } else if (password.length < 6){
      return "Password skal indeholde mindst 6 tegn!";
    } else {
      validPassword = true;
    }

  }

  String? validatePhone(String? number){
    if (isNumeric(number!) == false || number == "" || number.isEmpty){
      return "Telefon skal kun indeholde numre!";
    } else if (number.length < 8 || number.length > 8){
      return "Nummeret skal være 8 cifre langt!";
    } else {
      validPhone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: false,
        backgroundColor: Colors.blue,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Text("Brugeroplysninger",  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20,),),
      ),
      body: ListView(
        shrinkWrap: true,
        primary: false,
        children: [
          Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, top: 30, left: 10), child: Container(alignment: Alignment.centerLeft, child: Text("Alle brugere", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black87),),),),
          Column (children: [
            StreamBuilder(
                stream: usersRef.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData){
                    return SizedBox(height: 50, width: 50, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                      color: Colors.blue,
                      size: 50,
                    )));
                  } else if (snapshot.data!.docs.isEmpty){
                    return Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 30),
                      child: const Center(child: Text(
                        "Ingen Vikarer",
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      ),),
                    );
                  }

                  return Column(children: snapshot.data!.docs.map((e) {
                    return SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Container(margin:const EdgeInsets.only(right: 10, left: 10, top: 5,bottom: 5), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent), onPressed: () {
                        showDialog(context: context, builder: (BuildContext context){
                          return SimpleDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), title: const Center(child: Text("Rediger Bruger")),
                            children: [
                              SimpleDialogOption(onPressed: (){
                                Navigator.pop(context);
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Scaffold(resizeToAvoidBottomInset: false, appBar: AppBar(
                                  backgroundColor: Colors.transparent,
                                  leading: const BackButton(color: Colors.black,),
                                  elevation: 0,
                                ),
                                  body: Column(
                                    children: [
                                      Container(padding: const EdgeInsets.only(bottom: 20) , child: const Center(child: Text("Rediger Bruger", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
                                      updateUserField(e.id, 'email', e['email'], emailController, 'E-mail'),
                                      updateUserField(e.id, 'password', "Adgangskode", passwordController, 'Adgangskode'),
                                      updateUserField(e.id, 'phone', e['phone'], phoneController, 'Telefon'),
                                      updateUserField(e.id, 'name', e['name'],nameController, 'Navn'),
                                      //Container(height: 50, padding: const EdgeInsets.only(top: 10, left: 10, right: 10), child: ElevatedButton.icon(onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.keyboard_return, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Tilbage", style: TextStyle(color: Colors.white),)),)),
                                      Container(height: 50, padding: const EdgeInsets.only(top: 10, left: 10, right: 10), child: ElevatedButton.icon(onPressed: () {
                                        if (e['isAdmin'] == true){
                                          showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Fjern administrator"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), content: const Text("Er du sikker på at fjerne administrator?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {
                                            e.reference.update({'isAdmin': false});
                                            Flushbar(
                                                margin: EdgeInsets.all(10),
                                                borderRadius: BorderRadius.circular(10),
                                                title: 'Administrator',
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 3),
                                                message: 'Administratorrettigheder fjernet',
                                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          },
                                  child: const Text("Fjern administrator", style: TextStyle(color: Colors.red),))],);});
                                        } else {
                                          showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Tilføj administrator"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), content: const Text("Du er ved at tilføje administrator-privilegier til denne bruger."), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {
                                            e.reference.update({'isAdmin': true});
                                            Flushbar(
                                                margin: EdgeInsets.all(10),
                                                borderRadius: BorderRadius.circular(10),
                                                title: 'Administrator',
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 3),
                                                message: 'Administratorrettigheder tilføjet',
                                                flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                              child: const Text("Tilføj administrator", style: TextStyle(color: Colors.red),))],);});
                                        }
                                      }, icon: const Icon(Icons.admin_panel_settings, color: Colors.white,), label: Align(alignment: Alignment.centerLeft, child: e['isAdmin'] == true ? Text("Fjern som administrator", style: TextStyle(color: Colors.white),) : Text("Gør til administrator", style: TextStyle(color: Colors.white),)),)),
                                    ],
                                  ),)));
                              }, child: const Center(child: Text("Rediger Oplysninger"))),
                              SimpleDialogOption(onPressed: (){showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Slet Bruger"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), content: const Text("Er du sikker på at slette brugeren? Handlingen kan ikke fortrydes."), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {
                                usersRef.doc(e.id).delete();
                                FirebaseFirestore.instance.collection(e.id).get().then((snapshot){for(DocumentSnapshot ds in snapshot.docs){ds.reference.delete();}});
                                deleteUser(e.id);
                                Navigator.pop(context);  Navigator.pop(context); Navigator.pop(context);
                                Flushbar(
                                    margin: EdgeInsets.all(10),
                                    borderRadius: BorderRadius.circular(10),
                                    title: 'Bruger',
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                    message: 'Bruger fjernet fra systemet',
                                    flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                                },
                                  child: const Text("SLET BRUGER", style: TextStyle(color: Colors.red),))],);});}, child: const Center(child: Text("SLET BRUGER", style: TextStyle(color: Colors.red),)))],);});}, child: Center(child: Row(children:  [Align(alignment: Alignment.centerLeft, child: Text(e['name'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), const Spacer(), const Align(alignment: Alignment.centerRight, child: Icon(Icons.person, color: Colors.blue,))]),)),),
                    );

                  }).toList(),);
                }
            ),
          ],),

          Container(padding: const EdgeInsets.all(15),),
          Container(margin: const EdgeInsets.only(left: 10, right: 10, bottom: 25), decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent), onPressed: () async {
            var getAuthInfo = await FirebaseFirestore.instance.collection('auth').doc('authInfo').get();
            showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 0,
                backgroundColor: Colors.white,
                title: Text("Kode til oprettelse"),
                content: Text(getAuthInfo.data()!['OTP'].toString()),
                actions: [
                  TextButton(onPressed: (){
                    Clipboard.setData(ClipboardData(text: getAuthInfo.data()!['OTP'].toString()));
                    Flushbar(
                        margin: EdgeInsets.all(10),
                        borderRadius: BorderRadius.circular(10),
                        title: 'Kopier',
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 3),
                        message: 'Kode kopieret til udklipsholderen',
                        flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                    }, child: Text("Kopier"))
                ],
              );
            });
          }, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Oprettelseskode", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.info, color: Colors.blue,))]),)) ,),
        ],
      ),
    );
  }
}

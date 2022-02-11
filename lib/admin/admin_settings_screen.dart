import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/login.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:validators/validators.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminSettingsScreen> {

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
  get getUserInfo => FirebaseFirestore.instance.collection('user').doc(user!.uid);
  User? user = FirebaseAuth.instance.currentUser;

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
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
  void  initState() {
    super.initState();
    setState(() {
    });
  }

  // Display snackbar with provided details
  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  // Register user through auth without logging current user out
  Future<UserCredential> register(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(name: 'Secondary', options: Firebase.app().options);
    try {
      // initialize another app to prevent current user from logging out on creation of a new user
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: password);

      usersRef.doc(userCredential.user?.uid).get().then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists){
          _showSnackBar(context, "Bruger findes allerede!", Colors.red);
        } else if (!documentSnapshot.exists){
          await usersRef.doc(userCredential.user?.uid).set({'email': emailController.text, 'isAdmin':false, 'name': nameController.text, 'phone': phoneController.text});
          _showSnackBar(context, "Bruger oprettet!", Colors.green);
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
      _showSnackBar(context, "Bruger kunne ikke oprettes", Colors.red);
      if (kDebugMode) {
        print(e.toString());
      }
    }
    // making sure the app is killed, even if failed operation above
    await app.delete();
    return FirebaseAuth.instance.currentUser as UserCredential;
  }

  // Delete user with admin sdk cloud function
  Future<void> deleteUser(String uid) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('deleteUser');
    await callable.call(<String, dynamic>{
      'user': uid,
    });
  }

  // update the selected field for a specific user
  updateUserField(String uid, String reference, String field, TextEditingController controller) {
    return Column(
      children: [
        Container(margin:const EdgeInsets.only(right: 10, left: 10, top: 5,bottom: 5), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent), onPressed: () {
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
                          try{updateUserEmail(uid, controller.text); usersRef.doc(uid).update({reference:controller.text}); _showSnackBar(context, "Ny E-mail Gemt", Colors.green); Navigator.pop(context);}on FirebaseAuthException catch(e){if(e.code == 'invalid-email'){_showSnackBar(context, "Ugyldig E-mail", Colors.red);} else {_showSnackBar(context, "Databasefejl ved email!", Colors.red);}}
                        }
                        break;
                        case "password":{
                          try{updateUserPassword(uid, controller.text); _showSnackBar(context, "Ny Adgangskode Gemt", Colors.green); Navigator.pop(context);} catch(e){_showSnackBar(context, "Kunne ikke gemme adgangskode!", Colors.red);}
                        }
                        break;
                        case "phone":{
                          try{usersRef.doc(uid).update({reference:controller.text}); _showSnackBar(context, "Nyt Telefonnummer Gemt", Colors.green); Navigator.pop(context);}catch(e){_showSnackBar(context, "Kunne ikke gemme telefonnummer!", Colors.red);}
                        }
                        break;
                        case "name":{
                          try{usersRef.doc(uid).update({reference:controller.text}); _showSnackBar(context, "Nyt Navn Gemt", Colors.green); Navigator.pop(context);}catch(e){_showSnackBar(context, "Kunne ikke gemme navn!", Colors.red);}
                        }
                        break;
                        }
                      }
                    }, icon: const Icon(Icons.save, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Gem", style: TextStyle(color: Colors.white),)),),),
                  ],
                ),
              ),)));
          }, child: Center(child: Row(children: [Align(alignment: Alignment.centerLeft, child: Text(field, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), const Spacer(), const Align(alignment: Alignment.centerRight, child: Icon(Icons.edit, color: Colors.blue,))]),),),
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
    return ListView(
      padding: const EdgeInsets.only(top: 0),
      children: [
        Container(
          color: Colors.blue,
          margin: const EdgeInsets.only(bottom: 10),
          height: MediaQuery
              .of(context)
              .size
              .height / 3,
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .size
                        .height / 30),
                child: const Center(
                    child: Text(
                      "Administrator Profil",
                      style: TextStyle(color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .size
                        .height / 30),
                child: Center(
                    child: StreamBuilder(
                        stream: getUserInfo.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData){
                            var name = snapshot.data as DocumentSnapshot;
                            return Center(
                                child: Text(name['name'].toString(), style: const TextStyle(color: Colors.white, fontSize: 22),));
                          }
                          return const CircularProgressIndicator.adaptive();
                        }
                    ),),
              ),
            ],
          ),
        ),
        Container(padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20),
          child: const Text("Indstillinger",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),
        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {showContactInfo();}, icon: const Icon(Icons.contact_page, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Mine Oplysninger", style: TextStyle(color: Colors.white),)),style: ButtonStyle(shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.blue)
              )
          )),),),

        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {showSubInfo();}, icon: const Icon(Icons.supervised_user_circle, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Brugere", style: TextStyle(color: Colors.white),)), style: ButtonStyle(shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.blue)
              )
          )),),),


        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Log ud"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: const Text("Er du sikker på at logge ud?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {Navigator.pop(context); await FirebaseAuth.instance.signOut(); _showSnackBar(context, "Logget Ud", Colors.grey); Future.delayed(const Duration(seconds: 2)); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));}, child: const Text("Log Ud"))],);});}, icon: const Icon(Icons.logout, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Log Ud", style: TextStyle(color: Colors.white),)), style: ButtonStyle(shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.blue)
              )
          )),),),



      ],
    );

  }
  Future showContactInfo () => showSlidingBottomSheet(
    context,
    builder: (context) => SlidingSheetDialog(
      duration: const Duration(milliseconds: 450),
      snapSpec: const SnapSpec(
          snappings: [0.4, 0.7, 1], initialSnap: 0.4
      ),
      builder: showContact,
      /////headerBuilder: buildHeader,
      avoidStatusBar: true,
      cornerRadius: 15,
    ),
  );

  Widget showContact(context, state) => Material(
    child: ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 30), child: const Center(child: Text("Mine Oplysninger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),),
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 15, left: 10), child: Align(alignment: Alignment.centerLeft, child: Row(
          children: [
            const Text("Telefonnummer: ", style: TextStyle(fontWeight: FontWeight.bold),),
            StreamBuilder(
                stream: getUserInfo.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    var name = snapshot.data as DocumentSnapshot;
                    return Center(
                        child: Text(name['phone'].toString(), style: const TextStyle(color: Colors.black),));
                  }
                  return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator()));
                }
            ),
          ],
        ),),),
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 10, left: 10), child: Align(alignment: Alignment.centerLeft, child: Row(
          children: [
            const Text("E-mail: ", style: TextStyle(fontWeight: FontWeight.bold),),
            StreamBuilder(
                stream: getUserInfo.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    var name = snapshot.data as DocumentSnapshot;
                    return Center(
                        child: Text(name['email'].toString(), style: const TextStyle(color: Colors.black),));
                  }
                  return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator()));
                }
            ),
          ],
        ),),),
        Container(padding: const EdgeInsets.all(10),),
      ],
    ),
  );

  Future showSubInfo () => showSlidingBottomSheet(
    context,
    builder: (context) => SlidingSheetDialog(
      duration: const Duration(milliseconds: 450),
      snapSpec: const SnapSpec(
          snappings: [0.4, 0.7, 1], initialSnap: 0.4
      ),
      builder: showSub,
      /////headerBuilder: buildHeader,
      avoidStatusBar: true,
      cornerRadius: 15,
    ),
  );

  Widget showSub(context, state) => Material(
    child: ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 30), child: const Center(child: Text("Brugeroplysninger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),),
          Column (children: [
            StreamBuilder(
                stream: usersRef.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData){
                    return SizedBox(height: 50, width: 50, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator()));
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
                              return SimpleDialog(title: const Center(child: Text("Rediger Bruger")),
                                children: [
                                  SimpleDialogOption(onPressed: (){
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => Scaffold(resizeToAvoidBottomInset: false, appBar: AppBar(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                      body: Column(
                                        children: [
                                          Container(padding: const EdgeInsets.only(bottom: 20) , child: const Center(child: Text("Rediger Bruger", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
                                          updateUserField(e.id, 'email', e['email'], emailController),
                                          updateUserField(e.id, 'password', "Adgangskode", passwordController),
                                          updateUserField(e.id, 'phone', e['phone'], phoneController),
                                          updateUserField(e.id, 'name', e['name'],nameController),
                                          Container(height: 50, padding: const EdgeInsets.only(top: 10, left: 10, right: 10), child: ElevatedButton.icon(onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.keyboard_return, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Tilbage", style: TextStyle(color: Colors.white),)),)),
                                      ],
                                      ),)));
                                  }, child: const Center(child: Text("Rediger Oplysninger"))),
                                  SimpleDialogOption(onPressed: (){showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Slet Bruger"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: const Text("Er du sikker på at slette brugeren? Handlingen kan ikke fortrydes."), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {
                                    usersRef.doc(e.id).delete();
                                    FirebaseFirestore.instance.collection(e.id).get().then((snapshot){for(DocumentSnapshot ds in snapshot.docs){ds.reference.delete();}});
                                    deleteUser(e.id);
                                    Navigator.pop(context);  Navigator.pop(context); Navigator.pop(context);
                                    _showSnackBar(context, "Bruger slettet!", Colors.green);},
                                      child: const Text("SLET BRUGER", style: TextStyle(color: Colors.red),))],);});}, child: const Center(child: Text("FJERN BRUGER", style: TextStyle(color: Colors.red),)))],);});}, child: Center(child: Row(children:  [Align(alignment: Alignment.centerLeft, child: Text(e['name'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), const Spacer(), const Align(alignment: Alignment.centerRight, child: Icon(Icons.person, color: Colors.blue,))]),)),),
                        );

                  }).toList(),);
                }
            ),
          ],),
        Container(padding: const EdgeInsets.all(10),),
        Container(margin: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 25), decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))), child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent), onPressed: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Scaffold(resizeToAvoidBottomInset: false, appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
          ),
          body: Form(
            key: _key,
            child: Column(
              children: [
                const Align(alignment: Alignment.topCenter, child: Text('Tilføj Bruger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),)),
                Container(padding: const EdgeInsets.only(top: 50, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: validateEmail, controller:emailController, decoration: const InputDecoration(icon: Icon(Icons.email), hintText: "E-mail", hintMaxLines: 10),) ,)),
                Container(padding: const EdgeInsets.only(top: 20, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: validatePassword, controller:passwordController, obscureText: true, decoration: const InputDecoration(icon: Icon(Icons.password), hintText: "Adgangskode", hintMaxLines: 10),) ,)),
                Container(padding: const EdgeInsets.only(top: 20, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: validateName, controller:nameController, decoration: const InputDecoration(icon: Icon(Icons.drive_file_rename_outline), hintText: "Navn", hintMaxLines: 10),) ,)),
                Container(padding: const EdgeInsets.only(top: 20, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: validatePhone, controller:phoneController, decoration: const InputDecoration(icon: Icon(Icons.phone), hintText: "Telefon", hintMaxLines: 10),) ,)),
                Container(height: 50, width: MediaQuery.of(context).size.width, margin: const EdgeInsets.only(top: 50, left: 20, right: 20), child: ElevatedButton.icon(onPressed: () async {if(_key.currentState!.validate()){try{
                  register(emailController.text, passwordController.text);
                }catch(e){_showSnackBar(context, "Fejl", Colors.red);  if (kDebugMode) {
                  print(e.toString());
                }}}}, icon: const Icon(Icons.person_add, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Tilføj Bruger", style: TextStyle(color: Colors.white),)),),),
              ],
            ),
          ),)));

        }, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Tilføj Bruger", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.person_add, color: Colors.green,))]),)) ,),
      ],
    ),
  );
}


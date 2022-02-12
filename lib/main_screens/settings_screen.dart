import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/login.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:validators/validators.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SettingsScreen> {

  get getUserInfo => FirebaseFirestore.instance.collection('user').doc(user!.uid);
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
  User? user = FirebaseAuth.instance.currentUser;

  final GlobalKey<FormState> _updateInfokey = GlobalKey<FormState>();
  final GlobalKey<FormState> _authUserkey = GlobalKey<FormState>();


  final emailController = TextEditingController();
  final updatedEmailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  String? validatePassword(String? password){
    if (password == null || password.isEmpty){
      return "Indsæt password";
    }
  }

  String? validateEmail(String? email){
    if (email == null || email.isEmpty){
      return "Indsæt e-mail";
    } else if (!email.contains("@") || !email.contains(".")){
      return "Ugyldig e-mail";
    }
  }

  String? validateUpdateField(String reference , String? input){
    switch(reference){
      case "phone": {
        if (isNumeric(input!) == false || input == "" || input.isEmpty){
          return "Telefon skal kun indeholde numre!";
        } else if (input.length < 8 || input.length > 8){
          return "Nummeret skal være 8 cifre langt!";
        }
      }
      break;
      case "email": {
        if (input == null || input.isEmpty){
          return "Indsæt e-mail";
        } else if (!input.contains("@") || !input.contains(".")){
          return "Ugyldig e-mail";
        }
      }
      break;
    }
  }

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
              key: _updateInfokey,
              child: Column(
                children: [
                  Container(padding: const EdgeInsets.only(top: 50, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: (input) => validateUpdateField(reference, controller.text), controller: controller, decoration: InputDecoration(icon: const Icon(Icons.edit), hintText: field, hintMaxLines: 10,),) ,)),
                  Container(height: 50, width: MediaQuery.of(context).size.width, margin: const EdgeInsets.only(top: 50, left: 20, right: 20), child: ElevatedButton.icon(onPressed: () async {
                    final validForm = _updateInfokey.currentState!.validate();
                    if (validForm){
                      switch(reference){
                        case "phone":{
                          try{usersRef.doc(uid).update({reference:controller.text}); _showSnackBar(context, "Nyt Telefonnummer Gemt", Colors.green); Navigator.pop(context);}catch(e){_showSnackBar(context, "Kunne ikke gemme telefonnummer!", Colors.red);}
                        }
                        break;
                        case "email":{
                          showDialog(context: context, builder: (BuildContext context){
                            emailController.clear();
                            return Form(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              key: _authUserkey,
                              child: AlertDialog(title: const Text("Autentificer konto"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: const Text("Du bedes indtaste din gamle E-mail og adgangskode for at komme videre."), actions: [
                              TextFormField(validator: validateEmail, controller: emailController, decoration: const InputDecoration(icon: Icon(Icons.email), hintText: "E-mail", hintMaxLines: 10,),),
                              TextFormField(validator: validatePassword, controller: passwordController, obscureText: true, decoration: const InputDecoration(icon: Icon(Icons.password), hintText: "Adgangskode", hintMaxLines: 10,),),
                              TextButton(onPressed: () async {
                                if (_authUserkey.currentState!.validate()){
                                  try{
                                  /*AuthCredential credential = EmailAuthProvider.credential(email: emailController.text, password: passwordController.text);
                                  await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);*/
                                    await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                                  _showSnackBar(context, "Autentificering godkendt", Colors.green);
                                  FirebaseAuth.instance.currentUser?.updateEmail(controller.text);
                                  usersRef.doc(uid).update({reference:controller.text}); _showSnackBar(context, "Ny E-mail Gemt!", Colors.green); Navigator.pop(context); Navigator.pop(context);
                                  }
                                  on FirebaseAuthException catch(e){if(e.code == "wrong-password"){_showSnackBar(context, "Forkert adgangskode!", Colors.red);} else if (e.code == "invalid-email"){ _showSnackBar(context, "Forkert E-mail!", Colors.red);} else if (e.code == "user-not-found"){_showSnackBar(context, "Bruger eksisterer ikke!", Colors.red);} else { _showSnackBar(context, "Fejlkode " + e.code, Colors.red);}}
                                }
                              }, child: const Text("Godkend")),
                          ],),
                            );});
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
                      "Profil",
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
                          return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator()));
                        }
                    ),),
              ),
            ],
          ),
        ),
        Container(padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20),
          child: const Text("Indstillinger",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),),

        const Divider(thickness: 1, height: 1),

        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 20),
          child: ElevatedButton.icon(onPressed: () {showContactInfo();}, icon: const Icon(Icons.contact_page, color: Colors.white), label: const Align(alignment: Alignment.centerLeft, child: Text("Mine Oplysninger", style: TextStyle(color: Colors.white),)), style: ButtonStyle(shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.blue)
              )
          )),),),

        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          child: ElevatedButton.icon(onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Log ud"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: const Text("Er du sikker på at logge ud?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {Navigator.pop(context); await FirebaseAuth.instance.signOut(); _showSnackBar(context, "Logget Ud", Colors.grey); Future.delayed(const Duration(seconds: 2)); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));}, child: const Text("Log Ud"))],);});}, icon: const Icon(Icons.logout, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Log Ud", style: TextStyle(color: Colors.white),)),style: ButtonStyle(shape: MaterialStateProperty.all(
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

  Widget buildHeader(BuildContext context, SheetState state) => Material(child: Stack(children: <Widget>[Container(height: MediaQuery.of(context).size.height / 3 , color: Colors.blue,),Positioned(bottom: 20, child: SizedBox(width: MediaQuery.of(context).size.width, height: 40, child: Image.network("https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", height: 59, fit: BoxFit.contain)))],),);

  Widget showContact(context, state) => Material(
    child: ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.only(bottom: 20), child: const Center(child: Text("Mine Oplysninger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),),),
            Container(padding: const EdgeInsets.only(bottom: 20), child: Center(child: TextButton(onPressed: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Scaffold(resizeToAvoidBottomInset: false, appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const BackButton(color: Colors.black),
              ),
                body: Column(
                  children: [
                    Container(padding: const EdgeInsets.only(bottom: 20, top: 20) , child: const Center(child: Text("Rediger Bruger", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
                    updateUserField(user!.uid, 'phone', "Telefon", phoneController),
                    updateUserField(user!.uid, 'email', "E-mail", updatedEmailController),
                  ],
                ),)));
            }, child: const Text("Rediger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),),),),
          ],
        ),
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(bottom: 15, left: 10), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.only(bottom: 5), child: const Text("Telefonnummer", style: TextStyle(color: Colors.grey),)),
            StreamBuilder(
                stream: getUserInfo.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    var name = snapshot.data as DocumentSnapshot;
                    return Align(
                      alignment: Alignment.centerLeft,
                        child: Text(name['phone'].toString(), style: const TextStyle(color: Colors.black),));
                  }
                  return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator()));
                }
            ),
          ],
        ),),
        Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.only(left: 10), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.only(bottom: 5), child: const Text("E-mail", style: TextStyle(color: Colors.grey),)),
            StreamBuilder(
                stream: getUserInfo.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    var name = snapshot.data as DocumentSnapshot;
                    return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(name['email'].toString(), style: const TextStyle(color: Colors.black),));
                  }
                  return SizedBox(height: 10, width: 10, child: Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator()));
                }
            ),
          ],
        ),),

          StreamBuilder(
              stream: getUserInfo.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData){
                  var name = snapshot.data as DocumentSnapshot;
                  return Container(padding: const EdgeInsets.all(3), child: Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () async {showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(title: const Text("Nulstil Adgangskode"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text("Du er ved at nulstille din adgangskode. En e-mail vil blive sendt til " + name['email'] + " med yderligere instrukser."), actions: [
                      TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,
                      TextButton(onPressed: () async {await FirebaseAuth.instance.sendPasswordResetEmail(email: name['email']); Navigator.pop(context); Navigator.pop(context); _showSnackBar(context, "E-mail sendt!", Colors.green);}, child: const Text("Send E-mail", style: TextStyle(color: Colors.green),))],);});},
                      child: const Text("Nulstil Adgangskode"))));
                }
                return Container();
              }
          ),
      ],
    ),
  );
}


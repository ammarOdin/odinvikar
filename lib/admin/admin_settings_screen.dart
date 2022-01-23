import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/login.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:validators/validators.dart';

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


  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool validName = false;
  bool validPhone = false;

  @override
  void  initState() {
    super.initState();
  }

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
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
    }
  }
  String? validatePassword(String? password){
    if (password == null || password.isEmpty || password == ""){
      return "Ugyldig password";
    } else if (password.length < 6){
      return "Password skal indeholde mindst 6 tegn!";
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
          child: ElevatedButton.icon(onPressed: () {showContactInfo();}, icon: const Icon(Icons.contact_page, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Mine Oplysninger", style: TextStyle(color: Colors.white),)),),),

        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {showSubInfo();}, icon: const Icon(Icons.supervised_user_circle, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Brugere", style: TextStyle(color: Colors.white),)),),),


        Container(
          height: 50,
          width: 150,
          margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
          //padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10, bottom: MediaQuery.of(context).size.height / 40),
          child: ElevatedButton.icon(onPressed: () {showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: const Text("Log ud"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: const Text("Er du sikker på at logge ud?"), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("Annuller")) ,TextButton(onPressed: () async {Navigator.pop(context); await FirebaseAuth.instance.signOut(); _showSnackBar(context, "Logget Ud", Colors.grey); Future.delayed(const Duration(seconds: 2)); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));}, child: const Text("Log Ud"))],);});}, icon: const Icon(Icons.logout, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Log Ud", style: TextStyle(color: Colors.white),)),),),



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
                                      leading: const BackButton(color: Colors.black),
                                    ),
                                      body: Column(
                                        children: [
                                          const Align(alignment: Alignment.topCenter, child: Text('Rediger Bruger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),)),
                                          //Container(padding: const EdgeInsets.only(top: 50, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(controller:emailController, decoration: const InputDecoration(icon: Icon(Icons.email), hintText: "E-mail", hintMaxLines: 10),) ,)),
                                          Container(padding: const EdgeInsets.only(top: 50, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(controller:nameController, decoration:  InputDecoration(icon: const Icon(Icons.drive_file_rename_outline), labelText: e['name'], errorText: validateName(nameController.text),)) ,)),
                                          Container(padding: const EdgeInsets.only(top: 20, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(controller:phoneController, decoration: InputDecoration(icon: const Icon(Icons.phone), labelText: e['phone'], errorText: validatePhone(phoneController.text),)) ,)),
                                          Container(height: 50, width: MediaQuery.of(context).size.width, margin: const EdgeInsets.only(top: 50, left: 20, right: 20), child: ElevatedButton.icon(onPressed: () async {if (validName && validPhone == true){try {usersRef.doc(e.id).set({'email':e['email'], 'isAdmin':false, 'name':nameController.text, 'phone': phoneController.text}); _showSnackBar(context, "Bruger Gemt", Colors.green); Navigator.pop(context);} on FirebaseAuthException catch(e){_showSnackBar(context, "Fejl", Colors.red);}}}, icon: const Icon(Icons.save, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Gem", style: TextStyle(color: Colors.white),)),),),
                                        ],
                                      ),)));
                                  }, child: const Center(child: Text("Rediger Oplysninger"))),
                                  SimpleDialogOption(onPressed: (){Navigator.pop(context);}, child: const Center(child: Text("FJERN BRUGER", style: TextStyle(color: Colors.red),)))],);});}, child: Center(child: Row(children:  [Align(alignment: Alignment.centerLeft, child: Text(e['name'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), const Spacer(), const Align(alignment: Alignment.centerRight, child: Icon(Icons.person, color: Colors.blue,))]),)) ,),
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
                Container(padding: const EdgeInsets.only(top: 20, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: validateEmail, controller:passwordController, decoration: const InputDecoration(icon: Icon(Icons.password), hintText: "Password", hintMaxLines: 10),) ,)),
                Container(padding: const EdgeInsets.only(top: 20, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: validateName, controller:nameController, decoration: const InputDecoration(icon: Icon(Icons.drive_file_rename_outline), hintText: "Navn", hintMaxLines: 10),) ,)),
                Container(padding: const EdgeInsets.only(top: 20, left: 15, right: 20), child: Align(alignment: Alignment.center, child: TextFormField(validator: validatePhone, controller:phoneController, decoration: const InputDecoration(icon: Icon(Icons.phone), hintText: "Telefon", hintMaxLines: 10),) ,)),
                Container(height: 50, width: MediaQuery.of(context).size.width, margin: const EdgeInsets.only(top: 50, left: 20, right: 20), child: ElevatedButton.icon(onPressed: () async {if(_key.currentState!.validate()){try{
                  FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);

                }catch(e){_showSnackBar(context, "Fejl", Colors.red);}}}, icon: const Icon(Icons.person_add, color: Colors.white,), label: const Align(alignment: Alignment.centerLeft, child: Text("Tilføj Bruger", style: TextStyle(color: Colors.white),)),),),
              ],
            ),
          ),)));

        }, child: Align(alignment: Alignment.centerLeft, child: Row(children: const [Align(alignment: Alignment.centerLeft, child: Text("Tilføj Bruger", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),)), Spacer(), Align(alignment: Alignment.centerRight, child: Icon(Icons.person_add, color: Colors.green,))]),)) ,),
      ],
    ),
  );
}


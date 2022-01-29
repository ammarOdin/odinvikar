import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';


class AdminContactScreen extends StatefulWidget {
  const AdminContactScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminContactScreen> with TickerProviderStateMixin {

  get users => FirebaseFirestore.instance.collection('user');
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List> getInfo() async {
    List<String> phoneNr = [];
    QuerySnapshot usersSnapshot = await usersRef.get();
    for (var users in usersSnapshot.docs){
      if(users.get(FieldPath(const ['isAdmin']))==false){
        phoneNr.add(users.get(FieldPath(const['phone']))+users.get(FieldPath(const['name'])));
      }
    }
    return phoneNr;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 0),
      shrinkWrap: true,
      children: [
        Container(
          color: Colors.blue,
          height: MediaQuery.of(context).size.height / 3,
          child: ListView(
            children: [
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 20),
                  child: const Center(
                      child: Text(
                        "Kontakter",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
            ],
          ),
        ),
        FutureBuilder(future: getInfo(), builder: (context, AsyncSnapshot<List> snapshot){
          if (!snapshot.hasData){
            return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(50),
              child: const Center(child: Text(
                "Ingen Kontakter",
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),),
            );
          }
          return Container(
            padding: EdgeInsets.only(top:20),
            child: Column(
              children: snapshot.data!.map<Widget>((document){
                return Column(children: [
                  CardFb2(text: document.substring(8), imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "Opkald/SMS", onPressed: (){
                    showDialog(context: context, builder: (BuildContext context){
                      return SimpleDialog(title: const Center(child: Text("Kontakt"),), children: [
                        SimpleDialogOption(onPressed: (){}, child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("Opkald") , icon: const Icon(Icons.phone), onPressed: (){launch("tel:" + document.substring(0,8));},), ),),
                        SimpleDialogOption(onPressed: (){}, child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("SMS") , icon: const Icon(Icons.message), onPressed: (){launch("sms:" + document.substring(0,8));},), ),),
                      ],);
                    });
                  }),
                ],);
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}


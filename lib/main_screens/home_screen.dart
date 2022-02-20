import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:week_of_year/week_of_year.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<HomeScreen> with TickerProviderStateMixin {

  User? user = FirebaseAuth.instance.currentUser;
  get shift => FirebaseFirestore.instance.collection(user!.uid).orderBy('month', descending: false).orderBy('date', descending: false);
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener((){
      /*if (kDebugMode) {
        print('my index is '+ _controller.index.toString());
      }*/
      setState(() {
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      //physics: const NeverScrollableScrollPhysics(),
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
                      top: MediaQuery.of(context).size.height / 30),
                  child: const Center(
                      child: Text(
                        "Vagt Oversigt",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 40),
                  child: Center(
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(DateTime.now()),
                      style: const TextStyle(color: Colors.white, fontSize: 26),
                    ),
                  )
              ),
            ],
          ),
        ),
        Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(controller: _controller, tabs: const [Tab(text: "Uge",), Tab(text: "Måned",)])),
        StreamBuilder(
            stream: shift.snapshots() ,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator());
              }else if (snapshot.data!.docs.isEmpty){
                return Container(
                  padding: const EdgeInsets.all(50),
                  child: const Center(child: Text(
                    "Ingen Vagter",
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),),
                );
              }
              if (_controller.index == 0){
                return Column(
                  children: snapshot.data!.docs.map((document){
                    if (document['week'] == DateTime.now().weekOfYear) {
                      return CardFb2(text: "Vagt: " + document['date'], imageUrl: "assets/aula-logo.jpg", subtitle: " Se Mere", onPressed: () {
                        showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: Text("Vagt: " + document['date']), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: const Text("Du har sat dig selv til rådighed på valgte dato. Dette betyder ikke at du er garanteret vagten. Du vil blive kontaktet såfremt vagten er din."), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK"))],);});
                      });
                    } else {
                      return Container();
                    }
                  }).toList(),
                );
              } else if (_controller.index == 1){
                return Column(
                  children: snapshot.data!.docs.map((document){
                    var docDate = DateFormat('dd-MM-yyyy').parse(document['date']).add(const Duration(days: 1));
                    if (document['month'] == DateTime.now().month && DateTime.now().isBefore(docDate)) {
                      return CardFb2(text: "Vagt: " + document['date'], imageUrl: "assets/aula-logo.jpg", subtitle: "Se Mere", onPressed: () {
                        showDialog(context: context, builder: (BuildContext context){return AlertDialog(title: Text("Vagt: " + document['date']), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: const Text("Du har sat dig selv til rådighed på valgte dato. Dette betyder ikke at du er garanteret vagten. Du vil blive kontaktet såfremt vagten er din."), actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK"))],);});

                      });
                    } else {
                      return Container();
                    }
                  }).toList(),
                );
              } else {
                return Container();
              }
            }),
      ],
    );
  }
}


class CardFb2 extends StatelessWidget {
  final String text;
  final String imageUrl;
  final String subtitle;
  final Function() onPressed;

  const CardFb2(
      {required this.text,
        required this.imageUrl,
        required this.subtitle,
        required this.onPressed,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 75,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                offset: const Offset(5, 5),
                blurRadius: 15,
                color: Colors.grey.withOpacity(.5)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 60, height: 40, child: Image.asset(imageUrl, height: 59, fit: BoxFit.cover))),
            const SizedBox(
              width: 15,
            ),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            const Spacer(),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );

  }


}

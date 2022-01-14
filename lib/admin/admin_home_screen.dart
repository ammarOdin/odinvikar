import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminHomeScreen> with TickerProviderStateMixin {

  get users => FirebaseFirestore.instance.collection('user');
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
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

  Future<List> getData() async {
    List<String> userID = [];
    List<String> userID2 = [];
    QuerySnapshot usersSnapshot = await usersRef.get();
    for (var users in usersSnapshot.docs){
      CollectionReference shiftRef = FirebaseFirestore.instance.collection(users.id);
      QuerySnapshot shiftSnapshot = await shiftRef.get();
      for (var shifts in shiftSnapshot.docs){
        if (shifts.id == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
          if (kDebugMode) {
            print([shifts.data()]+[users.id]);
          }
          userID.add(users.get(FieldPath(const ['name'])));
        } else if (shifts.id == DateFormat('dd-MM-yyyy').format(DateTime.now().add(const Duration(days: 1)))){
          userID2.add(users.get(FieldPath(const ['name'])));
        }
      }
    }
    if (_controller.index == 0){
      return userID;
    } else if (_controller.index == 1){
      return userID2;
    }
    return [];
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
                        "Vikar Oversigt",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
              Center(
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 40),
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  )
                ),
              ),
            ],
          ),
        ),
        Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(controller: _controller, tabs: const [Tab(text: "I dag",), Tab(text: "I Morgen",)])),

        FutureBuilder(future: getData(), builder: (context, AsyncSnapshot<List> snapshot){
          if (!snapshot.hasData){
            return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(50),
              child: const Center(child: Text(
                "Ingen Vikarer",
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting){
            return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: const LinearProgressIndicator());

          }
          return Column(children: snapshot.data!.map<Widget>((e) => CardFb2(text: e, imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "", onPressed: () {}),
          ).toList());
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
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.5),
          boxShadow: [
            BoxShadow(
                offset: const Offset(10, 20),
                blurRadius: 10,
                spreadRadius: 0,
                color: Colors.grey.withOpacity(.05)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 60, height: 40, child: Image.network(imageUrl, height: 59, fit: BoxFit.cover))),
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

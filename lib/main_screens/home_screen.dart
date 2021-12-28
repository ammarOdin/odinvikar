import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:week_of_year/week_of_year.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<HomeScreen> with TickerProviderStateMixin {

  get shift => FirebaseFirestore.instance.collection('shift').orderBy('date', descending: false);
  late TabController _controller;


  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener((){
      /*if (kDebugMode) {
        print('my index is '+ _controller.index.toString());
      }*/
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
                        "Næste mulige vagt",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 40),
                child: StreamBuilder(
                  stream: shift.snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData){
                      return const Center(child: CircularProgressIndicator(),);
                    } else if (snapshot.data!.docs.isEmpty){
                      return const Center(child: Text(
                        "Ingen Tilgængelige",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),);
                    } else {return Center(
                        child: snapshot.data!.docs.map((document){
                          return Text(
                            document['date'],
                            style: const TextStyle(color: Colors.white, fontSize: 26),
                          );
                        }).first);}
                  }
                ),
              ),
            ],
          ),
        ),

        TabBar(controller: _controller, tabs: const [Tab(text: "1",), Tab(text: "2",)]),

        StreamBuilder(
            stream: shift.snapshots() ,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData){
                return const Center(child: CircularProgressIndicator(),);
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
                      return CardFb2(text: "Vikar - " + document['date'], imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "", onPressed: () {});
                    } else {
                      return Container();
                    }
                  }).toList(),
                );
              } else if (_controller.index == 1){
                return Column(
                  children: snapshot.data!.docs.map((document){
                    if (document['month'] == DateTime.now().month) {
                      return CardFb2(text: "Vikar - " + document['date'], imageUrl: "https://katrinebjergskolen.aarhus.dk/media/23192/aula-logo.jpg?anchor=center&mode=crop&width=1200&height=630&rnd=132022572610000000", subtitle: "", onPressed: () {});
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

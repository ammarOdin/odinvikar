import 'package:flutter/material.dart';

class OwnDaysDetailsScreen extends StatefulWidget {
  const OwnDaysDetailsScreen({Key? key}) : super(key: key);

  @override
  State<OwnDaysDetailsScreen> createState() => _OwnDaysDetailsScreenState();
}

class _OwnDaysDetailsScreenState extends State<OwnDaysDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Vagt detaljer"),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white,),),
      ),
      body: ListView(

        children: [

        ],
      ),
    );
  }
}

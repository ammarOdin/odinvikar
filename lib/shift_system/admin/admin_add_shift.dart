import 'package:flutter/material.dart';

class AdminAddShiftScreen extends StatefulWidget {
  const AdminAddShiftScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddShiftScreen> createState() => _AdminAddShiftScreenState();
}

class _AdminAddShiftScreenState extends State<AdminAddShiftScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: kToolbarHeight + 2,
        leading: const BackButton(color: Colors.white,),
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 7,
            padding: EdgeInsets.only(bottom: 30),
            color: Colors.blue,
            child: ListView(
              padding: EdgeInsets.only(top: 20),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Center(
                  child: Text("Tilføj Vagt", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
                ),
              ],
            ),
          ),




        ],
      ),
    );
  }
}

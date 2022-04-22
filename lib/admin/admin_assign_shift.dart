import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class AssignShiftScreen extends StatefulWidget {
  final DateTime date;
  final String token;
  const AssignShiftScreen({Key? key, required this.date, required this.token}) : super(key: key);

  @override
  State<AssignShiftScreen> createState() => _AssignShiftScreenState();
}

class _AssignShiftScreenState extends State<AssignShiftScreen> {

  Future<void> sendAssignedShiftNotification(String token, String date) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('addShiftNotif');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      leading: BackButton(color: Colors.white),
    ),
    body: ListView(
      physics: ClampingScrollPhysics(),
      padding: const EdgeInsets.only(top: 0),
      shrinkWrap: true,
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 5,
          padding: EdgeInsets.only(bottom: 30),
          color: Colors.blue,
          child: ListView(
            padding: EdgeInsets.only(top: 40),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: Text("Tildel vagt", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class AssignShiftScreen extends StatefulWidget {
  final String date;
  final String token;
  final CollectionReference<Map<String, dynamic>> userRef;
  const AssignShiftScreen({Key? key, required this.date, required this.token, required this.userRef}) : super(key: key);

  @override
  State<AssignShiftScreen> createState() => _AssignShiftScreenState();
}

class _AssignShiftScreenState extends State<AssignShiftScreen> {

  late TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = TimeOfDay(hour: 9, minute: 0);

  final commentController = TextEditingController();
  final GlobalKey<FormState> _commentKey = GlobalKey<FormState>();


  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  String? validateComment(String? input){
    if (input!.contains(new RegExp(r'^[#$^*():{}|<>]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    } else {
      return null;
    }
  }

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
          height: MediaQuery.of(context).size.height / 4,
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
        Container(
          padding: EdgeInsets.only(top: 30, bottom: 20),
          child: Row(
            children: [
              TextButton.icon(onPressed: null, icon: Icon(Icons.access_time), label: Text("Varighed")),
              const Spacer(),
              SizedBox(
                width: 200,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 5),
                        child: Column(
                          children: [
                            Container(padding: EdgeInsets.only(bottom: 5), child: Text("Fra")),
                            Container(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white
                              ),
                              child: TextButton(onPressed: () async {
                                startTime = (await showTimePicker(initialTime: startTime, context: context))!;
                                setState(() {
                                  startTime.format(context);
                                  //startTimeList.replaceRange(0, 1, [start.format(context)]);
                                });
                              },
                                child: Text(startTime.format(context)),),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Column(
                          children: [
                            Container(padding: EdgeInsets.only(bottom: 5), child: Text("Til")),
                            Container(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white
                              ),
                              child: TextButton(onPressed: () async {
                                endTime = (await showTimePicker(initialTime: endTime, context: context))!;
                                setState(() {
                                  endTime.format(context);
                                  //endTimeList.replaceRange(0, 1, [end.format(context)]);
                                });
                              },
                                child: Text(endTime.format(context)),),
                            ),
                          ],
                        ),
                      ),

                    ],),
                ),
              ),
            ],
          ),
        ),

        Container(
            padding: EdgeInsets.only(top: 10),
            child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: null, icon: Icon(Icons.add_comment_outlined), label: Text("Kommentar")))),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: MediaQuery.of(context).viewInsets.bottom),
          //height: MediaQuery.of(context).size.height / 5,
          child: Form(
            key: _commentKey,
            child: TextFormField(
              controller: commentController,
              validator: validateComment,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 0.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue, width: 1)),
              ),
            ),
          ),),

        Container(
            padding: EdgeInsets.all(15),
            height: 100,
            margin: EdgeInsets.only(left: 50, right: 50, top: 30),
            child: ElevatedButton.icon(
                style: ButtonStyle(shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Colors.blue)
                    )
                )),
                onPressed: () async {
                  if (_commentKey.currentState!.validate()){
                    try{
                      await widget.userRef.doc(widget.date).update({
                        'status': 'Afventer accept',
                        'isAccepted': true,
                        'color': '0xFFFF0000',
                        'details': startTime.format(context) + "-" + endTime.format(context) + "\nDetaljer: " + commentController.text,
                        'awaitConfirmation': 1});
                      Navigator.pop(context);Navigator.pop(context);
                      sendAssignedShiftNotification(widget.token, widget.date.toString());
                      _showSnackBar(context,"Vagt tildelt", Colors.green);
                    } catch (e) {
                      _showSnackBar(context, "Fejl", Colors.red);
                    }
                  }
                },
                icon: Icon(Icons.add_circle),
                label: Text("Tildel vagt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),))),
      ],
    ),
    );
  }
}

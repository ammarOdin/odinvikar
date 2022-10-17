import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class AdminEditShiftScreen extends StatefulWidget {
  final String date;
  final String token;
  final String name;
  final CollectionReference<Map<String, dynamic>> userRef;
  const AdminEditShiftScreen({Key? key, required this.date, required this.token, required this.userRef, required this.name}) : super(key: key);

  @override
  State<AdminEditShiftScreen> createState() => _EditShiftScreenState();
}

class _EditShiftScreenState extends State<AdminEditShiftScreen> {

  late TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = TimeOfDay(hour: 9, minute: 0);

  final commentController = TextEditingController();
  final GlobalKey<FormState> _commentKey = GlobalKey<FormState>();

  String? validateComment(String? input){
    if (input!.contains(new RegExp(r'^[#$^*():{}|<>]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    } else {
      return null;
    }
  }

  Future<void> sendEditedShiftNotification(String token, String date) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('editShiftNotif');
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
        toolbarHeight: kToolbarHeight + 2,
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20,),)
      ),
      body: ListView(
        //physics: ClampingScrollPhysics(),
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
                  child: Text(widget.name + "'s "+ "vagt \n", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
                ),
                Center(
                  child: Text("Dato: "+widget.date, style: TextStyle(fontSize: 18, color: Colors.white),),
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 20, left: 10, bottom: 10),
              child: Text("Indtast nye oplysninger", style:TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),)
          ),

          const Divider(thickness: 1),
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
              padding: EdgeInsets.only(top: 50, left: 15, right: 15),
              height: 100,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                    primary: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    List <String> stateUpdater = [];
                    var comment = commentController.text;
                    if (commentController.text == "" || commentController.text.isEmpty){
                      comment = "Ingen";
                    }
                    if (_commentKey.currentState!.validate()){
                      try{
                        await widget.userRef.doc(widget.date).update({
                          'details': startTime.format(context) + "-" + endTime.format(context) + "\n\nDetaljer: " + comment,
                          'color': "0xFFFF0000",
                          'awaitConfirmation': 1,
                          'status': "Afventer accept"
                        });
                        stateUpdater.add(startTime.format(context) + "-" + endTime.format(context) + "\n\nDetaljer: " + comment);
                        stateUpdater.add("1");
                        stateUpdater.add('Afventer accept');
                        stateUpdater.add('0xFFFF0000');
                        Navigator.pop(context, stateUpdater);
                        sendEditedShiftNotification(widget.token, widget.date.toString());
                        Flushbar(
                            margin: EdgeInsets.all(10),
                            borderRadius: BorderRadius.circular(10),
                            title: 'Vagt',
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                            message: 'Vagt redigeret',
                            flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                      } catch (e) {
                        Flushbar(
                            margin: EdgeInsets.all(10),
                            borderRadius: BorderRadius.circular(10),
                            title: 'Vagt',
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                            message: 'En fejl opstod. Prøv igen',
                            flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                      }
                    }
                  },
                  icon: Icon(Icons.edit_outlined),
                  label: Text("Rediger vagt", style: TextStyle(fontSize: 18),))),
        ],
      ),
    );
  }
}

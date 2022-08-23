import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EditShiftScreen extends StatefulWidget {
  final String date;
  final String details;
  final CollectionReference<Map<String, dynamic>> userRef;
  const EditShiftScreen({Key? key, required this.date, required this.userRef, required this.details}) : super(key: key);

  @override
  State<EditShiftScreen> createState() => _EditShiftScreenState();
}

class _EditShiftScreenState extends State<EditShiftScreen> {

  bool isSwitched = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: kToolbarHeight + 2,
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20,),)
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3.5,
            padding: EdgeInsets.only(bottom: 30),
            color: Colors.blue,
            child: ListView(
              padding: EdgeInsets.only(top: 40),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Center(
                  child: Text("Rediger vagt \n", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
                ),
                Center(
                  child: Text("Dato: "+widget.date + "\n" + "Tidsrum: " + widget.details, style: TextStyle(fontSize: 18, color: Colors.white),),
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
            padding: EdgeInsets.only(top: 10, bottom: 20),
            child: Row(
              children: [
                TextButton.icon(onPressed: null, icon: Icon(Icons.access_time), label: Text("Varighed")),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: SwitchListTile(
                    title: const Text("Hele dagen"),
                    value: isSwitched,
                    onChanged: (bool value) {
                      setState((){
                        isSwitched = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isSwitched == false) Container(
            padding: EdgeInsets.only(top: 30, bottom: 20),
            child: Row(
              children: [
                TextButton.icon(onPressed: null, icon: Icon(Icons.timelapse), label: Text("Tidsrum")),
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
          ) else Container(),


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
              height: 80,
              width: 250,
              margin: EdgeInsets.only(top: 20),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                    primary: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    List<String> stateUpdater = [];
                    var comment = commentController.text;
                    var timeRange = '';
                    var starting = startTime.format(context);
                    var ending = endTime.format(context);

                    if (isSwitched == false){
                      timeRange = '$starting - $ending';
                    } else if (isSwitched == true){
                      timeRange = 'Hele dagen';
                    }
                    if (commentController.text == "" || commentController.text.isEmpty){
                      comment = "Ingen";
                    }

                    if (_commentKey.currentState!.validate()){
                      try{
                        await widget.userRef.doc(widget.date).update({
                          'time': timeRange,
                          'comment': comment
                        });
                        stateUpdater.add(timeRange); stateUpdater.add(comment);
                        Navigator.pop(context, stateUpdater);
                        showTopSnackBar(context, CustomSnackBar.success(message: "Vagt redigeret",),);
                      } catch (e) {
                        showTopSnackBar(context, CustomSnackBar.error(message: "En fejl opstod. Prøv igen",),);
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

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          elevation: 3,
          centerTitle: false,
          backgroundColor: Colors.blue,
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          title: Text("Rediger vagt", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),),
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20,),)
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
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
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () async {
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
                        Flushbar(
                            margin: EdgeInsets.all(10),
                            borderRadius: BorderRadius.circular(10),
                            title: 'Vagt',
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                            message: 'Ændringer gemt',
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
                  child: Text("Gem redigering", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white)),
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(const Size(130, 50)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                      elevation: MaterialStateProperty.all(3),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                  ),),
              ],
            ),),
        ],
      ),
    );
  }
}

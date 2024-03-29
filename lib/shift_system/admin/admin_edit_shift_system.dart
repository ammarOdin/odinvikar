import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AdminEditShiftSystemScreen extends StatefulWidget {
  final String date, docID, comment;
  const AdminEditShiftSystemScreen({Key? key, required this.date, required this.docID, required this.comment}) : super(key: key);

  @override
  State<AdminEditShiftSystemScreen> createState() => _EditShiftScreenState();
}

class _EditShiftScreenState extends State<AdminEditShiftSystemScreen> {

  late TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = TimeOfDay(hour: 9, minute: 0);
  bool isSwitched = false;

  final commentController = TextEditingController();
  final GlobalKey<FormState> _commentKey = GlobalKey<FormState>();
  late String comment;

  String? validateComment(String? input){
    if (input!.contains(new RegExp(r'^[#$^*():{}|<>]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    } else {
      return null;
    }
  }

  @override
  void initState(){
    comment = widget.comment;
    super.initState();
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
          title: Text("Rediger vagt", style: TextStyle(color: Colors.white),),
          toolbarHeight: kToolbarHeight + 2,
          leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20,),)
      ),
      body: ListView(
        //physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
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
            padding: EdgeInsets.only(top: 30, bottom: 20),
            child: Row(
              children: [
                TextButton.icon(onPressed: null, icon: Icon(Icons.warning_amber_outlined), label: Text("Speciel")),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: SwitchListTile(
                    title: const Text("Akut vagt"),
                    value: isSwitched,
                    onChanged: (bool value) {
                      setState((){
                        isSwitched = value;
                      });
                    },
                  ),
                )
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
                    var acute = isSwitched ? true : false;
                    var comment = commentController.text;
                    if (commentController.text == "" || commentController.text.isEmpty){
                      comment = widget.comment;
                    } else {
                      comment = commentController.text;
                    }
                    if (_commentKey.currentState!.validate()){
                      try{
                        await FirebaseFirestore.instance.collection('shifts').doc(widget.docID).update({
                          'time': startTime.format(context) + "-" + endTime.format(context),
                          'isAcute' : acute,
                          'comment': comment
                        });
                        stateUpdater.add(startTime.format(context) + "-" + endTime.format(context));
                        stateUpdater.add(isSwitched ? true.toString() : false.toString());
                        stateUpdater.add(comment);
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

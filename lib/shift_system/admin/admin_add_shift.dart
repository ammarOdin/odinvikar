import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/date_week_extensions.dart';


class AdminAddShiftScreen extends StatefulWidget {
  const AdminAddShiftScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddShiftScreen> createState() => _AssignShiftScreenState();
}

class _AssignShiftScreenState extends State<AdminAddShiftScreen> {

  late TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = TimeOfDay(hour: 9, minute: 0);
  bool isSwitched = false;
  late DateTime? _pickedDay = DateTime.now();



  final commentController = TextEditingController();
  final GlobalKey<FormState> _commentKey = GlobalKey<FormState>();
  final databaseReference = FirebaseFirestore.instance;


  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  Future<void> sendAddedShiftNotification(String token, String date) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('shiftCreated');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date
    });
  }

  DateTime initialDate() {
    if (DateTime.now().weekday == DateTime.saturday){
      return DateTime.now().add(const Duration(days: 2));
    } else if (DateTime.now().weekday == DateTime.sunday){
      return DateTime.now().add(const Duration(days: 1));
    } else {
      return DateTime.now();

    }
  }

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
        title: Text("Tilføj vagt"),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20,),),
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.only(top: 40, bottom: 10),
            child: Row(
              children: [
                TextButton.icon(onPressed: null, icon: Icon(Icons.date_range), label: Text("Dato")),
                const Spacer(),
                Container(
                  padding: EdgeInsets.only(right: 20),
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(color: Colors.blue)
                        )
                    )),
                    onPressed: () async {
                      _pickedDay = (await showDatePicker(
                          locale : const Locale("da","DA"),
                          selectableDayPredicate: (DateTime val) => val.weekday == 6 || val.weekday == 7 ? false : true,
                          context: context,
                          confirmText: "Vælg dag",
                          cancelText: "Annuller",
                          initialDate: initialDate(),
                          firstDate: initialDate(),
                          lastDate: DateTime.now().add(const Duration(days: 90))))!;
                      setState(() {
                        _pickedDay;
                      });
                    }, child: Text('${DateFormat('dd-MM-yyyy').format(_pickedDay!)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),),
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
              padding: EdgeInsets.only(top: 50, right: 15, left: 15),
              height: 100,
              width: 250,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    var comment = commentController.text;
                    if (commentController.text == "" || commentController.text.isEmpty){
                      comment = "Ingen";
                    }
                    final f = DateFormat('dd-MM-yyyy');
                    var pickedDate = f.format(_pickedDay!);
                    var acute = isSwitched ? true : false;
                    var pickedMonth = _pickedDay?.month;
                    var pickedWeek = _pickedDay?.weekOfYear;

                    var timeRange = startTime.format(context) + "-" + endTime.format(context);


                    if (_commentKey.currentState!.validate()){
                      try{
                        FirebaseFirestore.instance.collection('shifts').doc().set({
                          'awaitConfirmation': 0,
                          'color': '0xFFFFA500',
                          'comment': comment,
                          'date': pickedDate,
                          'month': pickedMonth,
                          'week': pickedWeek,
                          'isAcute': acute,
                          'isTaken': false,
                          'status': 'Tilgængelig',
                          'time': timeRange,
                          'userID': '',
                          'name': '',
                          'token': ''
                        });
                        Navigator.pop(context);
                        // send notification to all users that shift has been added
                        var userRef = await databaseReference.collection('user').get();
                        for (var users in userRef.docs){
                          if (users.get(FieldPath(const ["isAdmin"])) == false){
                            sendAddedShiftNotification(users.get(FieldPath(const ["token"])), pickedDate);
                          }
                        }
                        _showSnackBar(context,"Vagt tilføjet", Colors.green);
                      } catch (e) {
                        _showSnackBar(context, "Fejl" + e.toString(), Colors.red);
                      }
                    }
                  },
                  icon: Icon(Icons.add_circle_outline),
                  label: Text("Tilføj vagt", style: TextStyle(fontSize: 18),))),

          Container(
            padding: EdgeInsets.all(15),
            child: Text("Ved at tilføje denne vagt, gør du den tilgængelig for alle vikarer. "
                "En vikar vil byde på den, og du skal derefter acceptere buddet før vagten godkendes.",
            style: TextStyle(color: Colors.grey),),
          ),
        ],
      ),
    );
  }
}

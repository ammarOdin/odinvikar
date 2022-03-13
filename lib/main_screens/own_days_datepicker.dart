import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/date_week_extensions.dart';



class OwnDaysDatepicker extends StatefulWidget {
  const OwnDaysDatepicker({Key? key}) : super(key: key);

  @override
  State<OwnDaysDatepicker> createState() => _OwnDaysDatepickerState();
}

class _OwnDaysDatepickerState extends State<OwnDaysDatepicker> {

  get saveShift => FirebaseFirestore.instance.collection(user!.uid);
  User? user = FirebaseAuth.instance.currentUser;

  bool isSwitched = false;
  late DateTime? _pickedDay = initialDate();
  String _startDropDownValue = "8:00";
  String _endDropDownValue = "9:00";

  final commentController = TextEditingController();
  final GlobalKey<FormState> _commentKey = GlobalKey<FormState>();

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
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
      //resizeToAvoidBottomInset: false,
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
                  height: MediaQuery.of(context).size.height / 5,
                  padding: EdgeInsets.only(bottom: 30),
                  color: Colors.blue,
                  child: Center(
                    child: Text("Tilføj Dag", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
                  ),
                ),
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
                        }, child: Text('${DateFormat('dd-MM-yyyy').format(_pickedDay!)}'),),
                      ),
                    ],
                  ),
                ),

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
                if (isSwitched == false) Center(child: Column(
                  children: [
                    Row(children: [
                      Column(
                          children: [
                            Container(padding: EdgeInsets.only(bottom: 5), child: Text("Fra")),
                            Container(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/10, right: MediaQuery.of(context).size.width/20),
                              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/10, right: MediaQuery.of(context).size.width/20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  value: _startDropDownValue,
                                    items: <String>['8:00', '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue){
                                    setState(() {
                                      _startDropDownValue = newValue!;
                                    });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(padding: EdgeInsets.only(bottom: 5), child: Text("Til")),
                            Container(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/10, right: MediaQuery.of(context).size.width/20),
                              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/20, right: MediaQuery.of(context).size.width/20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    value: _endDropDownValue,
                                    items: <String>['9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue){
                                      setState(() {
                                        _endDropDownValue = newValue!;
                                      });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],),

                ],)) else Container(),

                Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: null, icon: Icon(Icons.add_comment_outlined), label: Text("Kommentar"))),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: MediaQuery.of(context).viewInsets.bottom),
                  //height: MediaQuery.of(context).size.height / 5,
                  child: Form(
                    key: _commentKey,
                    child: TextFormField(
                      controller: commentController,
                      validator: validateComment,
                      decoration: InputDecoration(
                          //contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 10, horizontal: 10),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 0.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue, width: 1)),
                      ),
                    ),
                  ),),

                  //Spacer(),
                  Container(
                      padding: EdgeInsets.all(15),
                      height: 100,
                      margin: EdgeInsets.only(left: 50, right: 50, top: 10),
                      child: ElevatedButton.icon(
                          style: ButtonStyle(shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: const BorderSide(color: Colors.blue)
                              )
                          )),
                          onPressed: () async {
                            final f = DateFormat('dd-MM-yyyy');
                            var pickedDate = f.format(_pickedDay!);
                            var pickedMonth = _pickedDay?.month;
                            var pickedWeek = _pickedDay?.weekOfYear;
                            var timeRange = '';
                            var comment = commentController.text;

                            if (commentController.text == "" || commentController.text.isEmpty){
                              comment = "Ingen";
                            }

                            if (isSwitched == false){
                               timeRange = '$_startDropDownValue - $_endDropDownValue';
                            } else if (isSwitched == true){
                              timeRange = 'Hele dagen';
                            }
                            saveShift.doc(pickedDate).get().then((DocumentSnapshot documentSnapshot) async {
                              if (documentSnapshot.exists) {
                                _showSnackBar(context, "Vagten findes allerede!", Colors.red);
                              } else if (!documentSnapshot.exists && _commentKey.currentState!.validate()){
                                try{
                                  await saveShift.doc(pickedDate).set({'date': pickedDate,'month': pickedMonth, 'week': pickedWeek, 'time': timeRange, 'comment': comment});
                                  saveShift.get();
                                  _showSnackBar(context, "Vagt Tilføjet", Colors.green);
                                  Navigator.pop(context);

                                } catch (e) {
                                  _showSnackBar(context, "Fejl ved oprettelse", Colors.red);
                                }
                              }
                            });
                          },
                          icon: Icon(Icons.add_circle),
                          label: Text("Tilføj Dag", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),))),

              ]
          ),
      );
  }
}

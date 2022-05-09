import 'package:flutter/material.dart';

class AdminAddShiftScreen extends StatefulWidget {
  const AdminAddShiftScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddShiftScreen> createState() => _AssignShiftScreenState();
}

class _AssignShiftScreenState extends State<AdminAddShiftScreen> {

  late TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = TimeOfDay(hour: 9, minute: 0);
  bool isSwitched = false;


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
                    List <String> stateUpdater = [];
                    var comment = commentController.text;
                    if (commentController.text == "" || commentController.text.isEmpty){
                      comment = "Ingen";
                    }
                    if (_commentKey.currentState!.validate()){
                      try{
                        /*await widget.userRef.doc(widget.date).update({
                          'status': 'Afventer accept',
                          'isAccepted': true,
                          'color': '0xFFFF0000',
                          'details': startTime.format(context) + "-" + endTime.format(context) + "\n\nDetaljer: " + comment,
                          'awaitConfirmation': 1});
                        stateUpdater.add(startTime.format(context) + "-" + endTime.format(context) + "\n\nDetaljer: " + comment);
                        stateUpdater.add('Afventer accept');
                        stateUpdater.add('0xFFFF0000');
                        stateUpdater.add("1");
                        Navigator.pop(context, stateUpdater);
                        sendAssignedShiftNotification(widget.token, widget.date.toString());
                        _showSnackBar(context,"Vagt tildelt", Colors.green);*/
                      } catch (e) {
                        _showSnackBar(context, "Fejl", Colors.red);
                      }
                    }
                  },
                  icon: Icon(Icons.add_circle_outline),
                  label: Text("Tilføj vagt", style: TextStyle(fontSize: 18),))),
        ],
      ),
    );
  }
}

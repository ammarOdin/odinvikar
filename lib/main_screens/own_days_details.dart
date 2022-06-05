import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'edit_shift_screen.dart';

class OwnDaysDetailsScreen extends StatefulWidget {
  final String date, status, time, comment, color;
  final String? details;
  final QueryDocumentSnapshot<Map<String, dynamic>> data;
  final int awaitConfirmation;
  const OwnDaysDetailsScreen({Key? key, required this.date, required this.status, required this.time, required this.comment,
    required this.awaitConfirmation, this.details, required this.color,  required this.data}) : super(key: key);

  @override
  State<OwnDaysDetailsScreen> createState() => _OwnDaysDetailsScreenState();
}

class _OwnDaysDetailsScreenState extends State<OwnDaysDetailsScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  final databaseReference = FirebaseFirestore.instance;

  late String time;
  late String comment;
  late String timeRange;

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];

  late TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = TimeOfDay(hour: 9, minute: 0);


  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }

  Future<void> sendAcceptedShiftNotification(String token, String date, String name) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('acceptShiftNotif');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date,
      'name': name,
    });
  }

  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
  }

  @override
  void initState() {
    time = widget.time;
    timeRange = widget.details!.substring(0,11);
    comment = widget.comment;
    super.initState();
  }

  Future<List> getShiftDetails() async {
    List shift = [];
    //TODO fetch api data from IST Tabulex for the current user (check for name etc.)
    /*for (var i = 0; i < 6; i++){
      shift.add(Container(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            Container(
              color: Colors.grey,
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
              margin: EdgeInsets.only(left: 5),
              child: Text("09:00\n12:00"),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Text("MAT Vikar"),
                ),
                Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Text("5B (22)"),
                ),
              ],
            ),
          ],
        ),
      ),);
    }*/
    return shift;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Vagt detaljer"),
        actions: [
          IconButton(onPressed: () async {
            if (widget.awaitConfirmation != 0){
              Fluttertoast.showToast(
                  msg: "En vagt er allerede tildelt. Du kan ikke redigere dagen.",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            } else {
              var userRef = await databaseReference.collection(user!.uid);
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditShiftScreen(date: widget.date, userRef: userRef, details: widget.time)));
              setState(() {
                time = result[0];
                comment = result[1];
              });
            }
          }, icon: Icon(Icons.edit_calendar_outlined, color: Colors.white,)),
        ],
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white,),),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          // Date
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.only(right: 10, left: 5),
                      child: Icon(Icons.date_range_outlined, color: Colors.grey,)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                          child: Text("Dato", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                      Container(child: Text(getDayOfWeek(DateFormat('dd-MM-yyyy').parse(widget.date))
                          + ", " + widget.date.substring(0,2)
                          + " " + months[DateFormat('dd-MM-yyyy').parse(widget.date).month.toInt() - 1]
                          + " " + widget.date.substring(6), style: TextStyle(color: Colors.grey),))
                    ],
                  ),
                ],
              ),
          ),
          // Status
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child: Icon(Icons.warning_amber_outlined, color: Colors.grey,)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text("Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(child: Text(widget.status, style: TextStyle(color: Color(int.parse(widget.color)), fontWeight: FontWeight.w500),)),
                    if (widget.awaitConfirmation == 1) Container(
                      padding: EdgeInsets.only(top: 10),
                      height: 35,
                      //width: 100,
                      child: ElevatedButton.icon(
                          onPressed: () async {
                            await widget.data.reference.update({"awaitConfirmation": 2, 'status': "Godkendt vagt", 'color' : '0xFF4CAF50'});
                            Navigator.pop(context);
                            _showSnackBar(context, "Vagt accepteret", Colors.green);
                            var adminRef = await databaseReference.collection('user').get();
                            var userNameRef = await databaseReference.collection('user').doc(user!.uid).get();
                            for (var admins in adminRef.docs){
                              if (admins.get(FieldPath(const ["isAdmin"])) == true){
                                sendAcceptedShiftNotification(admins.get(FieldPath(const ["token"])), widget.date, userNameRef.get(FieldPath(const ["name"])));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 16),
                            primary: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.check, color: Colors.white, size: 14,),
                          label: Text("Accepter", style: TextStyle(fontSize: 14),)),
                    ) else Container(),
                  ],
                ),

                // Accept button

              ],
            ),
          ),
          // Time
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child: Icon(Icons.access_time_outlined, color: Colors.grey,)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text("Kan arbejde", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(child: Text(time, style: TextStyle(color: Colors.grey),))
                  ],
                )
              ],
            ),
          ),
          // Comment
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child: Icon(Icons.comment_outlined, color: Colors.grey,)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text("Egen kommentar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(
                        width: MediaQuery.of(context).size.width/1.2,
                        child: Text(comment, style: TextStyle(color: Colors.grey),))
                  ],
                )
              ],
            ),
          ),

          if (widget.awaitConfirmation == 1 || widget.awaitConfirmation == 2) Container(
            padding: EdgeInsets.only(top: 20),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Center(
                  child: Text("Vagtoplysninger", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                ),
                // Timerange
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 10, left: 5),
                          child: Icon(Icons.access_time_outlined, color: Colors.grey,)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text("Tidsrum", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                          Container(child: Text(timeRange, style: TextStyle(color: Colors.grey),))
                        ],
                      )
                    ],
                  ),
                ),
                // Details
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 10, left: 5),
                          child: Icon(Icons.comment_outlined, color: Colors.grey,)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text("Detaljer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                          Container(
                              width: MediaQuery.of(context).size.width/1.2,
                              child: Text(widget.details!.substring(22), style: TextStyle(color: Colors.grey),))
                        ],
                      )
                    ],
                  ),
                ),

                /*Container(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 10, left: 5),
                          child: Icon(Icons.school_outlined, color: Colors.grey,)),
                      Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text("Lokalefordeling", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),)),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: getShiftDetails(), builder: (context, AsyncSnapshot<List> snapshot){
                  if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting){
                    return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitFoldingCube(
                      color: Colors.blue,
                      size: 50,
                    ));
                  } else if (snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.only(left: 50),
                      child: Text(
                        "Intet at vise",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),);
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index){
                        var shiftCard = snapshot.data?[index];
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              shiftCard
                            ],
                          ),
                        );
                      }
                  );
                }),*/
              ],
            ),
          ) else Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 50),
            height: 100,
            width: 250,
            child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(title: Text("Slet dag"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      content: Text("Er du sikker på at slette dagen?"),
                      actions: [TextButton(onPressed: () {widget.data.reference.delete(); Navigator.pop(context); Navigator.pop(context);  _showSnackBar(context, "Vagt slettet", Colors.green);}
                          , child: const Text("SLET", style: TextStyle(color: Colors.red),))],); });
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.delete_outline, color: Colors.white, size: 18,),
                label: Text("Slet dag")),
          ),
          if (widget.status == "Tilkaldt") Container(
            //padding: EdgeInsets.only(left: 10),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    children: [
                      TextButton.icon(onPressed: null, icon: Icon(Icons.timelapse), label: Text("Timer")),
                      const Spacer(),
                      SizedBox(
                        width: 300,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
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
                              ),
                              Flexible(
                                child: Container(
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
                              ),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(top: 10),
                                  child: ElevatedButton.icon(onPressed: (){
                                    showDialog(context: context, builder: (BuildContext context){
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                        elevation: 0,
                                        title: Text("Gem timer"),
                                        content: Text("Du er ved at gemme dine timer."),
                                        actions: [
                                          TextButton(onPressed: () async {
                                            await widget.data.reference.update({'details': startTime.format(context) + "-" + endTime.format(context) + "\n\nDetaljer: Ingen",});
                                            setState((){
                                              timeRange = startTime.format(context) + "-" + endTime.format(context);
                                            });
                                            Navigator.pop(context);
                                            _showSnackBar(context, "Tidsrum gemt", Colors.green);
                                          }, child: Text("GEM", style: TextStyle(color: Colors.green),))
                                        ],
                                      );
                                    });
                                  }, icon: Icon(Icons.save), label: Text("Gem"), ),
                                ),
                              ),
                            ],),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text("Du har mulighed for at indskrive dine timer, hvis du er blevet tilkaldt. Således kan timerne inkluderes inde under 'Mine timer'.", style: TextStyle(color: Colors.grey, fontSize: 14),)),
              ],
            ),
          ) else Container()
        ],
      ),
    );
  }
}

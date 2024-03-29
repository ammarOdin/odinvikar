import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:odinvikar/admin/admin_assign_shift.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin_edit_shift.dart';

class AdminShiftDetailsScreen extends StatefulWidget {
  final String date, status, time, comment, color, name, token;
  final String? details;
  final DocumentReference<Map<String, dynamic>> data;
  final CollectionReference<Map<String, dynamic>> userRef;
  final int awaitConfirmation;
  const AdminShiftDetailsScreen({Key? key, required this.date, required this.status, required this.time, required this.comment, required this.color,
    this.details, required this.data, required this.awaitConfirmation, required this.name, required this.token, required this.userRef}) : super(key: key);

  @override
  State<AdminShiftDetailsScreen> createState() => _AdminShiftDetailsScreenState();
}

class _AdminShiftDetailsScreenState extends State<AdminShiftDetailsScreen> {
  final databaseReference = FirebaseFirestore.instance;

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];

  late String status;
  late String? details ;
  late String color ;
  late String number;
  late String awaitConfirmation ;
  bool isChecked = false;

  Future<void> sendSummonedUser(String token, String date) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('summonedUser');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date
    });
  }

  Future<void> sendCanceledShift(String token, String date) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('cancelledShift');
    await callable.call(<String, dynamic>{
      'token': token,
      'date': date
    });
  }


  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
  }

  @override
  void initState() {
    status = widget.status;
    details = widget.details;
    color = widget.color;
    awaitConfirmation = widget.awaitConfirmation.toString();
    FirebaseFirestore.instance.collection('user').doc(widget.userRef.id).get().then((value) {
      number = value['phone'];
    });
    super.initState();
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
        title: Text("${widget.name}'s vagt",  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white,),),
        actions: [
          PopupMenuButton(
              icon: Icon(Icons.phone),
              itemBuilder: (context){
            return[
              PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Colors.blue,),
                      Padding(padding: EdgeInsets.only(left: 10),),
                      Text("Opkald", style: TextStyle(color: Colors.black)),
                    ],
                  )
              ),
              PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.message, color: Colors.blue,),
                      Padding(padding: EdgeInsets.only(left: 10),),
                      Text("SMS", style: TextStyle(color: Colors.black)),
                    ],
                  )
              ),
            ];
          },
            onSelected: (value) async {
              if (value == 0){
                launch("tel:" + number);
              } else if (value == 1){
                launch("sms:" + number);
              }
          }
          )
        ],
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
                    Container(child: Text(status, style: TextStyle(color: Color(int.parse(color)), fontWeight: FontWeight.w500),))
                  ],
                )
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
                    Container(child: Text(widget.time, style: TextStyle(color: Colors.grey),))
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
                        child: Text(widget.comment, style: TextStyle(color: Colors.grey),))
                  ],
                )
              ],
            ),
          ),

          if (awaitConfirmation == "1" || awaitConfirmation == "2") Container(
            padding: EdgeInsets.only(top: 20),
            child: ListView(
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
                          Container(child: Text(details!.substring(0,11), style: TextStyle(color: Colors.grey),))
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
                              child: Text(details!.substring(22), style: TextStyle(color: Colors.grey),))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ) else Container(),

          // Assign/Delete shift button
          if (awaitConfirmation == "0") Container(
            padding: EdgeInsets.only(left: 5, top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Assign
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20, left: 5, right: 5),
                  margin: EdgeInsets.only(left: 5),
                  height: 80,
                  width: MediaQuery.of(context).size.width / 2.1,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AssignShiftScreen(date: widget.date, token: widget.token, userRef: widget.userRef)));
                        setState(() {
                          details = result[0];
                          status = result[1];
                          color = result[2];
                          awaitConfirmation = result[3];
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 14),
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.add, color: Colors.white, size: 18,),
                      label: Text("Tildel vagt")),
                ),

                // Summoned
               /* Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  height: 80,
                  width: MediaQuery.of(context).size.width / 3.1,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        showDialog(context: context, builder: (BuildContext context){
                          return AlertDialog(title: Text("Tilkaldt vikar"),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            content: Text("Du har tilkaldt vikaren telefonisk, og status på vikaren ændres. Denne handling kan ikke fortrydes."),
                            actions: [TextButton(onPressed: () async {
                              await widget.userRef.doc(widget.date).update({
                                'status': 'Tilkaldt',
                                'isAccepted': true,
                                'color': '0xFF4CAF50',
                                'awaitConfirmation': 2,
                                'details' : "Tilkaldt              Ingen"
                              });
                              sendSummonedUser(widget.token, widget.date);
                              setState(() {
                                status = "Tilkaldt";
                                color = "0xFF4CAF50";
                                awaitConfirmation = "2";
                                details = "Tilkaldt              Ingen";
                              });
                              Navigator.pop(context); Navigator.pop(context);
                              Flushbar(
                                  margin: EdgeInsets.all(10),
                                  borderRadius: BorderRadius.circular(10),
                                  title: 'Vagt',
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                  message: 'Vikar status ændret',
                                  flushbarPosition: FlushbarPosition.BOTTOM).show(context);
                              }
                                , child: const Text("SKIFT STATUS", style: TextStyle(color: Colors.blue),))],); });
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 14),
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.add_ic_call, color: Colors.white, size: 18,),
                      label: Text("Tilkald")),
                ),*/
              ],
            ),
          ) else Container(
            padding: EdgeInsets.only(left: 2),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 2, right: 2),
                  width: MediaQuery.of(context).size.width / 2.1,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        Dialogs.bottomMaterialDialog(
                            msg: "Du er ved at slette vagten. Dagen vil blive gjort tilgængelig igen",
                            title: 'Slet vagt',
                            context: context,
                            actions: [
                              IconsOutlineButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                text: 'Annuller',
                                iconData: Icons.cancel_outlined,
                                textStyle: TextStyle(color: Colors.grey),
                                iconColor: Colors.grey,
                              ),
                              IconsButton(
                                onPressed: () async {
                                  widget.data.update({
                                    'isAccepted': false,
                                    'color': '0xFFFFA500',
                                    'status': 'Tilgængelig',
                                    'awaitConfirmation': 0,
                                    'details': FieldValue.delete(),
                                  });
                                  sendCanceledShift(widget.token, widget.date);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Flushbar(
                                      margin: EdgeInsets.all(10),
                                      borderRadius: BorderRadius.circular(10),
                                      title: 'Vagt',
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                      message: 'Vikar status ændret til tilgængelig',
                                      flushbarPosition: FlushbarPosition.BOTTOM).show(context);

                                },
                                text: 'Slet',
                                iconData: Icons.delete,
                                color: Colors.red,
                                textStyle: TextStyle(color: Colors.white),
                                iconColor: Colors.white,
                              ),
                            ]);
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.delete_outline, color: Colors.white, size: 18,),
                      label: Text("Slet vagt")),
                ),
                /*Container(
                  padding: EdgeInsets.only(left: 2, right: 2),
                  width: MediaQuery.of(context).size.width / 3.1,
                  child: ElevatedButton.icon(onPressed: () async {
                    Dialogs.bottomMaterialDialog(
                        msg: "Du er ved at afbooke vagten. " + widget.name + " vil blive gjort tilgængelig igen.",
                        title: 'Afbook vagt',
                        context: context,
                        actions: [
                          IconsOutlineButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: 'Annuller',
                            iconData: Icons.cancel_outlined,
                            textStyle: TextStyle(color: Colors.grey),
                            iconColor: Colors.grey,
                          ),
                          IconsButton(
                            onPressed: () async {
                              widget.data.update({
                                'isAccepted': false,
                                'color': '0xFFFFA500',
                                'status': 'Tilgængelig',
                                'awaitConfirmation': 0,
                                'details': FieldValue.delete(),
                              });
                              sendCanceledShift(widget.token, widget.date);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Flushbar(
                                  margin: EdgeInsets.all(10),
                                  borderRadius: BorderRadius.circular(10),
                                  title: 'Vagt',
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                  message: 'Vikar status ændret til tilgængelig',
                                  flushbarPosition: FlushbarPosition.BOTTOM).show(context);

                            },
                            text: 'Afbok',
                            iconData: Icons.remove_circle_outline,
                            color: Colors.blue,
                            textStyle: TextStyle(color: Colors.white),
                            iconColor: Colors.white,
                          ),
                        ]);
                  },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.remove_circle_outline, color: Colors.white, size: 18,), label: Text("Afbook")),
                ),*/
                Container(
                  padding: EdgeInsets.only(left: 2, right: 2),
                  width: MediaQuery.of(context).size.width / 2.1,
                  child: ElevatedButton.icon(onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminEditShiftScreen(date: widget.date, userRef: widget.userRef, name: widget.name, token: widget.token)));
                    setState(() {
                      details = result[0];
                      awaitConfirmation = result[1];
                      status = result[2];
                      color = result[3];
                    });
                  },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                        primary: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.edit_outlined, color: Colors.white, size: 18,), label: Text("Rediger")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

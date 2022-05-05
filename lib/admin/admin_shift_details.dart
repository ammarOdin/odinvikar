import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:odinvikar/admin/admin_assign_shift.dart';
import 'package:odinvikar/shift_system%20%5Binactive%5D/admin/admin_add_shift.dart';

import 'admin_edit_shift.dart';

class AdminShiftDetailsScreen extends StatefulWidget {
  final String date, status, time, comment, color, name, token;
  final String? details;
  final QueryDocumentSnapshot<Map<String, dynamic>> data;
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


  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }


  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.name + "'s vagt"),
        actions: [
          IconButton(onPressed: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminEditShiftScreen(date: widget.date, userRef: widget.userRef, name: widget.name, token: widget.token))).then((value) {
              setState(() {

              });});
          }, icon: Icon(Icons.edit_calendar_outlined, color: Colors.white,))
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
                    Container(child: Text(widget.status, style: TextStyle(color: Color(int.parse(widget.color)), fontWeight: FontWeight.w500),))
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

          if (widget.awaitConfirmation == 1 || widget.awaitConfirmation == 2) Container(
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
                          Container(child: Text(widget.details!.substring(0,11), style: TextStyle(color: Colors.grey),))
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
              ],
            ),
          ) else Container(),

          // Accept button
          if (widget.awaitConfirmation == 0) Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 50, top: 50),
                height: 100,
                child: ElevatedButton.icon(
                    onPressed: () async {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(title: Text("Slet dag"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          content: Text("Du er ved at slette dagen. Handlingen kan ikke fortrydes."),
                          actions: [TextButton(onPressed: () {widget.data.reference.delete(); Navigator.pop(context); Navigator.pop(context); _showSnackBar(context, "Vagt slettet", Colors.green);}
                              , child: const Text("SLET", style: TextStyle(color: Colors.red),))],); });
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: Icon(Icons.delete_outline, color: Colors.white, size: 18,),
                    label: Text("Slet vagt")),
              ),
              Container(
                padding: EdgeInsets.only(left: 20, top: 50),
                height: 100,
                child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AssignShiftScreen(date: widget.date, token: widget.token, userRef: widget.userRef))).then((value) {
                        setState(() {

                        });});
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: Icon(Icons.check, color: Colors.white, size: 18,),
                    label: Text("Tildel vagt")),
              ),
            ],
          ) else Container(
            padding: EdgeInsets.only(left: 70, right: 70, top: 50),
            height: 100,
            child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(title: Text("Slet dag"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      content: Text("Du er ved at slette dagen. Handlingen kan ikke fortrydes."),
                      actions: [TextButton(onPressed: () {widget.data.reference.delete(); Navigator.pop(context); Navigator.pop(context); _showSnackBar(context, "Vagt slettet", Colors.green);}
                          , child: const Text("SLET", style: TextStyle(color: Colors.red),))],); });
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: Icon(Icons.delete_outline, color: Colors.white, size: 18,),
                label: Text("Slet vagt")),
          ),

        ],
      ),
    );
  }
}
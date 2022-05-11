import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'admin_edit_shift_system.dart';

class AdminShiftSystemDetailsScreen extends StatefulWidget {
  final String date, status, time, comment, color, data;
  final String?  name, token;
  final CollectionReference<Map<String, dynamic>> userRef;
  final int awaitConfirmation;
  const AdminShiftSystemDetailsScreen({Key? key, required this.date, required this.status, required this.time, required this.comment, required this.color,
    required this.data, required this.awaitConfirmation, this.name, this.token, required this.userRef}) : super(key: key);

  @override
  State<AdminShiftSystemDetailsScreen> createState() => _AdminShiftDetailsScreenState();
}

class _AdminShiftDetailsScreenState extends State<AdminShiftSystemDetailsScreen> {
  final databaseReference = FirebaseFirestore.instance;

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];

  late String status;
  late String color ;
  late String awaitConfirmation ;

  void _showSnackBar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color,));
  }


  String getDayOfWeek(DateTime date){
    Intl.defaultLocale = 'da';
    return DateFormat('EEEE').format(date);
  }

  @override
  void initState() {
    status = widget.status;
    color = widget.color;
    awaitConfirmation = widget.awaitConfirmation.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Udbudt vagt"),
        actions: [
          IconButton(onPressed: () async {
            if (awaitConfirmation != "2"){
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminEditShiftSystemScreen(date: widget.date, userRef: widget.userRef, name: widget.name!, token: widget.token!)));
              setState(() {
                awaitConfirmation = result[1];
                status = result[2];
                color = result[3];
              });
            } else {
              Fluttertoast.showToast(
                  msg: "Du kan ikke redigere en booket vagt.",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            }
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
                        child: Text("Tidsrum", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
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
                        child: Text("Kommentar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(
                        width: MediaQuery.of(context).size.width/1.2,
                        child: Text(widget.comment, style: TextStyle(color: Colors.grey),))
                  ],
                )
              ],
            ),
          ),

          // Display name of user who booked the shift
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
                          child: Icon(Icons.person_outline, color: Colors.grey,)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text("Taget af", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                          Container(child: Text(widget.name!, style: TextStyle(color: Colors.grey),))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ) else Container(),

          // Delete shift button
          Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 50),
            height: 100,
            width: 250,
            child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(title: Text("Slet dag"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      content: Text("Du er ved at slette dagen. Handlingen kan ikke fortrydes."),
                      actions: [TextButton(onPressed: () {
                        FirebaseFirestore.instance.collection('shifts').doc(widget.data).delete(); Navigator.pop(context); Navigator.pop(context); _showSnackBar(context, "Vagt slettet", Colors.green);
                        }
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
                label: Text("Slet vagt")),
          ),

        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ShiftSystemDetailsScreen extends StatefulWidget {
  final String date, status, time, comment, color, data;
  final bool acute;
  final String?  name, token;
  final int awaitConfirmation;
  const ShiftSystemDetailsScreen({Key? key, required this.date, required this.status, required this.time, required this.comment, required this.color,
    required this.data, required this.awaitConfirmation, required this.acute, this.name, this.token}) : super(key: key);

  @override
  State<ShiftSystemDetailsScreen> createState() => _ShiftDetailsScreenState();
}

class _ShiftDetailsScreenState extends State<ShiftSystemDetailsScreen> {
  final databaseReference = FirebaseFirestore.instance;

  List months =
  ['Januar', 'Februar', 'Marts', 'April', 'Maj','Juni','Juli','August','September','Oktober','November','December'];

  late String status, color, awaitConfirmation, time, comment;
  late bool acute;
  User? user = FirebaseAuth.instance.currentUser;
  get users => FirebaseFirestore.instance.collection("user");

  Future<void> sendShiftNotification(String token, String date, String name) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('shiftOfferNotif');
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
    status = widget.status;
    acute = widget.acute;
    color = widget.color;
    comment = widget.comment;
    awaitConfirmation = widget.awaitConfirmation.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Udbudt vagt"),
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
          // if shift is acute
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child: Icon(Icons.work_outline, color: Colors.grey,)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text("Vagttype", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(child: Text(acute? "AKUT" : "IKKE-AKUT", style: TextStyle(color: acute?  Colors.red : Colors.blue, fontWeight: FontWeight.bold),))
                  ],
                )
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
                        child: Text("Kommentar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    Container(
                        width: MediaQuery.of(context).size.width/1.2,
                        child: Text(comment, style: TextStyle(color: Colors.grey),))
                  ],
                )
              ],
            ),
          ),

          if (awaitConfirmation == "1") Container(
            padding: EdgeInsets.only(top: 20),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Text("Vagtoplysninger", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                ),
                // Booked person name
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
                              child: Text("Vagt status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                          Container(child: Text("Optaget af " + widget.name!, style: TextStyle(color: Colors.grey),))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ) else Container(),

          if (awaitConfirmation == "0")Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 50),
                height: 100,
                width: 250,
                child: ElevatedButton.icon(
                    onPressed: () async {
                      // get reference to the current user document where it contains all relevant information
                      var userReference = await FirebaseFirestore.instance.collection('user').doc(user!.uid).get();
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(title: Text("Ledig vagt"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          content: Text("Du er ved at byde på vagten. Handlingen kan ikke fortrydes. Kan du alligevel ikke arbejde, bedes du kontakte din chef."),
                          actions: [TextButton(onPressed: () async {
                            FirebaseFirestore.instance.collection('shifts').doc(widget.data).update({
                              'status': 'Afventer accept',
                              'color': '0xFFFF0000',
                              'userID': user!.uid,
                              'isTaken': true,
                              'awaitConfirmation': 1,
                              'name': userReference.data()!['name'],
                              'token': userReference.data()!['token']
                            });
                            // send notification that shift has been taken by a user, to all admins
                            var userRef = await databaseReference.collection('user').get();
                            for (var admins in userRef.docs){
                              if (admins.get(FieldPath(const ["isAdmin"])) == true){
                                sendShiftNotification(admins.get(FieldPath(const ["token"])), widget.date, userReference.data()!['name']);
                              }
                            }
                            Navigator.pop(context); Navigator.pop(context);
                            showTopSnackBar(context, CustomSnackBar.success(message: "Budt på vagt afsendt",),);
                          }
                              , child: const Text("BYD PÅ VAGT", style: TextStyle(color: Colors.green),))],); });
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.work_outline, color: Colors.white, size: 18,),
                    label: Text("Byd på vagt")),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Text("Ved at byde på denne vagt, gør du dig tilgængelig for arbejde. "
                    "Din arbejdsgiver vil acceptere dit bud, og vagten bliver din.",
                  style: TextStyle(color: Colors.grey),),
              )
            ],
          ) else Container(),
        ],
      ),
    );
  }
}

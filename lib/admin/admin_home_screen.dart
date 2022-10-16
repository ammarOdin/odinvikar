import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:odinvikar/admin/admin_edit_shift.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../assets/card_assets.dart';
import 'admin_assign_shift.dart';
import 'admin_shift_details.dart';


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AdminHomeScreen> with TickerProviderStateMixin {

  get users => FirebaseFirestore.instance.collection('user');
  final databaseReference = FirebaseFirestore.instance;
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener((){
      /*if (kDebugMode) {
        print('my index is '+ _controller.index.toString());
      }*/
      setState(() {
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  Future<List> getUserInfo() async {
    var userRef = await databaseReference.collection('user').get();
    List<String> entireShift = [];
    List<Slidable> todayList = [];
    List<Slidable> tomorrowList = [];

    for (var users in userRef.docs){
      var shiftRef;
      if (_controller.index == 0){
        shiftRef = await databaseReference.collection(users.id).
        where("date", isEqualTo: DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()).get();
      } else if (_controller.index == 1){
        shiftRef = await databaseReference.collection(users.id).
        where("date", isEqualTo: DateFormat('dd-MM-yyyy').format(DateTime.now().add(Duration(days: 1))).toString()).get();
      }

      for (var shifts in shiftRef.docs){
        if (shifts.data()['awaitConfirmation'].toString() != "0"){
          entireShift.add(shifts.data()['date'] + ";"
              + shifts.data()['status'] + ";"
              + shifts.data()['color'] + ";"
              + shifts.data()['time'] + ";"
              + shifts.data()['comment'] + ";"
              + users.get(FieldPath(const ['phone'])) + ";"
              + users.get(FieldPath(const ['name'])) + ";"
              + users.get(FieldPath(const ['token'])) + ";"
              + users.id + ";"
              + shifts.data()['awaitConfirmation'].toString() + ";"
              + shifts.data()['details'] + ";"
          );
        } else if (shifts.data()['awaitConfirmation'].toString() == "0") {
          entireShift.add(shifts.data()['date'] + ";"
              + shifts.data()['status'] + ";"
              + shifts.data()['color'] + ";"
              + shifts.data()['time'] + ";"
              + shifts.data()['comment'] + ";"
              + users.get(FieldPath(const ['phone'])) + ";"
              + users.get(FieldPath(const ['name'])) + ";"
              + users.get(FieldPath(const ['token'])) + ";"
              + users.id + ";"
              + shifts.data()['awaitConfirmation'].toString() + ";"
          );
        }
      }
    }

    for (var shifts in entireShift){
      List shiftSplit = shifts.split(";");
      if (shiftSplit[0] == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
        todayList.add(
            Slidable(
              endActionPane: ActionPane(
                motion: DrawerMotion(),
                children: [
                  SlidableAction(onPressed: (BuildContext context) {
                    if (int.parse(shiftSplit[9]) == 1 || int.parse(shiftSplit[9]) == 2 ){
                      showTopSnackBar(
                        context,
                        CustomSnackBar.info(
                          message:
                          "En vagt er allerede tildelt",
                        ),
                      );
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AssignShiftScreen(date: shiftSplit[0], token: shiftSplit[7], userRef: FirebaseFirestore.instance.collection(shiftSplit[8]))));
                    }
                  },
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.add,),
                  SlidableAction(onPressed: (BuildContext context) {
                    if (int.parse(shiftSplit[9]) == 0){
                      showTopSnackBar(
                        context,
                        CustomSnackBar.info(
                          message:
                          "Der er ikke tildelt en vagt endnu. Du kan ikke redigere dagen",
                        ),
                      );
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminEditShiftScreen(date: shiftSplit[0], token: shiftSplit[7], userRef: FirebaseFirestore.instance.collection(shiftSplit[8]), name: shiftSplit[6])));
                    }
                  },
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,),
                  SlidableAction(onPressed: (BuildContext context) {
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      title: Text("Slet dag"),
                      content: const Text("Er du sikker på at slette dagen?"),
                      actions: [
                        TextButton(onPressed: () {
                          FirebaseFirestore.instance.collection(shiftSplit[8]).doc(shiftSplit[0]).delete();
                          Navigator.pop(context);
                          showTopSnackBar(
                            context,
                            CustomSnackBar.success(
                              message:
                              "Vagt slettet",
                            ),
                          );
                          }, child: const Text("Slet")),
                        TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Annuller")),
                      ],
                    );});
                  },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,),
                ],
              ),
                child: AdminAvailableShiftCard(text: shiftSplit[6], time: int.parse(shiftSplit[9]) == 0 ? "Tilgængelig: " + shiftSplit[3] : shiftSplit[10].substring(0,11), subtitle: "Se mere", icon: Icon(Icons.square_rounded, color: Color(int.parse(shiftSplit[2])),), onPressed: (){
                  showDialog(context: context, builder: (BuildContext context){
                    return SimpleDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      title: Center(child: Text(shiftSplit[6] + " - " + shiftSplit[0].substring(0,5))),
                      children: [
                        Container(padding: EdgeInsets.only(left: 30, right: 30),child: TextButton.icon(onPressed: () async {
                          var userRef = await databaseReference.collection(shiftSplit[8]);
                          var dataRef = await databaseReference.collection(shiftSplit[8]).doc(shiftSplit[0]);
                          if (int.parse(shiftSplit[9]) != 0){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
                              date: shiftSplit[0],
                              status: shiftSplit[1],
                              name: shiftSplit[6],
                              token: shiftSplit[7],
                              time: shiftSplit[3],
                              comment: shiftSplit[4],
                              awaitConfirmation: int.parse(shiftSplit[9]),
                              details: shiftSplit[10],
                              color: shiftSplit[2],
                              data: dataRef,
                              userRef: userRef,
                            ))); } else if (int.parse(shiftSplit[9]) == 0){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
                              date: shiftSplit[0],
                              status: shiftSplit[1],
                              name: shiftSplit[6],
                              token: shiftSplit[7],
                              time: shiftSplit[3],
                              comment: shiftSplit[4],
                              awaitConfirmation: int.parse(shiftSplit[9]),
                              color: shiftSplit[2],
                              data: dataRef,
                              userRef: userRef,
                            )));
                          }
                        }, icon: Icon(Icons.login, color: Colors.blue,), label: Text("Flere oplysninger", style: TextStyle(color: Colors.blue),),),),
                        const Divider(thickness: 1),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          alignment: Alignment.center,
                          child: Text("Kontakt", style: TextStyle(fontWeight: FontWeight.bold),),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("Opkald") , icon: const Icon(Icons.phone), onPressed: (){launch("tel:" + shiftSplit[5]);},), ),),
                            SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("SMS") , icon: const Icon(Icons.message), onPressed: (){launch("sms:" + shiftSplit[5]);},), ),),
                          ],
                        ),
                      ],
                  );});
                }))
        );
      } else if (shiftSplit[0] == DateFormat('dd-MM-yyyy').format(DateTime.now().add(const Duration(days: 1)))){
        tomorrowList.add(
            Slidable(
                endActionPane: ActionPane(
                  motion: DrawerMotion(),
                  children: [
                    SlidableAction(onPressed: (BuildContext context) {
                      if (int.parse(shiftSplit[9]) == 1 || int.parse(shiftSplit[9]) == 2 ){
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                            "En vagt er allerede tildelt",
                          ),
                        );
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AssignShiftScreen(date: shiftSplit[0], token: shiftSplit[7], userRef: FirebaseFirestore.instance.collection(shiftSplit[8]))));
                      }
                    },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.add,),
                    SlidableAction(onPressed: (BuildContext context) {
                      if (int.parse(shiftSplit[9]) == 0){
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                            "Der er ikke tildelt en vagt endnu. Du kan ikke redigere den",
                          ),
                        );
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminEditShiftScreen(date: shiftSplit[0], token: shiftSplit[7], userRef: FirebaseFirestore.instance.collection(shiftSplit[8]), name: shiftSplit[6])));
                      }
                    },
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,),
                    SlidableAction(onPressed: (BuildContext context) {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          title: Text("Slet dag"),
                          content: const Text("Er du sikker på at slette dagen?"),
                          actions: [
                            TextButton(onPressed: () {
                              FirebaseFirestore.instance.collection(shiftSplit[8]).doc(shiftSplit[0]).delete();
                              Navigator.pop(context);
                              showTopSnackBar(
                                context,
                                CustomSnackBar.success(
                                  message:
                                  "Vagt slettet",
                                ),
                              );
                              }, child: const Text("Slet")),
                            TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Annuller")),
                          ],
                        );});
                    },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,),
                  ],
                ),
                child: AdminAvailableShiftCard(text: shiftSplit[6], time: int.parse(shiftSplit[9]) == 0 ? "Tilgængelig: " + shiftSplit[3] : shiftSplit[10].substring(0,11), subtitle: "Se mere", icon: Icon(Icons.square_rounded, color: Color(int.parse(shiftSplit[2])),), onPressed: (){
                  showDialog(context: context, builder: (BuildContext context){
                    return SimpleDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      title: Center(child: Text(shiftSplit[6] + " - " + shiftSplit[0].substring(0,5))),
                      children: [
                        Container(padding: EdgeInsets.only(left: 30, right: 30),child: TextButton.icon(onPressed: () async {
                          var userRef = await databaseReference.collection(shiftSplit[8]);
                          var dataRef = await databaseReference.collection(shiftSplit[8]).doc(shiftSplit[0]);
                          if (int.parse(shiftSplit[9]) != 0){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
                              date: shiftSplit[0],
                              status: shiftSplit[1],
                              name: shiftSplit[6],
                              token: shiftSplit[7],
                              time: shiftSplit[3],
                              comment: shiftSplit[4],
                              awaitConfirmation: int.parse(shiftSplit[9]),
                              details: shiftSplit[10],
                              color: shiftSplit[2],
                              data: dataRef,
                              userRef: userRef,
                            ))); } else if (int.parse(shiftSplit[9]) == 0){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminShiftDetailsScreen(
                              date: shiftSplit[0],
                              status: shiftSplit[1],
                              name: shiftSplit[6],
                              token: shiftSplit[7],
                              time: shiftSplit[3],
                              comment: shiftSplit[4],
                              awaitConfirmation: int.parse(shiftSplit[9]),
                              color: shiftSplit[2],
                              data: dataRef,
                              userRef: userRef,
                            )));
                          }
                        }, icon: Icon(Icons.login, color: Colors.blue,), label: Text("Flere oplysninger", style: TextStyle(color: Colors.blue),),),),
                        const Divider(thickness: 1),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          alignment: Alignment.center,
                          child: Text("Kontakt", style: TextStyle(fontWeight: FontWeight.bold),),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("Opkald") , icon: const Icon(Icons.phone), onPressed: (){launch("tel:" + shiftSplit[5]);},), ),),
                            SimpleDialogOption(child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(label: const Text("SMS") , icon: const Icon(Icons.message), onPressed: (){launch("sms:" + shiftSplit[5]);},), ),),
                          ],
                        ),
                      ],
                    );});
                }))
        );
      }
    }

    if (_controller.index == 0){
      return todayList;
    } else if (_controller.index == 1){
      return tomorrowList;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: ClampingScrollPhysics(),
      padding: const EdgeInsets.only(top: 0),
      shrinkWrap: true,
      children: [
        Container(
          color: Colors.blue,
          height: MediaQuery.of(context).size.height / 3,
          child: ListView(
            physics: ClampingScrollPhysics(),
            children: [
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 10),
                  child: const Center(
                      child: Text(
                        "Vikaroversigt",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
              Center(
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 30),
                  child: Text(
                    _controller.index == 0 ? DateFormat('dd-MM-yyyy').format(DateTime.now()) : DateFormat('dd-MM-yyyy').format(DateTime.now().add(Duration(days: 1))),
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  )
                ),
              ),
            ],
          ),
        ),
        Container(padding: const EdgeInsets.only(bottom: 10), child: TabBar(labelColor: Colors.black, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue, controller: _controller, tabs: const [Tab(text: "I dag",), Tab(text: "I morgen",)])),

        Row(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.square_rounded, color: Colors.orange, size: 16,),
                ),
                Text(" Tilgængelig", style: TextStyle(fontSize: 12),)
              ],
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.square_rounded, color: Colors.red, size: 16,),
                ),
                Text(" Afventer accept", style: TextStyle(fontSize: 12),)
              ],
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(Icons.square_rounded, color: Colors.green, size: 16,),
                ),
                Text(" Godkendt vagt", style: TextStyle(fontSize: 12),)
              ],
            ),
          ],
        ),

        const Divider(thickness: 1),

        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 10),
            child: FutureBuilder(future: getUserInfo(), builder: (context, AsyncSnapshot<List> snapshot){
              IconButton button = IconButton(
                onPressed: () {
                  setState((){});
                },
                color: Colors.blue, icon: Icon(Icons.refresh),
              );
              if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting){
                return Container(padding: const EdgeInsets.only(left: 50, right: 50, top: 50), child: SpinKitRing(
                  color: Colors.blue,
                  size: 50,
                ));
              } else if (snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(50),
                  child: const Center(child: Text(
                    "Ingen vikarer",
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),),
                );
              }
              return ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15, bottom: 5),
                        child: Text("Opdater", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)
                      ),
                      Spacer(),
                      Container(
                          padding: EdgeInsets.only(right: 10, bottom: 5),
                          child: button),
                    ],
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index){
                        Slidable shiftCard = snapshot.data?[index];
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              shiftCard
                            ],
                          ),
                        );
                      }
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
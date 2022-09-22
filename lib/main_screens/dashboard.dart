import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:odinvikar/main_screens/settings_screen.dart';
import 'package:odinvikar/main_screens/shiftinfo_sync.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:upgrader/upgrader.dart';
import '../upgrader_messages.dart';
import 'home_screen.dart';
import 'own_days.dart';
import 'package:intl/intl.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Dashboard> {

  User? user = FirebaseAuth.instance.currentUser;

  int _currentIndex = 0;
  late PageController _pageController;
  bool isSynced = false;
  late String icsFilePath = "null";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _getSyncStatus();
    Future.delayed(Duration(seconds: 1), (){
      isSynced? _downloadIcsFile() : null;
    });
    Future.delayed(Duration(seconds: 2), (){
      isSynced? _updateShiftStatus() : null;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _getSyncStatus() {
    FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      setState((){
        if (value['isAdmin'] == false){
          value['isSynced'] == true ? isSynced = true : Navigator.push(context, PageTransition(duration: Duration(milliseconds: 200), type: PageTransitionType.rightToLeft, child: ShiftInfoSyncScreen()));
        }
      });
    });
  }

  _downloadIcsFile() async {
    Response response;
    var dio = Dio();
    var directory = await getApplicationDocumentsDirectory();
    var path = directory.path + Platform.pathSeparator;

    FirebaseFirestore.instance.collection("user").doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) async {
      response = await dio.download(value['syncURL'], path + 'vikarlydata.ics');
    });

    setState(() {
      icsFilePath = path + "vikarlydata.ics";
    });
  }

  _updateShiftStatus() async {
    final data = await File(icsFilePath).readAsLines();
    final calendar = ICalendar.fromLines(data);
      FirebaseFirestore.instance.collection(user!.uid).doc(DateFormat('dd-MM-yyyy').format((DateTime.now()))).get().then((value) {

        var date = DateTime.parse(calendar.data.last['dtstart'].dt);
        if (value['awaitConfirmation'] == 0 && calendar.data.length > 3 && date == DateTime.now()){
          value.reference.update({
            'awaitConfirmation': 2,
            'color': '0xFF4CAF50',
            'isAccepted': true,
            'status': 'Godkendt vagt',
            'details' : "Godkendt              Ingen"
          });
        }
      });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 250), curve: Curves.easeOutCirc);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showTopSnackBar(context, CustomSnackBar.error(message: "Du kan ikke navigere tilbage",),);
        return false;
      },
      child: Scaffold(
        //extendBodyBehindAppBar: true,
        body: UpgradeAlert(
          upgrader: Upgrader(
            showLater: false,
            showIgnore: false,
              messages: MyUpgraderMessages()
          ),
          child: SizedBox.expand(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: const <Widget>[
                HomeScreen(),
                OwnDaysScreen(),
                //ShiftScreen(),
                SettingsScreen(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            /*borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),*/
            boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black,
              blurRadius: 0.1,
            ),
          ],
          ),
          child: ClipRRect(
            /*borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),*/
            child: BottomNavigationBar(
              enableFeedback: false,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                    label: 'Oversigt',
                    icon: Icon(Icons.home_outlined)
                ),
                BottomNavigationBarItem(
                    label: 'Kalender',
                    icon: Icon(Icons.today_outlined)
                ),
               /* BottomNavigationBarItem(
                    label: 'Vagtbanken',
                    icon: Icon(Icons.work_outline)
                ),*/
                BottomNavigationBarItem(
                    label: 'Profil',
                    icon: Icon(Icons.account_box_outlined)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/settings_screen.dart';
import 'package:odinvikar/main_screens/shiftinfo_sync.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import '../shift_system/shifts_screen.dart';
import 'home_screen.dart';
import 'own_days.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Dashboard> {

  int _currentIndex = 0;
  late PageController _pageController;
  bool isSynced = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _getSyncStatus();
    Future.delayed(Duration(seconds: 1), (){
      isSynced? _downloadIcsFile() : null;
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
    var path = Platform.isAndroid ? "/sdcard/Download/" : directory.path + Platform.pathSeparator;

    FirebaseFirestore.instance.collection("user").doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) async {
      response = await dio.download(value['syncURL'], path + 'vikarlydata.ics');
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
    return Scaffold(
      //extendBodyBehindAppBar: true,
     appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: kToolbarHeight + 2,
        //iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue
                ),
                child: Center(child: Text("Menu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),))),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            ListTile(
              title: Text("Hjem", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ),),
              leading: Icon(Icons.home_outlined),
              selected: true,
            ),
            ListTile(
              title: Text("Vagtbanken"),
              leading: Icon(Icons.work_outline),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShiftScreen()));
              },
            ),
            ListTile(
              title: Text("Profil"),
              leading: Icon(Icons.account_box_outlined),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: const <Widget>[
            HomeScreen(),
            OwnDaysScreen(),
            /*ShiftScreen(),
            SettingsScreen(),*/
          ],
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
              ),
              BottomNavigationBarItem(
                  label: 'Profil',
                  icon: Icon(Icons.account_box_outlined)
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

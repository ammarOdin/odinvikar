import 'dart:io';

import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:upgrader/upgrader.dart';
import '../upgrader_messages.dart';
import 'admin_calendar.dart';
import 'admin_home_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<AdminDashboard> {

  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        body: UpgradeAlert(
          upgrader: Upgrader(
              dialogStyle: Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material,
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
                AdminHomeScreen(),
                AdminCalendar(),
                AdminSettingsScreen()
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
                BottomNavigationBarItem(
                    label: 'Indstillinger',
                    icon: Icon(Icons.settings_outlined)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

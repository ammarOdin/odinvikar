import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
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
        Flushbar(
            margin: EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(10),
            title: 'Navigation',
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            message: 'Du kan ikke navigere tilbage',
            flushbarPosition: FlushbarPosition.BOTTOM).show(context);
        return false;
        },
      child: Scaffold(
        body: SizedBox.expand(
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

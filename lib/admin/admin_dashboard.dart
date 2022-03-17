import 'package:flutter/material.dart';
import 'package:odinvikar/admin/admin_calendar.dart';
import 'package:odinvikar/admin/admin_contact_screen.dart';
import 'package:odinvikar/shift_system/admin/admin_shifts_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: const <Widget>[
            AdminHomeScreen(),
            AdminCalendar(),
            AdminShiftsScreen(),
            AdminContactScreen(),
            AdminSettingsScreen(),
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
            currentIndex: _currentIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() => _currentIndex = index);
              _pageController.jumpToPage(index);
            },
            items: const [
              BottomNavigationBarItem(
                  label: 'Oversigt',
                  icon: Icon(Icons.home)
              ),
              BottomNavigationBarItem(
                  label: 'Kalender',
                  icon: Icon(Icons.today_outlined)
              ),
              BottomNavigationBarItem(
                  label: 'Vagter',
                  icon: Icon(Icons.work_outline)
              ),
              BottomNavigationBarItem(
                  label: 'Telefonliste',
                  icon: Icon(Icons.account_box)
              ),
              BottomNavigationBarItem(
                  label: 'Indstillinger',
                  icon: Icon(Icons.settings)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

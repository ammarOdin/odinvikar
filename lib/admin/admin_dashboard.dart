import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/settings_screen.dart';
import '../main_screens/own_days.dart';
import 'admin_home_screen.dart';



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
            OwnDaysScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
              label: 'Vikarer',
              icon: Icon(Icons.apps)
          ),
          BottomNavigationBarItem(
              label: 'Profil',
              icon: Icon(Icons.account_box)
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/settings_screen.dart';
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
          duration: Duration(milliseconds: 250), curve: Curves.easeIn);
    });
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
            HomeScreen(),
            OwnDaysScreen(),
            ShiftScreen(),
            SettingsScreen(),
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
              BottomNavigationBarItem(
                  label: 'Vagtbanken',
                  icon: Icon(Icons.work_outline)
              ),
              BottomNavigationBarItem(
                  label: 'Profil',
                  icon: Icon(Icons.account_box_outlined)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/settings_screen.dart';
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
            //CalendarPickerIntegration(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black,
            blurRadius: 5,
          ),
        ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
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
                  label: 'Mine Dage',
                  icon: Icon(Icons.apps)
              ),
              BottomNavigationBarItem(
                  label: 'Profil',
                  icon: Icon(Icons.account_box)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

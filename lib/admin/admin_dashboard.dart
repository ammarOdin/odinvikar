import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:page_transition/page_transition.dart';
import '../missing_connection.dart';
import '../shift_system/admin/admin_shifts_screen.dart';
import 'admin_calendar_new.dart';
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
    _getConnectionStatus();
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

  _getConnectionStatus() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == false) {
      Navigator.push(context, PageTransition(duration: Duration(milliseconds: 200), type: PageTransitionType.rightToLeft, child: MissingConnectionPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              title: Text("Hjem", style: TextStyle(fontSize: 16),),
              leading: Icon(Icons.home_outlined),
              selected: true,
            ),
            ListTile(
              title: Text("Vagtbanken"),
              leading: Icon(Icons.work_outline),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminShiftsScreen()));
              },
            ),
            ListTile(
              title: Text("Indstillinger"),
              leading: Icon(Icons.settings_outlined),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminSettingsScreen()));
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
            AdminHomeScreen(),
            AdminNewCalendar(),
            /*AdminShiftsScreen(),
            AdminSettingsScreen(),*/
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
              /*BottomNavigationBarItem(
                  label: 'Vagter',
                  icon: Icon(Icons.work_outline)
              ),*/
              /*BottomNavigationBarItem(
                  label: 'Vagtbanken',
                  icon: Icon(Icons.work_outline)
              ),
              BottomNavigationBarItem(
                  label: 'Indstillinger',
                  icon: Icon(Icons.settings_outlined)
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

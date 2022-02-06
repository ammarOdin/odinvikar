import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:odinvikar/main_screens/dashboard.dart';
import 'package:odinvikar/main_screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatelessWidget {
  IntroScreen({Key? key}) : super(key: key);

  final List<PageViewModel> pages = [
    PageViewModel(title: "Velkommen til OdinVikar", body: "Hold styr på de dage du kan arbejde.", image: Container(padding: const EdgeInsets.only(top: 50), child: Center(child: Image.asset("assets/1.png"),)), footer: ElevatedButton(onPressed: () {}, child: const Text("Næste"),)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),),
      body: IntroductionScreen(pages: pages, dotsDecorator: const DotsDecorator(
        size: Size(10,10),
        color: Colors.blue,
        activeSize: Size.square(15),
        activeColor: Colors.blueAccent
      ),
      showDoneButton: true,
      done: const Text("Kom i gang"),
        showSkipButton: false,
        showNextButton: true,
        next: const Icon(Icons.arrow_forward),
        onDone: (){onDone(context);},
      ),
    );
  }

  void onDone(context) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool("on_boarding", false );
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Dashboard()));
  }
}

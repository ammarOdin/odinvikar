import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatelessWidget {
  IntroScreen({Key? key}) : super(key: key);

  final List<PageViewModel> pages = [
    PageViewModel(title: "Velkommen til OdinVikar", body: "Hold styr på de dage du kan arbejde som vikar.", image: Center(child: Image.asset("assets/1.svg"),), footer: ElevatedButton(onPressed: () {}, child: const Text("Næste"),)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),),
      body: IntroductionScreen(),
    );
  }
}

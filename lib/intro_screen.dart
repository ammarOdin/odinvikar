import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/main_screens/dashboard.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),),
      body: Onboarding(
        background: Colors.blueGrey,
        proceedButtonStyle: ProceedButtonStyle(proceedpButtonText: const Text("Fortsæt"),
          proceedButtonRoute: onDone,
        ),
        isSkippable: false,
        pages: [
          PageModel(
            widget: Column(
              children: [
                Container(padding: const EdgeInsets.only(bottom: 50, top: 50), child: ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.asset('assets/1.png'))),
                const Text('Velkommen til OdinVikar', style: pageTitleStyle),
                const Text('Hold styr på hvornår du kan arbejde, nemt og enkelt.', style: pageInfoStyle,)
              ],
            ),
          ),
          PageModel(
            widget: Column(
              children: [
                Container(padding: const EdgeInsets.only(bottom: 50, top: 50), child: ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.asset('assets/2.png'))),
                const Text('Vagt Oversigt', style: pageTitleStyle),
                const Text('Se hvilke dage du har sat dig selv til rådighed.', style: pageInfoStyle,)
              ],
            ),
          ),
          PageModel(
            widget: Column(
              children: [
                Container(padding: const EdgeInsets.only(bottom: 50, top: 50), child: ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.asset('assets/3.png'))),
                const Text('Strukturer dine vagter', style: pageTitleStyle),
                const Text('Sæt dig selv til rådighed, rediger og strukturer dine dage.', style: pageInfoStyle,)
              ],
            ),
          ),
          PageModel(
            widget: Column(
              children: [
                Container(padding: const EdgeInsets.only(bottom: 50, top: 50), child: ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.asset('assets/4.png'))),
                const Text('Dine Oplysninger', style: pageTitleStyle),
                const Text('Se og rediger dine personlige oplysninger.', style: pageInfoStyle,)
              ],
            ),
          ),
        ],
        indicator: Indicator(
          indicatorDesign: IndicatorDesign.line(
            lineDesign: LineDesign(
              lineType: DesignType.line_uniform,
            ),
          ),
        ),
      )
    );
  }

  void onDone(context) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool("on_boarding", false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Dashboard()));
  }
}

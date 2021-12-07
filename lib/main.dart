import 'package:flutter/material.dart';
import 'main_screens/dashboard.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('da')
      ],
        title: 'Odin Vikar Oversigt',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF3EBACE),
          scaffoldBackgroundColor: const Color(0xFFF3F5F7),
        ),
        home: const Dashboard(),

    );
  }
}
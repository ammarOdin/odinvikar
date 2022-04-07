import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odinvikar/admin/admin_dashboard.dart';
import 'package:odinvikar/main_screens/login.dart';
import 'package:odinvikar/main_screens/web_register.dart';
import 'main_screens/dashboard.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'package:firebase_core/firebase_core.dart';

bool screen = true;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyBU0I4h6PEocz7ZgT5Eb2FEo0tVSUD-jIM", appId: "1:320368504585:web:d6ecf3729dc524167aedd8", messagingSenderId: "320368504585", projectId: "odinvikar", storageBucket: "odinvikar.appspot.com"),
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseMessaging.instance.getToken().then((value) {FirebaseFirestore.instance.collection('user').doc(user!.uid).update({'token': value});});

// onboarding
  /*final preferences = await SharedPreferences.getInstance();
  screen = preferences.getBool("on_boarding") ?? true;*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
    localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('da')
      ],
        title: 'Vikar Oversigt',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          /*colorSchemeSeed: Colors.blue,
          useMaterial3: true,*/
          primaryColor: const Color(0xFF3EBACE),
          //textTheme: GoogleFonts.oxygenTextTheme(Theme.of(context).textTheme),
          scaffoldBackgroundColor: const Color(0xFFF3F5F7),
          appBarTheme: const AppBarTheme(elevation: 0),
        ),
      home: user == null? const LoginScreen() : const AuthenticationWrapper(),
      locale: const Locale('da'),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  isAdmin(context)  async  {
    var admin = await
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == true){
        /*final preferences = await SharedPreferences.getInstance();
        await preferences.setBool("on_boarding", false);*/
        return true;
      } else if (documentSnapshot.get(FieldPath(const ['isAdmin'])) == false){
        return false;
      }
    });
    return admin;
  }
  @override
  Widget build(BuildContext context) {
    /*if (screen == false){
      return FutureBuilder(future: isAdmin(context), builder: (context, snapshot) => snapshot.data == true? const AdminDashboard(): const Dashboard());
    } else if (screen == true){
      return FutureBuilder(future: isAdmin(context), builder: (context, snapshot) => snapshot.data == true? const AdminDashboard(): const IntroScreen());
    } else {
      return const LoginScreen();
    }*/

    if (kIsWeb){
      return FutureBuilder(builder: (context, snapshot) => const RegisterPage());
    } else {
      return FutureBuilder(future: isAdmin(context), builder: (context, snapshot) => snapshot.data == true? const AdminDashboard(): const Dashboard());
    }
  }
}

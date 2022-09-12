import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:odinvikar/admin/admin_dashboard.dart';
import 'package:odinvikar/auth/login.dart';
import 'main_screens/dashboard.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

bool screen = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Foreground notifications
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: android.smallIcon,
              styleInformation: BigTextStyleInformation(""),
            ),
          ));
    }
  });

  if (Platform.isIOS){
// iOS notifications permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
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

    await messaging.setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true
    );
  }

  // User token saver
  User? user = FirebaseAuth.
  instance.currentUser;
  FirebaseMessaging.instance.getToken().then((value) {FirebaseFirestore.instance.collection('user').doc(user!.uid).update({'token': value});});

  // Disabled persistance for performane improvements
  var db = FirebaseFirestore.instance;
  db.settings = const Settings(persistenceEnabled: false);

 /* var users = await FirebaseFirestore.instance.collection('user').get();
  for (var users in users.docs){
  if (users['isAdmin'] == false){
  users.reference.update({
      'syncURL': "",
      'isSynced': false
    });
  }
  }*/

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

    Widget checkHome(){
      return user == null? const LoginScreen() : const AuthenticationWrapper();
    }

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
      home: checkHome(),
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
    return FutureBuilder(future: isAdmin(context), builder: (context, snapshot) => snapshot.data == true? const AdminDashboard(): const Dashboard());
  }
}


void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
  Get.dialog(AlertDialog(
    title: Text(title!),
    content: Text(body!),
  ));
}

void selectNotification(String? payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  // Fires when a notification has been tapped on via the onSelectNotification callback

}

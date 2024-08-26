import 'package:abblehelptech/pages/authentication/login_screen.dart';
import 'package:abblehelptech/pages/bords/bords_screens.dart';
import 'package:abblehelptech/themes/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCVsSmCN3lLyHn08VJkXFeV4Sv5qgXpqsg",
          authDomain: "abblehelp.firebaseapp.com",
          projectId: "abblehelp",
          storageBucket: "abblehelp.appspot.com",
          messagingSenderId: "649301835668",
          appId: "1:649301835668:web:a21da84ebd5ac9f3be1981",
          measurementId: "G-YW341SCXMV"));
    await Permission.locationWhenInUse.isDenied.then((valueOfPermission){
      if(valueOfPermission){
        Permission.locationWhenInUse.request();
      }
    });

    await Permission.notification.isDenied.then((valueOfPermission){
      if(valueOfPermission){
        Permission.notification.request();
      }
    });


  await SharedPreferences.getInstance();
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbbleHelp',
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null? LoginScreen():BordsScreens(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

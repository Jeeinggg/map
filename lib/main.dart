import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_accident/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_accident/screens//page_map.dart';
import 'package:flutter/material.dart';
import 'package:app_accident/screens/page_accidentlist.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email And Password Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

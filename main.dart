import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Login_Screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase Initialized Successfully');
  } catch (e) {
    print('Firebase Not Initialized Successfully${e.toString()}');
  }
  runApp(DoorApp());
}

class DoorApp extends StatefulWidget {
  @override
  State<DoorApp> createState() => _DoorAppState();
}

class _DoorAppState extends State<DoorApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}






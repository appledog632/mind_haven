import 'package:flutter/material.dart';
import 'package:mentalwellness/bottom_navbar.dart';
import 'package:mentalwellness/screens/baselogin.dart';
import 'package:mentalwellness/screens/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eve Wellness',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: LoginSignupPage(), // Replace HomePage with FloatingNavBarHome
    );
  }
}
import 'package:flutter/material.dart';
import 'package:to_do/loginPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do',
      theme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}


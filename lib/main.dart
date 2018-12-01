import 'package:flutter/material.dart';
import 'package:to_do/loginPage.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'To Do',
      theme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}


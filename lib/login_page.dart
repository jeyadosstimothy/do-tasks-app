import 'dart:async';

import 'package:flutter_firebase_ui/flutter_firebase_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do/home_page.dart';

class LoginPage extends StatefulWidget {
  final destinationPage;
  LoginPage({this.destinationPage});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<FirebaseUser> _listener;
  FirebaseUser _currentUser;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_currentUser == null) {
      return new SignInScreen(
        title: 'Welcome to Do',
        header: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Text("By signing in using your google account, your tasks will be synced with the cloud. To continue, press the button below", style: Theme.of(context).textTheme.subhead,)
          )
        ),
        providers: [
          ProvidersTypes.google
        ],
        color: Theme.of(context).canvasColor,
      );
    }
    else {
      return new HomePage(firebaseUser: _currentUser);
    }
  }

  void _checkCurrentUser() async {
    _currentUser = await _auth.currentUser();
    _currentUser?.getIdToken(refresh: true);

    _listener = _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        _currentUser = user;
      });
    });
  }
}


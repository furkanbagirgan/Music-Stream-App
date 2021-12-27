import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'tabs_page.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  User _user;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return LoginPage((user) {
        _updateUser(user);
      }, auth);
    } else {
      return TabsPage(_user, () {
        _updateUser(null);
      }, auth);
    }
  }

  void _checkUser() {
    _user = auth.currentUser;
  }

  void _updateUser(User user) {
    setState(() {
      _user = user;
    });
  }
}

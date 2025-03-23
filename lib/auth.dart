import 'package:firebase_tutorial/screens/home_screen.dart';
import 'package:firebase_tutorial/screens/login.dart';
import 'package:firebase_tutorial/service/auth_service.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          } else {
            return HomeScreen();
          }
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

// signup_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_tutorial/service/auth_service.dart';
import 'package:firebase_tutorial/service/database_service.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String name = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(hintText: 'Name'),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                onChanged: (val) {
                  setState(() => name = val);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(hintText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(hintText: 'Password'),
                obscureText: true,
                validator:
                    (val) =>
                        val!.length < 6
                            ? 'Enter a password 6+ chars long'
                            : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                child: Text('Register'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    try {
                      UserCredential? result = await _auth
                          .createUserWithEmailAndPassword(email, password);
                      if (result != null && result.user != null) {
                        // Save user data to Firebase
                        await _db.saveUserData(result.user!.uid, {
                          'name': name,
                          'email': email,
                          'createdAt': DateTime.now().toString(),
                        });
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        error = e.message!;
                        loading = false;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 12.0),
              Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0)),
              TextButton(
                child: Text('Already have an account? Sign in'),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

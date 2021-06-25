import 'package:aplikacija_za_inventuru/screens/services/auth.dart';
import 'package:aplikacija_za_inventuru/shared/constants.dart';
import 'package:aplikacija_za_inventuru/shared/loading.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 50.0),
              Text('Scan it!', style: TextStyle(color: Colors.blueAccent, fontSize: 75.0)),
              SizedBox(height: 50.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Upišite email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Lozinka'),
                validator: (val) => val!.length < 6 ? 'Upišite lozinku sa 6 ili više znakova' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
                  onPressed: () async {
                    if(_formKey.currentState!.validate()) {
                      setState(() => loading = true);
                      dynamic result = await _auth.signInWithEmail(email, password);
                      if(result == null) {
                        setState(() {
                          error = 'Pogreška pri prijavi';
                          loading = false;
                        });
                      }
                    }
                  },
                  child: Text('Prijava',
                        style: TextStyle(color: Colors.white))
              ),
              SizedBox(height: 10.0),
              Text(error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
              )
            ],
          )
        ),
      ),
    );
  }
}

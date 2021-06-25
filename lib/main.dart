import 'package:aplikacija_za_inventuru/models/user.dart';
import 'package:aplikacija_za_inventuru/screens/home/detalji.dart';
import 'package:aplikacija_za_inventuru/screens/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:aplikacija_za_inventuru/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:aplikacija_za_inventuru/screens/home/azuriraj.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
        value: AuthService().user,
        initialData: null,
        child: MaterialApp(
          home: Wrapper(),
          routes: {
            '/detalji': (ctx) => Detalji(),
            '/azuriraj' : (ctx) => AzurirajDetalje()
          }
        ),
    );
  }
}


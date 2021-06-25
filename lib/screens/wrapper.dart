import 'package:aplikacija_za_inventuru/models/user.dart';
import 'package:aplikacija_za_inventuru/screens/authenticate/authenticate.dart';
import 'package:aplikacija_za_inventuru/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel?>(context);
    if(user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}

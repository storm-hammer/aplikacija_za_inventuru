import 'package:aplikacija_za_inventuru/screens/home/filterObject.dart';
import 'package:aplikacija_za_inventuru/screens/services/database.dart';
import 'package:aplikacija_za_inventuru/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aplikacija_za_inventuru/shared/constants.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class Filter extends StatefulWidget {
  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {

  final DatabaseService _db = DatabaseService();
  CollectionReference predmeti = FirebaseFirestore.instance.collection('predmeti');
  Set<dynamic> prostorije = new Set();
  Set<dynamic> osobe = new Set();
  String naziv = '';

  List<dynamic> odabraneProstorije = List.empty(growable: true);
  List<dynamic> odabraneOsobe = List.empty(growable: true);

  FilterObject? _buildFilter() {
    if(odabraneProstorije.length != 0 || odabraneOsobe.length != 0 || naziv != '') {
      return new FilterObject(odabraneProstorije, odabraneOsobe, naziv);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('predmeti').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        prostorije = snapshot.data!.docs.map((e) => e['prostorija']).toSet();
        osobe = snapshot.data!.docs.map((e) => e['osoba']).toSet();

        return Scaffold(
            appBar:  AppBar(
              backgroundColor: Colors.blueAccent,
              automaticallyImplyLeading: false,
              title: Text('Izaberite željeni filtar'),
              centerTitle: true,
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MultiSelectDialogField(
                    buttonText: Text('Izaberite prostorije'),
                    title: Text("Izaberite prostorije"),
                    items: prostorije.map((e) => MultiSelectItem(e, e.toString())).toList(),
                    listType: MultiSelectListType.CHIP,
                    onConfirm: (values) {
                      odabraneProstorije = values;
                    },
                  ),
                  MultiSelectDialogField(
                    buttonText: Text('Izaberite osobe'),
                    title: Text('Izaberite osobe'),
                    items: osobe.map((e) => MultiSelectItem(e, e.toString())).toList(),
                    listType: MultiSelectListType.CHIP,
                    onConfirm: (values) {
                      odabraneOsobe = values;
                    },
                  ),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'Unesite naziv predmeta',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 1.0)
                        )
                    ),
                    onChanged: (val) {
                      naziv = val;
                    },
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
                      onPressed: () {
                        Navigator.pop(context, _buildFilter());
                      },
                      child: Text('Primijeni filter', style: TextStyle(color: Colors.white))
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      child: Text('Poništi filter', style: TextStyle(color: Colors.white))
                  )
                ],
              ),
            )
        );
      },
    );
  }
}

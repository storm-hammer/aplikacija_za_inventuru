import 'package:flutter/material.dart';
import 'package:aplikacija_za_inventuru/shared/constants.dart';
import 'package:aplikacija_za_inventuru/screens/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikacija_za_inventuru/shared/loading.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AzurirajDetalje extends StatefulWidget {
  @override
  _AzurirajDetaljeState createState() => _AzurirajDetaljeState();
}

class _AzurirajDetaljeState extends State<AzurirajDetalje> {

  final DatabaseService _db = DatabaseService();

  String naziv = '',
      opis = '',
      osoba = '',
      prostorija = '';

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _predmetiStream = _db.getDb().collection('predmeti').snapshots();

    final args = ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, String>;

    return StreamBuilder<QuerySnapshot>(
      stream: _predmetiStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if(snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        naziv = snapshot.data!.docs.firstWhere((element) => element['inv_broj'].toString() == args['inv_broj'])['naziv'];
        opis = snapshot.data!.docs.firstWhere((element) => element['inv_broj'].toString() == args['inv_broj'])['opis'];

        Set<dynamic> osobe = snapshot.data!.docs.map((e) => e['osoba']).toSet();
        Set<dynamic> prostorije = snapshot.data!.docs.map((e) => e['prostorija']).toSet();

        if(args['currentRoom'] != '') {
          prostorija = args['currentRoom']!;
        } else {
          prostorija = prostorije.first.toString();
        }

        if(args['currentPerson'] != '') {
          osoba = args['currentRoom']!;
        } else {
          osoba = osobe.first.toString();
        }

        return Material(
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blueAccent,
                  title: Text('Ažuriraj detalje o predmetu'),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                ),
                body: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                    child: ListView(
                      children: [
                        SizedBox(height: 30),
                        Text('Prvo odaberite prostoriju i osobu:', style: TextStyle(color: Colors.blueAccent, fontSize: 20.0)),
                        SizedBox(height: 30),
                        DropdownSearch<String>(
                          mode: Mode.MENU,
                          showSelectedItem: true,
                          items: prostorije.map((e) => e.toString()).toList(),
                          label: "Prostorija",
                          popupItemDisabled: (String s) => s.startsWith('I'),
                          onChanged: (value) {
                            prostorija = value!;
                          },
                          selectedItem: prostorija,
                        ),
                        SizedBox(height: 30),
                        DropdownSearch<String>(
                          mode: Mode.MENU,
                          showSelectedItem: true,
                          items: osobe.map((e) => e.toString()).toList(),
                          label: "Osoba",
                          popupItemDisabled: (String s) => s.startsWith('I'),
                          onChanged: (value) {
                            osoba = value!;
                          },
                          selectedItem: osoba,
                        ),
                        SizedBox(height: 30),
                        Text('Potom upišite naziv i opis:', style: TextStyle(color: Colors.blueAccent, fontSize: 20.0)),
                        SizedBox(height: 30),
                        TextFormField(
                          initialValue: naziv,
                          decoration: textInputDecoration.copyWith(helperText: 'Naziv',
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0))
                          ),
                          onChanged: (val) {
                            naziv = val;
                          },
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          initialValue: opis,
                          decoration: textInputDecoration.copyWith(helperText: 'Opis',
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0))
                          ),
                          onChanged: (val) {
                            opis = val;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
                            onPressed: () {
                              _db.azuriraj(args['inv_broj'].toString(), naziv, opis, osoba, prostorija);
                              Navigator.pop(context, {'currentRoom': prostorija, 'currentPerson': osoba});
                            },
                            child: Text('Spremi podatke', style: TextStyle(color: Colors.white))
                        ),
                      ],
                    )
                )
            )
        );
      }
    );

  }
}


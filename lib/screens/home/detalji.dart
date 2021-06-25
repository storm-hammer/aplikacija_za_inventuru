import 'package:aplikacija_za_inventuru/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aplikacija_za_inventuru/shared/constants.dart';
import 'package:aplikacija_za_inventuru/screens/services/database.dart';

class Detalji extends StatefulWidget {

  @override
  _DetaljiState createState() => _DetaljiState();
}

class _DetaljiState extends State<Detalji> {

  final DatabaseService _db = DatabaseService();
  String naziv = '', opis = '', osoba = '', prostorija = '', currentPerson = '', currentRoom = '';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    CollectionReference colRef = _db.getDb().collection('predmeti');
    String invBroj = args['inv_broj'].toString();
    if(currentPerson != '') {
      currentPerson = args['currentPerson']!;
    }
    if(currentRoom != '') {
      currentRoom = args['currentRoom']!;
    }

    return FutureBuilder<DocumentSnapshot>(
      future: colRef.doc(invBroj).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if(!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text('Nažalost taj predmet ne postoji, probajte ponovo skenirati'),
            ),
          );
        }

        Color color = snapshot.data!['datum'] != null ? Colors.redAccent : Colors.blueAccent;

        return Material(
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: color,
                  title: Text('Detalji o predmetu'),
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                ),
                body: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFormField(
                          initialValue: snapshot.data!['naziv'],
                          decoration: disabledTextInputDecoration.copyWith(helperText: 'Naziv'),
                        ),
                        TextFormField(
                          initialValue: snapshot.data!['opis'],
                          decoration: disabledTextInputDecoration.copyWith(helperText: 'Opis'),
                        ),
                        TextFormField(
                          initialValue: snapshot.data!['osoba'],
                          decoration: disabledTextInputDecoration.copyWith(helperText: 'Osoba'),
                        ),
                        TextFormField(
                          initialValue: snapshot.data!['prostorija'],
                          decoration: disabledTextInputDecoration.copyWith(helperText: 'Prostorija'),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: color),
                            onPressed: () async {
                              final result = await Navigator.pushNamed(context, '/azuriraj',
                                  arguments: {'inv_broj': invBroj, 'currentRoom': currentRoom, 'currentPerson': currentPerson}) as Map<String, String>;
                              setState(() {
                                currentPerson = result['currentPerson']!;
                                currentRoom = result['currentRoom']!;
                              });
                            },
                            child: Text('Ažuriraj podatke', style: TextStyle(color: Colors.white))
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: color),
                            onPressed: () {
                              _db.ocitaj(invBroj.toString());
                              print(currentPerson);
                              print(currentRoom);
                              Navigator.pop(context, {'currentRoom': currentRoom, 'currentPerson': currentPerson});
                            },
                            child: Text('Spremi podatke', style: TextStyle(color: Colors.white))
                        ),
                      ],
                    )
                )
            )
        );
      },
    );
  }
}
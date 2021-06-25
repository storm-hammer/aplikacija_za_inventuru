import 'package:aplikacija_za_inventuru/screens/home/filter.dart';
import 'package:aplikacija_za_inventuru/screens/services/auth.dart';
import 'package:aplikacija_za_inventuru/screens/services/database.dart';
import 'package:aplikacija_za_inventuru/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'detalji.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:aplikacija_za_inventuru/models/user.dart';
import 'package:excel/excel.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  int _currentIndex = 0;
  var filter;
  bool showByRoom = false;
  bool isSwitched = false;
  bool showScanned = true;
  bool filterOn = false;
  bool admin = false;
  bool scanMethod = true;
  String scanButton = 'QR/Barkod';
  String showButton = 'Prostorije';
  String currentRoom = '';
  String currentPerson = '';

  _import (BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (result != null) {
      _db.obrisiPredmete();
      CollectionReference predmeti = _db.getDb().collection('predmeti');
      String path = result.paths.first!;

      var bytes = File(path).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for(int i = 1; i < excel.tables[table]!.maxRows; i++) {
          var row = excel.tables[table]!.row(i);
          predmeti.doc(row[0]!.value.toString()).set({
            'inv_broj' : row[0]!.value,
            'naziv' : row[1]!.value,
            'opis' : row[2]!.value,
            'prostorija' : row[3]!.value,
            'osoba' : row[4]!.value,
            'datum' : null,
          });
        }
      }
    }
    build(context);
  }

  _export() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow(['inv_broj', 'naziv', 'opis', 'prostorija', 'osoba', 'datum']);

    CollectionReference predmeti = FirebaseFirestore.instance.collection('predmeti');
    await predmeti.get().then((value) => {
      value.docs.forEach((element) {
        sheetObject.appendRow(
        [element['inv_broj'], element['naziv'], element['opis'], element['prostorija'], element['osoba'], element['datum']]
        );
      })
    });

    var bytes = excel.encode();
    Directory dir = await getApplicationDocumentsDirectory();

    String docPath = '/storage/emulated/0/Android/data/com.example.aplikacija_za_inventuru/files';
    final file = File("$docPath/inventura.xlsx");
    file.writeAsBytesSync(bytes!);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context, listen: false);
    CollectionReference admini = _db.getDb().collection('admini');

    return FutureBuilder<DocumentSnapshot>(
        future: admini.doc(user!.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          admin = false;
        } else {
          admin = true;
        }

        if(snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        final Stream<QuerySnapshot> predmeti = _db.getDb().collection('predmeti').snapshots();

        return StreamBuilder<QuerySnapshot>(
            stream: predmeti,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading();
              }

              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.blueAccent,
                  title: Text('Trenutna inventura'),
                  centerTitle: true,
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    if(scanMethod) {
                      try {
                        String inv_broj = await scanner.scan();
                        final result = await Navigator.of(context).pushNamed('/detalji',
                            arguments: {"inv_broj": inv_broj, "currentRoom": currentRoom, "currentPerson" : currentPerson}) as Map<String, String>;
                        currentRoom = result['currentRoom']!;
                        currentPerson = result['currentPerson']!;
                      } catch(e) {}
                    } else {

                    }
                  },
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.blueAccent,
                ),

                body: Container(
                  child: ListView(
                    children: <Widget>[
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if(admin)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(primary: Colors.white),
                              onPressed: () {
                                showDialog(context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Uvozom novih podataka će se obrisati podaci o prošloj inventuri'),
                                      content: Text('Želite li nastaviti?'),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(primary: Colors.white),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Ne', style: TextStyle(color: Colors.blueAccent)),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(primary: Colors.white),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _import(context);
                                          },
                                          child: Text('Da', style: TextStyle(color: Colors.blueAccent)),
                                        )
                                      ],
                                    )
                                );
                              },
                              child: Text('Uvoz', style: TextStyle(color: Colors.blueAccent)),
                            ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.white),
                            onPressed: () {
                              _export();
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("Izvoz podataka uspješan"),
                                  )
                              );
                            },
                            child: Text('Izvoz', style: TextStyle(color: Colors.blueAccent)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.white),
                            onPressed: () {
                              showDialog(context: context, builder: (_) => AlertDialog(
                                title: Text('Želite li se stvarno odjaviti?'),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(primary: Colors.white),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Ne', style: TextStyle(color: Colors.blueAccent)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(primary: Colors.white),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _auth.signOut();
                                    },
                                    child: Text('Da', style: TextStyle(color: Colors.blueAccent)),
                                  )
                                ],
                              ));
                            },
                            child: Text('Odjava', style: TextStyle(color: Colors.blueAccent)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: filterOn ? Colors.blueAccent : Colors.white),
                            onPressed: () async {
                              filter = await Navigator.push(context, MaterialPageRoute(builder: (context) => Filter()));
                              setState(() {
                                filterOn = filter != null;
                              });
                            },
                            child: Text('Filter', style: TextStyle(color: filterOn ? Colors.white : Colors.blueAccent)),
                          ),
                        ],
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.white),
                            onPressed: () {
                              setState(() {
                                scanMethod = !scanMethod;
                                if(scanMethod) {
                                  scanButton = 'QR/Barkod';
                                } else {
                                  scanButton = 'Inventarni broj';
                                }
                              });
                            },
                            child: Text(scanButton, style: TextStyle(color: Colors.blueAccent)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.white),
                            onPressed: () {
                              setState(() {
                                showByRoom = !showByRoom;
                                if(showByRoom) {
                                  showButton = 'Osobe';
                                } else {
                                  showButton = 'Prostorije';
                                }
                              });
                            },
                            child: Text(showButton, style: TextStyle(color: Colors.blueAccent)),
                          ),
                        ],
                      ),
                      _db.getData(showScanned, showByRoom, filter),
                    ],
                  ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.blueAccent,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.black54,
                  currentIndex: _currentIndex,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.mark_as_unread),
                      label: 'Očitano',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.mark_as_unread),
                        label: 'Neočitano')
                  ],
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                      if(_currentIndex != 0) {
                        showScanned = false;
                      } else {
                        showScanned = true;
                      }
                    });
                  },
                ),
              );
            });
    });
  }
}


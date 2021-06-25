import 'package:aplikacija_za_inventuru/screens/home/filter.dart';
import 'package:aplikacija_za_inventuru/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aplikacija_za_inventuru/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:aplikacija_za_inventuru/screens/home/filterObject.dart';

class DatabaseService {

  FirebaseFirestore db = FirebaseFirestore.instance;

  FirebaseFirestore getDb() {
    return db;
  }

  Widget getData(bool showScanned, bool showByRoom, FilterObject? filter) {
    final Stream<QuerySnapshot> _predmetiStream = db.collection('predmeti').snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: _predmetiStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
    {
      if (snapshot.hasError) {
        return Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Loading();
      }

      return Column(
        children: _ucitaj(showScanned, showByRoom, filter, snapshot),
      );
    });
  }

  List<ScannedCard> _ucitaj(bool showScanned, bool showByRoom, FilterObject? filter, AsyncSnapshot<QuerySnapshot> snapshot) {
    List<ScannedCard> predmeti = List.empty(growable: true);
    Map<String, List<ListTile>> predmeti2 = new Map();
    snapshot.data!.docs.where((element) => showScanned ? element['datum'] != null : element['datum'] == null)
                       .where((element) {
                          if(filter == null) {
                            return true;
                          } else {
                            return filter.test(element);
                          }
                        })
                       .forEach((element) {
                          if(showByRoom) {
                            dodaj(predmeti2, showScanned, 'prostorija', element);
                          } else {
                            dodaj(predmeti2, showScanned, 'osoba', element);
                          }
                       });

    predmeti2.entries.forEach((element) {
      predmeti.add(ScannedCard(owner: element.key, predmeti: element.value));
    });
    return predmeti;
  }

  void dodaj(Map<String, List<ListTile>> predmeti2, bool showScanned, String value, element) {
    List<ListTile> lista = predmeti2.putIfAbsent(element[value], () => List<ListTile>.empty(growable: true));
    if(showScanned) {
      lista.add(ListTile(title: Text('Predmet: '+element['naziv']+', datum: '+element['datum'])));
    } else {
      lista.add(ListTile(title: Text('Predmet: '+element['naziv'])));
    }
  }

  void obrisiPredmete() {
    CollectionReference predmeti = db.collection('predmeti');
    predmeti.get().then((value) => {
      value.docs.forEach((element) {
        element.reference.delete();
      })
    });
  }

  void ocitaj(String inv_broj) async {
    CollectionReference predmeti = db.collection('predmeti');
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    await predmeti.doc(inv_broj).update({'datum': formattedDate});
  }

  void azuriraj(String inv_broj, String naziv, String opis, String osoba, String prostorija) async {
    CollectionReference predmeti = db.collection('predmeti');
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    await predmeti.doc(inv_broj).update({
      'datum': formattedDate,
      'opis' : opis,
      'naziv' : naziv,
      'osoba' : osoba,
      'prostorija' : prostorija,
    });
  }

}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterObject {
  List<dynamic> prostorije = List.empty(growable: true);
  List<dynamic> osobe = List.empty(growable: true);
  String naziv = '';

  FilterObject(this.prostorije, this.osobe, this.naziv);

  bool test(QueryDocumentSnapshot<Object?> element) {
    bool isPresentInRoom = false;
    bool isScannedByPerson = false;
    bool nameIsSimilar = false;
    for(String prostorija in prostorije) {
      if(element['prostorija'].toString() == prostorija) {
        isPresentInRoom = true;
      }
    }
    for(String osoba in osobe) {
      if(element['osoba'].toString() == osoba) {
        isScannedByPerson = true;
      }
    }
    if(naziv != '') {
      if(element['naziv'].toString().toUpperCase().contains(naziv.toUpperCase())) {
        nameIsSimilar = true;
      }
    }
    return (prostorije.length == 0 ? true : isPresentInRoom)
        && (osobe.length == 0 ? true : isScannedByPerson)
        && (naziv == '' ? true : nameIsSimilar);
  }
}
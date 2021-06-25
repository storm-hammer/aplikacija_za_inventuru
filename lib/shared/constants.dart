import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0)
  ),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent, width: 2.0)
  ),
);

const disabledTextInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabled: false, helperStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0)
    )
);

class ScannedCard extends StatefulWidget {
  final String owner;
  final List<ListTile> predmeti;

  ScannedCard({required this.owner, required this.predmeti});

  @override
  _ScannedCardState createState() => _ScannedCardState(owner: owner, predmeti: predmeti);
}

class _ScannedCardState extends State<ScannedCard> {
  final String owner;
  final List<ListTile> predmeti;

  _ScannedCardState({required this.owner, required this.predmeti});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        textColor: Colors.black,
        title: Text(owner,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        children: predmeti
    );
  }
}

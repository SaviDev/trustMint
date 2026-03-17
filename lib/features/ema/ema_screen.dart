import 'package:flutter/material.dart';

class EmaScreen extends StatelessWidget {
  final String emaId;
  const EmaScreen({super.key, required this.emaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EMA Survey')),
      body: Center(child: Text('Survey ID: $emaId')),
    );
  }
}

import 'package:flutter/material.dart';

class BandoDetailScreen extends StatelessWidget {
  final String bandoId;
  const BandoDetailScreen({super.key, required this.bandoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dettaglio Bando')),
      body: Center(child: Text('Bando ID: $bandoId')),
    );
  }
}

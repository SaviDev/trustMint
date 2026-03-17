import 'package:flutter/material.dart';

class BandiListScreen extends StatelessWidget {
  const BandiListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bandi Disponibili')),
      body: const Center(child: Text('Lista bandi')),
    );
  }
}


import 'package:flutter/material.dart';

class NotaFiscalView extends StatelessWidget {
  const NotaFiscalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota Fiscal'),
      ),
      body: const Center(
        child: Text(
          'Aqui vai ser nota fiscal',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

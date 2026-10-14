
import 'package:flutter/material.dart';

class NotaFiscalServicoView extends StatelessWidget {
  const NotaFiscalServicoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota Fiscal de Serviço'),
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

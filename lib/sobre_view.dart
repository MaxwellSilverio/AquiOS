
import 'package:flutter/material.dart';

class SobreView extends StatelessWidget {
  const SobreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o AquiOS'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AquiOS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Objetivo do aplicativo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 8),


              const Text(
                'Gerar e imprimir ordens de serviço simples '
                    'de forma rápida e sem complicações.',
              ),

              const SizedBox(height: 24),

              const Text(
                'Desenvolvido por',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text('Maxwell Carlos Silvério'),

              const SizedBox(height: 24),

              const Text(
                'Informações acadêmicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(height: 8),


              const Text(
                'Disciplina: Programação pra dispositivos móveis',
              ),


              const SizedBox(height: 8),


              const Text(
                'Instituição: Fatec Ribeirão Preto - SP',
              ),


              const SizedBox(height: 8),


              const Text('Professor: Rodrigo Plots'),

              const SizedBox(height: 24),

              const Text(
                'Versão do aplicativo: 1.0.0',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DadosProfissionaisView extends StatefulWidget {
  const DadosProfissionaisView({super.key});

  @override
  State<DadosProfissionaisView> createState() =>
      _DadosProfissionaisViewState();
}

class _DadosProfissionaisViewState
    extends State<DadosProfissionaisView> {
  final _nomeController = TextEditingController();
  final _documentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();


  @override
  void dispose() {
    _nomeController.dispose();
    _documentoController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }





  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final preferencias = await SharedPreferences.getInstance();           // Aqui faz carregar os dados

    _nomeController.text =
        preferencias.getString('nomeProfissional') ?? '';

    _documentoController.text =
        preferencias.getString('documentoProfissional') ?? '';

    _emailController.text =
        preferencias.getString('emailProfissional') ?? '';

    _telefoneController.text =
        preferencias.getString('telefoneProfissional') ?? '';

    _enderecoController.text =
        preferencias.getString('enderecoProfissional') ?? '';
  }







  Future<void> salvar() async {                                         // aqui que salva os dados
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome profissional.'),
        ),
      );
      return;
    }

    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString(
      'nomeProfissional',
      _nomeController.text.trim(),
    );

    await preferencias.setString(
      'documentoProfissional',
      _documentoController.text.trim(),
    );

    await preferencias.setString(
      'emailProfissional',
      _emailController.text.trim(),
    );

    await preferencias.setString(
      'telefoneProfissional',
      _telefoneController.text.trim(),
    );

    await preferencias.setString(
      'enderecoProfissional',
      _enderecoController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados profissionais salvos com sucesso!'),
      ),
    );
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus dados profissionais'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [



            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome profissional ou empresa',
                border: OutlineInputBorder(),
              ),
            ),



            const SizedBox(height: 16),



            TextField(
              controller: _documentoController,
              decoration: const InputDecoration(
                labelText: 'CPF ou CNPJ',
                border: OutlineInputBorder(),
              ),
            ),



            const SizedBox(height: 16),



            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail profissional',
                border: OutlineInputBorder(),
              ),
            ),



            const SizedBox(height: 16),



            TextField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),



            const SizedBox(height: 16),



            TextField(
              controller: _enderecoController,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
              ),
            ),



            const SizedBox(height: 24),




            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text('Salvar dados'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
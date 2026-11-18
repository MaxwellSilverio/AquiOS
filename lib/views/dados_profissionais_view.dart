import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



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
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (!mounted) return;

      final dados = documento.data() ?? {};

      setState(() {
        _nomeController.text =
            dados['nomeProfissional'] ??
                dados['nome'] ??
                usuario.displayName ??
                '';

        _documentoController.text =
            dados['documentoProfissional'] ?? '';

        _emailController.text =
            dados['emailProfissional'] ??
                dados['email'] ??
                usuario.email ??
                '';

        _telefoneController.text =
            dados['telefoneProfissional'] ??
                dados['telefone'] ??
                '';

        _enderecoController.text =
            dados['enderecoProfissional'] ?? '';
      });
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $erro'),
        ),
      );
    }
  }









  Future<void> salvar() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome profissional.'),
        ),
      );
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .set({
        'nomeProfissional': _nomeController.text.trim(),
        'documentoProfissional': _documentoController.text.trim(),
        'emailProfissional': _emailController.text.trim(),
        'telefoneProfissional': _telefoneController.text.trim(),
        'enderecoProfissional': _enderecoController.text.trim(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados profissionais salvos com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados: $erro'),
        ),
      );
    }
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
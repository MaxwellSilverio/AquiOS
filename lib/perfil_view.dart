
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'iniciar_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}




class _PerfilViewState extends State<PerfilView> {

  final _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nomeController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const InicioView(),
          ),
              (route) => false,
        );
      }
    });


  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }






  Future<void> salvar() async {
    String nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu nome.')),
      );
      return;
    }

    if (nome.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome deve ter pelo menos 3 caracteres.'),
        ),
      );
      return;
    }

    final usuarioAtual = FirebaseAuth.instance.currentUser;

    if (usuarioAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa fazer login para atualizar o perfil.'),
        ),
      );
      return;
    }

    await usuarioAtual.updateDisplayName(nome);
    await usuarioAtual.reload();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );

    setState(() {});
  }





  @override
  Widget build(BuildContext context) {
    final usuarioAtual = FirebaseAuth.instance.currentUser;

    if (usuarioAtual == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meu Perfil'),
        ),
        body: const Center(
          child: Text('Você precisa fazer login para acessar o perfil.'),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),



            const SizedBox(height: 16),




            TextFormField(
              initialValue: usuarioAtual.email ?? '',
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),



            const SizedBox(height: 24),



            ElevatedButton(
              onPressed: salvar,
              child: const Text('Salvar alterações'),
            ),
          ],
        ),
      ),
    );
  }
}

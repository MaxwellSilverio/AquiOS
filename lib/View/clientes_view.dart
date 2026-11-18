
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientesView extends StatefulWidget {
  const ClientesView({super.key});

  @override
  State<ClientesView> createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> {

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();











  Future<void> salvarCliente(
      String nome,
      String telefone,
      ) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('clientes')
        .add({
      'nome': nome,
      'telefone': telefone,
      'dataCadastro': Timestamp.now(),
      'uid': usuario.uid,
      'status': 'Ativo',
    });
  }






  Future<void> excluirCliente(String id) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('clientes')
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente excluído com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir cliente: $erro'),
        ),
      );
    }
  }








  Future<void> cadastrarCliente() async {
    if (_nomeController.text.trim().isEmpty ||
        _telefoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o nome e o telefone do cliente.'),
        ),
      );
      return;
    }

    try {
      await salvarCliente(
        _nomeController.text.trim(),
        _telefoneController.text.trim(),
      );

      if (!mounted) return;

      _nomeController.clear();
      _telefoneController.clear();



      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente cadastrado com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar cliente: $erro'),
        ),
      );
    }
  }


  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cadastro de clientes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),


            const Text(
              'Cadastre as informações do seu cliente.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do cliente',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 16),





            TextField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),






            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(


                onPressed: cadastrarCliente,


                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Cadastrar cliente'),
              ),
            ),





            const SizedBox(height: 24),
            const Text(
              'Clientes cadastrados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('clientes')
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Erro ao carregar clientes.'),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final clientes = snapshot.data!.docs;

                  if (clientes.isEmpty) {
                    return const Center(
                      child: Text('Nenhum cliente cadastrado.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente =
                      clientes[index].data() as Map<String, dynamic>;

                      final id = clientes[index].id;

                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.lightBlue,
                          ),
                          title: Text(cliente['nome'] ?? ''),
                          subtitle: Text(cliente['telefone'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            tooltip: 'Excluir cliente',
                            onPressed: () {
                              excluirCliente(id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),




          ],
        ),
      ),
    );
  }
}

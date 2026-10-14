
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClientesView extends StatefulWidget {
  const ClientesView({super.key});

  @override
  State<ClientesView> createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> {

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();


  final List<Map<String, String>> _clientes = [];




  @override
  void initState() {
    super.initState();
    carregarClientes();
  }

  Future<void> carregarClientes() async {
    final preferencias = await SharedPreferences.getInstance();
    final dados = preferencias.getString('listaClientes');

    if (dados != null) {
      final List lista = jsonDecode(dados);

      setState(() {
        _clientes.clear();

        for (final item in lista) {
          _clientes.add(Map<String, String>.from(item));
        }
      });
    }
  }


  Future<void> salvarClientes() async {
    final preferencias = await SharedPreferences.getInstance();

    final dados = jsonEncode(_clientes);

    await preferencias.setString('listaClientes', dados);
  }


  Future<void> excluirCliente(int index) async {
    setState(() {
      _clientes.removeAt(index);
    });

    await salvarClientes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cliente excluído com sucesso!'),
      ),
    );
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

    setState(() {
      _clientes.add({
        'nome': _nomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
      });
    });

    await salvarClientes();


    _nomeController.clear();
    _telefoneController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cliente cadastrado com sucesso!'),
      ),
    );
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
              child: ListView.builder(                //Listview
                itemCount: _clientes.length,
                itemBuilder: (context, index) {
                  final cliente = _clientes[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Colors.lightBlue,
                      ),
                      title: Text(cliente['nome']!),
                      subtitle: Text(cliente['telefone']!),




                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir cliente',
                        onPressed: () {
                          excluirCliente(index);
                        },
                      ),


                    ),
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

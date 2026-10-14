
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProdutosServicosView extends StatefulWidget {
  const ProdutosServicosView({super.key});

  @override
  State<ProdutosServicosView> createState() =>
      _ProdutosServicosViewState();
}

class _ProdutosServicosViewState extends State<ProdutosServicosView> {
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();

  String _tipoSelecionado = 'Serviço';
  final List<Map<String, String>> _itens = [];

  @override
  void initState() {
    super.initState();
    carregarItens();
  }

  Future<void> carregarItens() async {
    final preferencias = await SharedPreferences.getInstance();
    final dados = preferencias.getString('listaProdutosServicos');

    if (dados != null && mounted) {
      final List lista = jsonDecode(dados);

      setState(() {
        _itens.clear();
        for (final item in lista) {
          _itens.add(Map<String, String>.from(item));
        }
      });
    }
  }

  Future<void> salvarItens() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(
      'listaProdutosServicos',
      jsonEncode(_itens),
    );
  }

  Future<void> cadastrarItem() async {
    final nome = _nomeController.text.trim();
    final precoTexto = _precoController.text.trim().replaceAll(',', '.');
    final preco = double.tryParse(precoTexto);

    if (nome.isEmpty || preco == null || preco < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome e um preço válido.'),
        ),
      );
      return;
    }

    setState(() {
      _itens.add({
        'nome': nome,
        'tipo': _tipoSelecionado,
        'preco': preco.toStringAsFixed(2),
      });
    });

    await salvarItens();

    _nomeController.clear();
    _precoController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item cadastrado com sucesso!'),
      ),
    );
  }

  Future<void> excluirItem(int index) async {
    setState(() {
      _itens.removeAt(index);
    });

    await salvarItens();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos e Serviços'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cadastrar item',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do produto ou serviço',
                prefixIcon: Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Produto',
                  child: Text('Produto'),
                ),
                DropdownMenuItem(
                  value: 'Serviço',
                  child: Text('Serviço'),
                ),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _tipoSelecionado = valor;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _precoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Preço (R\$)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: cadastrarItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar item'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Itens cadastrados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _itens.isEmpty
                  ? const Center(
                child: Text('Nenhum item cadastrado.'),
              )
                  : ListView.builder(
                itemCount: _itens.length,
                itemBuilder: (context, index) {
                  final item = _itens[index];

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        item['tipo'] == 'Produto'
                            ? Icons.inventory_2
                            : Icons.build,
                        color: Colors.lightBlue,
                      ),
                      title: Text(item['nome']!),
                      subtitle: Text(
                        '${item['tipo']} • R\$ ${item['preco']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: 'Excluir item',
                        onPressed: () => excluirItem(index),
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

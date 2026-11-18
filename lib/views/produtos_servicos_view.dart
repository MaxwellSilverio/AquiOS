
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



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
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      final consulta = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('produtos_servicos')
          .get();

      if (!mounted) return;

      setState(() {
        _itens.clear();

        for (final documento in consulta.docs) {
          final dados = documento.data();

          _itens.add({
            'id': documento.id,
            'nome': dados['nome'].toString(),
            'tipo': dados['tipo'].toString(),
            'preco': dados['preco'].toString(),
          });
        }
      });
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar itens: $erro'),
        ),
      );
    }
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

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('produtos_servicos')
          .add({
        'nome': nome,
        'tipo': _tipoSelecionado,
        'preco': preco,
        'dataCadastro': Timestamp.now(),
        'uid': usuario.uid,
        'status': 'Ativo',
      });

      _nomeController.clear();
      _precoController.clear();

      await carregarItens();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item cadastrado com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar item: $erro'),
        ),
      );
    }
  }






  Future<void> excluirItem(int index) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      final id = _itens[index]['id'];

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('produtos_servicos')
          .doc(id)
          .delete();

      await carregarItens();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item excluído com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir item: $erro'),
        ),
      );
    }
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

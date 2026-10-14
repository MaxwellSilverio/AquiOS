
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'orcamento_pdf.dart';

class OrcamentosView extends StatefulWidget {
  const OrcamentosView({super.key});

  @override
  State<OrcamentosView> createState() => _OrcamentosViewState();
}

class _OrcamentosViewState extends State<OrcamentosView> {
  List<Map<String, String>> _clientes = [];
  List<Map<String, String>> _itensDisponiveis = [];
  final List<Map<String, String>> _itensOrcamento = [];

  String? _clienteSelecionado;
  String? _itemSelecionado;

  final _quantidadeController =
  TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final preferencias = await SharedPreferences.getInstance();

    final dadosClientes =
    preferencias.getString('listaClientes');

    final dadosItens =
    preferencias.getString('listaProdutosServicos');

    if (!mounted) return;

    setState(() {
      if (dadosClientes != null) {
        _clientes = (jsonDecode(dadosClientes) as List)
            .map((item) => Map<String, String>.from(item))
            .toList();
      }

      if (dadosItens != null) {
        _itensDisponiveis = (jsonDecode(dadosItens) as List)
            .map((item) => Map<String, String>.from(item))
            .toList();
      }
    });
  }

  double get total {
    double soma = 0;

    for (final item in _itensOrcamento) {
      soma += double.parse(item['preco']!) *
          int.parse(item['quantidade']!);
    }

    return soma;
  }

  void adicionarItem() {
    if (_itemSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um produto ou serviço.'),
        ),
      );
      return;
    }

    final quantidade =
    int.tryParse(_quantidadeController.text.trim());

    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade válida.'),
        ),
      );
      return;
    }

    final item = _itensDisponiveis.firstWhere(
          (item) => item['nome'] == _itemSelecionado,
    );

    setState(() {
      _itensOrcamento.add({
        'nome': item['nome']!,
        'tipo': item['tipo']!,
        'preco': item['preco']!,
        'quantidade': quantidade.toString(),
      });

      _itemSelecionado = null;
    });

    _quantidadeController.text = '1';
  }








  Future<void> salvarOrcamento() async {
    if (_clienteSelecionado == null ||
        _itensOrcamento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione um cliente e adicione pelo menos um item.',
          ),
        ),
      );
      return;
    }

    final preferencias = await SharedPreferences.getInstance();

    final dadosAtuais =
    preferencias.getString('listaOrcamentos');

    final List<Map<String, dynamic>> orcamentos =
    dadosAtuais == null
        ? []
        : (jsonDecode(dadosAtuais) as List)
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();



    final numerosExistentes = orcamentos
        .map((orcamento) =>
    int.tryParse('${orcamento['numero']}') ?? 0)
        .toList();                                              //O primeiro orçamento novo recebe 0001 e o segundo 0002

    final proximoNumero = numerosExistentes.isEmpty
        ? 1
        : numerosExistentes.reduce(
          (maior, numero) => numero > maior ? numero : maior,
    ) + 1;




    orcamentos.add({
      'numero': proximoNumero.toString().padLeft(4, '0'),
      'cliente': _clienteSelecionado!,
      'itens': List<Map<String, String>>.from(
        _itensOrcamento,
      ),
      'total': total.toStringAsFixed(2),
      'data': DateTime.now().toIso8601String(),
      'status': 'Pendente',
    });

    await preferencias.setString(
      'listaOrcamentos',
      jsonEncode(orcamentos),
    );

    if (!mounted) return;

    setState(() {
      _clienteSelecionado = null;
      _itemSelecionado = null;
      _itensOrcamento.clear();
      _quantidadeController.text = '1';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Orçamento salvo com sucesso!'),
      ),
    );
  }
















  Future<void> verOrcamentosSalvos() async {
    final preferencias = await SharedPreferences.getInstance();

    final dados =
    preferencias.getString('listaOrcamentos');

    final List<Map<String, dynamic>> orcamentos =
    dados == null
        ? []
        : (jsonDecode(dados) as List)
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Orçamentos salvos'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: orcamentos.isEmpty
                ? const Center(
              child: Text('Nenhum orçamento salvo.'),
            )
                : ListView.builder(
              itemCount: orcamentos.length,
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];

                final data =
                (orcamento['data'] ?? '').toString();

                final dataFormatada =
                data.length >= 10
                    ? '${data.substring(8, 10)}/'
                    '${data.substring(5, 7)}/'
                    '${data.substring(0, 4)}'
                    : data;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      color: Colors.lightBlue,
                    ),
                    title: Text(
                      orcamento['cliente']
                          ?.toString() ??
                          'Cliente',
                    ),
                    subtitle: Text(
                      'Data: $dataFormatada\n'
                          'Status: ${orcamento['status'] ?? 'Pendente'}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          tooltip: 'Excluir orçamento',
                          onPressed: () {
                            excluirOrcamento(index);
                          },
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      verDetalhesOrcamento(orcamento);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }










  void verDetalhesOrcamento(
      Map<String, dynamic> orcamento,
      ) {
    final itens = (orcamento['itens'] as List? ?? [])
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalhes do orçamento'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cliente: ${orcamento['cliente'] ?? 'Cliente'}',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Produtos e serviços:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      final item = itens[index];

                      final preco =
                          double.tryParse(
                            '${item['preco']}',
                          ) ??
                              0;

                      final quantidade =
                          int.tryParse(
                            '${item['quantidade']}',
                          ) ??
                              0;

                      final subtotal = preco * quantidade;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${item['nome'] ?? 'Item'}',
                        ),
                        subtitle: Text(
                          '$quantidade x R\$ ${preco.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          'R\$ ${subtotal.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Text(
                  'Total: R\$ ${orcamento['total'] ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final data = '${orcamento['data'] ?? ''}';
                final ano = data.length >= 4
                    ? data.substring(2, 4)
                    : '00';

                gerarPdfOrcamento(
                  orcamento,
                  '${(orcamento['numero'] ?? '0001')}-$ano',
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Gerar PDF'),
            ),
          ],
        );
      },
    );
  }











  Future<void> excluirOrcamento(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir orçamento'),
          content: const Text(
            'Tem certeza de que deseja excluir este orçamento?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    final preferencias = await SharedPreferences.getInstance();

    final dados =
    preferencias.getString('listaOrcamentos');

    if (dados == null) return;

    final List<Map<String, dynamic>> orcamentos =
    (jsonDecode(dados) as List)
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();

    if (index < 0 || index >= orcamentos.length) return;

    orcamentos.removeAt(index);

    await preferencias.setString(
      'listaOrcamentos',
      jsonEncode(orcamentos),
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Orçamento excluído com sucesso!'),
      ),
    );

    verOrcamentosSalvos();
  }







  Future<void> gerarPdfOrcamento(
      Map<String, dynamic> orcamento,
      String numero,
      ) async {
    final garantiaController =
    TextEditingController(text: '1 Ano');

    final garantia = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Garantia do orçamento'),
          content: TextField(
            controller: garantiaController,
            decoration: const InputDecoration(
              labelText: 'Garantia',
              hintText: 'Ex.: 1 Ano',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  garantiaController.text.trim(),
                );
              },
              child: const Text('Gerar PDF'),
            ),
          ],
        );
      },
    );

    garantiaController.dispose();

    if (garantia == null || garantia.isEmpty) {
      return;
    }

    try {
      await OrcamentoPdf.gerar(
        orcamento: orcamento,
        garantia: garantia,
        numero: numero,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
        ),
      );
    }
  }













  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos e Ordens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver orçamentos salvos',
            onPressed: verOrcamentosSalvos,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Novo orçamento',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _clienteSelecionado,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: _clientes.map((cliente) {
                return DropdownMenuItem<String>(
                  value: cliente['nome'],
                  child: Text(
                    cliente['nome']!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _clienteSelecionado = valor;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _itemSelecionado,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Produto ou serviço',
                prefixIcon: Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
              items: _itensDisponiveis.map((item) {
                return DropdownMenuItem<String>(
                  value: item['nome'],
                  child: Text(
                    '${item['nome']} - R\$ ${item['preco']}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _itemSelecionado = valor;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: adicionarItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar item'),
            ),

            const SizedBox(height: 20),

            const Text(
              'Itens do orçamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (_itensOrcamento.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('Nenhum item adicionado.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount: _itensOrcamento.length,
                itemBuilder: (context, index) {
                  final item = _itensOrcamento[index];

                  final subtotal =
                      double.parse(item['preco']!) *
                          int.parse(item['quantidade']!);

                  return Card(
                    child: ListTile(
                      title: Text(
                        item['nome']!,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${item['quantidade']} x R\$ ${item['preco']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'R\$ ${subtotal.toStringAsFixed(2)}',
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            visualDensity:
                            VisualDensity.compact,
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _itensOrcamento
                                    .removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 12),

            Text(
              'Total: R\$ ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: salvarOrcamento,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              icon: const Icon(Icons.save),
              label: const Text('Salvar orçamento'),
            ),
          ],
        ),
      ),
    );
  }
}

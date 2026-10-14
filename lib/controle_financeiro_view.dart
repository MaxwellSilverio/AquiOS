
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControleFinanceiroView extends StatefulWidget {
  const ControleFinanceiroView({super.key});

  @override
  State<ControleFinanceiroView> createState() =>
      _ControleFinanceiroViewState();
}

class _ControleFinanceiroViewState
    extends State<ControleFinanceiroView> {
  List<Map<String, dynamic>> _orcamentos = [];

  @override
  void initState() {
    super.initState();
    carregarOrcamentos();
  }

  Future<void> carregarOrcamentos() async {
    final preferencias = await SharedPreferences.getInstance();
    final dados = preferencias.getString('listaOrcamentos');

    if (!mounted) return;

    setState(() {
      if (dados == null) {
        _orcamentos = [];
      } else {
        _orcamentos = (jsonDecode(dados) as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    });
  }

  double converterTotal(dynamic valor) {
    if (valor is num) {
      return valor.toDouble();
    }

    if (valor is String) {
      return double.tryParse(valor.replaceAll(',', '.')) ?? 0.0;
    }

    return 0.0;
  }

  double get totalReceitas {
    return _orcamentos.fold(0.0, (total, orcamento) {
      return total + converterTotal(orcamento['total']);
    });
  }

  double get totalRecebido {
    return _orcamentos.fold(0.0, (total, orcamento) {
      if (orcamento['pagamento'] == 'Recebido') {
        return total + converterTotal(orcamento['total']);
      }

      return total;
    });
  }

  double get totalPendente => totalReceitas - totalRecebido;

  String formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }



  Future<void> excluirOrcamento(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir orçamento'),
        content: const Text(
          'Deseja realmente excluir este orçamento? '
              'Ele também será removido da agenda e do histórico.',
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
      ),
    );

    if (confirmar != true) return;

    final preferencias = await SharedPreferences.getInstance();

    setState(() {
      _orcamentos.removeAt(index);
    });

    await preferencias.setString(
      'listaOrcamentos',
      jsonEncode(_orcamentos),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Orçamento excluído com sucesso!'),
      ),
    );
  }



  Future<void> alterarPagamento(
      int index,
      String pagamento,
      ) async {
    final preferencias = await SharedPreferences.getInstance();

    setState(() {
      _orcamentos[index]['pagamento'] = pagamento;
    });

    await preferencias.setString(
      'listaOrcamentos',
      jsonEncode(_orcamentos),
    );
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
      ),
      body: _orcamentos.isEmpty
          ? const Center(
        child: Text('Nenhum orçamento cadastrado.'),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Total de receitas'),
              subtitle: Text(
                formatarValor(totalReceitas),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Total recebido'),
              subtitle: Text(
                formatarValor(totalRecebido),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Total pendente'),
              subtitle: Text(
                formatarValor(totalPendente),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pagamentos dos serviços',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_orcamentos.length, (index) {
            final orcamento = _orcamentos[index];
            final pagamento =
                orcamento['pagamento'] ?? 'Pendente';

            return Card(
              child: ListTile(
                title: Text(
                  '${orcamento['cliente'] ?? 'Cliente'}',
                ),
                subtitle: Text(
                  'Valor: ${formatarValor(converterTotal(orcamento['total']))}\n'
                      'Pagamento: $pagamento',
                ),
                isThreeLine: true,



                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: pagamento,
                      items: const [
                        DropdownMenuItem(
                          value: 'Pendente',
                          child: Text('Pendente'),
                        ),
                        DropdownMenuItem(
                          value: 'Recebido',
                          child: Text('Recebido'),
                        ),
                      ],
                      onChanged: (novoPagamento) {
                        if (novoPagamento != null) {
                          alterarPagamento(index, novoPagamento);
                        }
                      },
                    ),
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
                  ],
                ),






              ),
            );
          }),
        ],
      ),
    );
  }
}

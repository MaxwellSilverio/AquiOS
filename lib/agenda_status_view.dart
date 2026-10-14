
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgendaStatusView extends StatefulWidget {
  const AgendaStatusView({super.key});

  @override
  State<AgendaStatusView> createState() => _AgendaStatusViewState();
}

class _AgendaStatusViewState extends State<AgendaStatusView> {
  List<Map<String, dynamic>> _orcamentos = [];
  final Map<int, DateTime> _datasAgendadas = {};

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






  Future<void> excluirOrcamento(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir orçamento'),
        content: const Text(
          'Deseja realmente excluir este orçamento? '
              'Ele também será removido do histórico e do controle financeiro.',
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







  Future<void> selecionarData(int index) async {
    final hoje = DateTime.now();

    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _datasAgendadas[index] ?? hoje,
      firstDate: DateTime(hoje.year - 1),
      lastDate: DateTime(hoje.year + 5),
      helpText: 'Selecione a data do serviço',
    );

    if (dataEscolhida == null) return;

    final preferencias = await SharedPreferences.getInstance();

    setState(() {
      _datasAgendadas[index] = dataEscolhida;

      _orcamentos[index]['dataAgendada'] =
          dataEscolhida.toIso8601String();
    });

    await preferencias.setString(
      'listaOrcamentos',
      jsonEncode(_orcamentos),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data do serviço salva com sucesso!'),
      ),
    );
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda e Status'),
      ),
      body: _orcamentos.isEmpty
          ? const Center(
        child: Text('Nenhum orçamento cadastrado.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orcamentos.length,
        itemBuilder: (context, index) {
          final orcamento = _orcamentos[index];
          final data = '${orcamento['data'] ?? ''}';

          final dataFormatada = data.length >= 10
              ? '${data.substring(8, 10)}/'
              '${data.substring(5, 7)}/'
              '${data.substring(0, 4)}'
              : 'Sem data';


          final dataAgendada =
              '${orcamento['dataAgendada'] ?? ''}';

          final dataAgendadaFormatada = dataAgendada.length >= 10
              ? '${dataAgendada.substring(8, 10)}/'
              '${dataAgendada.substring(5, 7)}/'
              '${dataAgendada.substring(0, 4)}'
              : 'Não agendado';


          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: Colors.lightBlue,
              ),
              title: Text(
                '${orcamento['cliente'] ?? 'Cliente'}',
              ),



              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Criado em: $dataFormatada'),
                  Text('Agendado para: $dataAgendadaFormatada'),
                  Text('Status: ${orcamento['status'] ?? 'Pendente'}'),               // nesse código faz a seleção dos status
                  DropdownButton<String>(
                    value: [
                      'Pendente',
                      'Agendado',
                      'Em andamento',
                      'Concluído',
                    ].contains(orcamento['status'])
                        ? orcamento['status']
                        : 'Pendente',
                    items: [
                      'Pendente',
                      'Agendado',
                      'Em andamento',
                      'Concluído',
                    ].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (novoStatus) async {
                      if (novoStatus == null) return;

                      final preferencias =
                      await SharedPreferences.getInstance();

                      setState(() {
                        orcamento['status'] = novoStatus;
                      });

                      await preferencias.setString(
                        'listaOrcamentos',
                        jsonEncode(_orcamentos),
                      );
                    },
                  ),
                ],
              ),





              isThreeLine: true,



              trailing: SizedBox(
                width: 105,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.lightBlue,
                      ),
                      tooltip: 'Agendar serviço',
                      onPressed: () {
                        selecionarData(index);
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





            ),
          );
        },
      ),
    );
  }
}

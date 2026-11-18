import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      final consulta = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('orcamentos')
          .orderBy('data', descending: true)
          .get();

      if (!mounted) return;

      setState(() {
        _orcamentos = consulta.docs.map((documento) {
          final dados = documento.data();

          return {
            ...dados,
            'id': documento.id,
          };
        }).toList();

        _datasAgendadas.clear();

        for (int i = 0; i < _orcamentos.length; i++) {
          final data = _orcamentos[i]['dataAgendada'];

          if (data is Timestamp) {
            _datasAgendadas[i] = data.toDate();
          }
        }
      });
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar orçamentos: $erro'),
        ),
      );
    }
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

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      final id = _orcamentos[index]['id'];

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('orcamentos')
          .doc(id)
          .delete();

      if (!mounted) return;

      setState(() {
        _orcamentos.removeAt(index);
        _datasAgendadas.remove(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orçamento excluído com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir orçamento: $erro'),
        ),
      );
    }
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

    if (dataEscolhida == null || !mounted) return;

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) return;

    try {
      final id = _orcamentos[index]['id'];

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('orcamentos')
          .doc(id)
          .update({
        'dataAgendada': Timestamp.fromDate(dataEscolhida),
      });

      if (!mounted) return;

      setState(() {
        _datasAgendadas[index] = dataEscolhida;
        _orcamentos[index]['dataAgendada'] =
            Timestamp.fromDate(dataEscolhida);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data do serviço salva com sucesso!'),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar data: $erro'),
        ),
      );
    }
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

          final data = orcamento['data'];
          final DateTime? dataCriacao =
          data is Timestamp ? data.toDate() : null;

          final dataFormatada = dataCriacao == null
              ? 'Sem data'
              : '${dataCriacao.day.toString().padLeft(2, '0')}/'
              '${dataCriacao.month.toString().padLeft(2, '0')}/'
              '${dataCriacao.year}';

          final dataAgendada = orcamento['dataAgendada'];
          final DateTime? dataAgendamento =
          dataAgendada is Timestamp ? dataAgendada.toDate() : null;

          final dataAgendadaFormatada = dataAgendamento == null
              ? 'Não agendado'
              : '${dataAgendamento.day.toString().padLeft(2, '0')}/'
              '${dataAgendamento.month.toString().padLeft(2, '0')}/'
              '${dataAgendamento.year}';

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

                      final usuario = FirebaseAuth.instance.currentUser;

                      if (usuario == null) return;

                      try {
                        final id = orcamento['id'];

                        await FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(usuario.uid)
                            .collection('orcamentos')
                            .doc(id)
                            .update({
                          'status': novoStatus,
                        });

                        if (!mounted) return;

                        setState(() {
                          orcamento['status'] = novoStatus;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status atualizado com sucesso!'),
                          ),
                        );
                      } catch (erro) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar status: $erro'),
                          ),
                        );
                      }
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

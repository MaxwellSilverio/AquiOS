import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


import 'cadastrar_controller.dart';
import 'app_routes.dart';

class ExibirView extends StatelessWidget {
  const ExibirView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = GetIt.I.get<CadastrarController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados cadastrados'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: ctrl,
          builder: (context, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Cadastro realizado',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall,
                      ),

                      const SizedBox(height: 24),

                      Card(
                        elevation: 0,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _ItemInformacao(
                                icone: Icons.person_outline,
                                titulo: 'Nome',
                                valor: ctrl.nome,
                              ),

                              const Divider(height: 32),

                              _ItemInformacao(
                                icone: Icons.email_outlined,
                                titulo: 'E-mail',
                                valor: ctrl.email,
                              ),

                              _ItemInformacao(
                                icone: Icons.phone_outlined,
                                titulo: 'Telefone',
                                valor: ctrl.telefone,
                              ),

                              const Divider(height: 32),

                              _ItemInformacao(
                                icone: ctrl
                                    .receberNotificacoes
                                    ? Icons
                                    .notifications_active_outlined
                                    : Icons
                                    .notifications_off_outlined,
                                titulo: 'Receber notificações',
                                valor: ctrl
                                    .notificacoesFormatadas,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar cadastro'),
                      ),

                      const SizedBox(height: 12),




                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName(
                              AppRoutes.inicio,
                            ),
                          );
                        },
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Voltar ao início'),
                      ),





                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          ctrl.limpar();

                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.cadastrar,
                          );
                        },
                        child: const Text(
                          'Realizar um novo cadastro',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ItemInformacao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _ItemInformacao({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icone,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor.isEmpty ? 'Não informado' : valor,
                style:
                Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
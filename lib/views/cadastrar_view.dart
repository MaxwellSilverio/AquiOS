import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../controllers/cadastrar_controller.dart';
import '../config/app_routes.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastrarView extends StatefulWidget {
  const CadastrarView({super.key});

  @override
  State<CadastrarView> createState() => _CadastrarViewState();
}

class _CadastrarViewState extends State<CadastrarView> {
  final ctrl = GetIt.I.get<CadastrarController>();
  bool _carregando = false;

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;
  final TextEditingController _senhaController =  TextEditingController();

  final TextEditingController _confirmarSenhaController =  TextEditingController();



  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(
      text: ctrl.nome,
    );

    _emailController = TextEditingController(
      text: ctrl.email,
    );

    _telefoneController = TextEditingController(
      text: ctrl.telefone,
    );

  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _confirmarSenhaController.dispose();

    super.dispose();
  }





  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();

    final formularioValido =
        _formKey.currentState?.validate() ?? false;

    if (!formularioValido) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final credencial =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );

      await credencial.user?.updateDisplayName(
        _nomeController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(credencial.user!.uid)
          .set({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'receberNotificacoes': ctrl.receberNotificacoes,
        'dataCadastro': FieldValue.serverTimestamp(),
      });

      ctrl.alterarNome(_nomeController.text.trim());
      ctrl.alterarEmail(_emailController.text.trim());
      ctrl.alterarTelefone(_telefoneController.text.trim());

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.exibir,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;

      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este e-mail já possui uma conta.';
          break;
        case 'weak-password':
          mensagem = 'A senha é muito fraca.';
          break;
        case 'invalid-email':
          mensagem = 'O e-mail informado é inválido.';
          break;
        case 'network-request-failed':
          mensagem = 'Verifique sua conexão com a internet.';
          break;
        default:
          mensagem = 'Não foi possível realizar o cadastro.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro ao realizar o cadastro.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: ctrl,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.person_add_alt_1,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),




                            const SizedBox(height: 16),




                            Text(
                              'Dados do usuário',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Preencha os campos abaixo para continuar.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),




                            const SizedBox(height: 32),




                            TextFormField(
                              controller: _nomeController,
                              textInputAction:
                              TextInputAction.next,
                              textCapitalization:
                              TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Nome',
                                hintText: 'Digite seu nome',
                                prefixIcon:
                                Icon(Icons.person_outline),
                              ),
                              onChanged:
                              ctrl.alterarNome,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Informe o nome.';
                                }

                                if (value.trim().length < 3) {
                                  return 'O nome deve ter pelo menos 3 caracteres.';
                                }

                                return null;
                              },
                            ),




                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _emailController,
                              keyboardType:
                              TextInputType.emailAddress,
                              textInputAction:
                              TextInputAction.done,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                hintText: 'nome@exemplo.com',
                                prefixIcon:
                                Icon(Icons.email_outlined),
                              ),
                              onChanged:
                              ctrl.alterarEmail,
                              onFieldSubmitted: (_) => _salvar(),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Informe o e-mail.';
                                }

                                final emailValido = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(value.trim());

                                if (!emailValido) {
                                  return 'Informe um e-mail válido.';
                                }

                                return null;
                              },
                            ),




                            const SizedBox(height: 16),


                            TextFormField(
                              controller: _telefoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Telefone',
                                hintText: '(16) 99999-9999',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              onChanged: ctrl.alterarTelefone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o telefone.';
                                }

                                if (value.trim().length < 8) {
                                  return 'Informe um telefone válido.';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),




                            TextFormField(
                              controller: _senhaController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                                hintText: 'Crie uma senha',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe a senha.';
                                }

                                if (value.length < 8) {
                                  return 'A senha deve ter pelo menos 8 caracteres.';
                                }

                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Inclua pelo menos uma letra maiúscula.';
                                }

                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'Inclua pelo menos uma letra minúscula.';
                                }

                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'Inclua pelo menos um número.';
                                }

                                return null;
                              },
                            ),





                            const SizedBox(height: 16),




                            TextFormField(
                              controller: _confirmarSenhaController,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Confirmar senha',
                                hintText: 'Digite a senha novamente',
                                prefixIcon: Icon(Icons.lock_reset_outlined),
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirme sua senha.';
                                }

                                if (value != _senhaController.text) {
                                  return 'As senhas não coincidem.';
                                }

                                return null;
                              },

                            ),





                            const SizedBox(height: 16),





                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Receber notificações',
                              ),
                              subtitle: Text(
                                ctrl.receberNotificacoes
                                    ? 'As notificações estão ativadas.'
                                    : 'As notificações estão desativadas.',
                              ),
                              secondary: Icon(
                                ctrl.receberNotificacoes
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_off_outlined,
                              ),
                              value:
                              ctrl.receberNotificacoes,
                              onChanged: ctrl
                                  .alterarReceberNotificacoes,
                            ),





                            const SizedBox(height: 32),





                            FilledButton.icon(
                              onPressed: _carregando ? null : _salvar,
                              icon: _carregando
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                _carregando ? 'Cadastrando...' : 'Salvar e exibir',
                              ),
                            ),

                            const SizedBox(height: 12),

                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text(
                                'Voltar para o início',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
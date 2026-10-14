import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'cadastrar_controller.dart';
import 'app_routes.dart';

import 'principal_view.dart';

import 'recuperar_senha_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sobre_view.dart';


class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _ocultarSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    final ctrl = GetIt.I.get<CadastrarController>();

    return Scaffold(

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 320,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [



                    Image.asset(
                      'assets/images/aquios_logo.jpeg',
                      height: 100,
                    ),




                    const SizedBox(height: 12),


                    const Text(
                      'AquiOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 32),



                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu e-mail.';
                        }

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                          return 'Informe um e-mail válido.';
                        }

                        return null;
                      },
                    ),




                    const SizedBox(height: 16),


                    TextFormField(
                      controller: _senhaController,
                      obscureText: _ocultarSenha,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _ocultarSenha = !_ocultarSenha;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe sua senha.';
                        }

                        return null;
                      },
                    ),




                    const SizedBox(height: 24),





                    FilledButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _senhaController.text,
                          );

                          if (!mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrincipalView(),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) return;

                          String mensagem = 'E-mail ou senha incorretos.';

                          if (e.code == 'network-request-failed') {
                            mensagem = 'Verifique sua conexão com a internet.';
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(mensagem)),
                          );
                        }
                      },
                      child: const Text('Entrar'),
                    ),





                    const SizedBox(height: 8),

                    FilledButton(
                      onPressed: () {
                        ctrl.limpar();
                        Navigator.pushNamed(
                          context,
                          AppRoutes.cadastrar,
                        );
                      },
                      child: const Text('Cadastrar usuário'),
                    ),

                    const SizedBox(height: 8),

                    FilledButton(


                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecuperarSenhaView(),
                          ),
                        );
                      },


                      child: const Text('Esqueceu a senha?'),
                    ),


                    const SizedBox(height: 8),

                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SobreView(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Sobre'),
                    ),



                  ],
                ),
              ),
            ),
          ),
        ),
      ),



    );
  }
}

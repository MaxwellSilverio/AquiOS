import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';


class RecuperarSenhaView extends StatefulWidget {
  const RecuperarSenhaView({super.key});

  @override
  State<RecuperarSenhaView> createState() =>
      _RecuperarSenhaViewState();
}



class _RecuperarSenhaViewState
    extends State<RecuperarSenhaView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar senha'),
      ),



      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 320,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_reset,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Esqueceu sua senha?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),



                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Informe seu e-mail.';
                      }


                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'Informe um e-mail válido.';
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
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: _emailController.text.trim(),
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Se houver uma conta com esse e-mail, você receberá as instruções de recuperação.',
                            ),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.code == 'network-request-failed'
                                  ? 'Verifique sua conexão com a internet.'
                                  : 'Não foi possível solicitar a recuperação. Tente novamente.',
                            ),
                          ),
                        );
                      }
                    },





                    child: const Text(
                      'Solicitar recuperação',
                    ),
                  ),



                ],
              ),
            ),
          ),
        ),
      ),


    );
  }
}
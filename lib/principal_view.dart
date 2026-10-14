import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'perfil_view.dart';
import 'dados_profissionais_view.dart';

import 'clientes_view.dart';

import 'produtos_servicos_view.dart';

import 'orcamentos_view.dart';
import 'agenda_status_view.dart';

import 'controle_financeiro_view.dart';

import 'nota_fiscal_view.dart';
import 'nota_fiscal_servico_view.dart';


class PrincipalView extends StatelessWidget {
  const PrincipalView({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final nome = usuario?.displayName ?? 'usuário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('AquiOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Meu Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerfilView(),
                ),
              );
            },
          ),
        ],
      ),


      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bem-vindo, $nome!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DadosProfissionaisView(),
                  ),
                );
              },

              icon: const Icon(Icons.business),
              label: const Text('Meus dados profissionais'),
            ),



            const SizedBox(height: 20),



            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClientesView(),
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Clientes'),
            ),




            const SizedBox(height: 20),




            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProdutosServicosView(),
                  ),
                );
              },
              icon: const Icon(Icons.inventory_2),
              label: const Text('Produtos e Serviços'),
            ),



            const SizedBox(height: 20),




            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrcamentosView(),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('Orçamentos e Ordens'),
            ),



            const SizedBox(height: 20),



            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgendaStatusView(),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Agenda e Status'),
            ),






            const SizedBox(height: 20),





            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ControleFinanceiroView(),
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Controle Financeiro'),
            ),




            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 110,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotaFiscalView(),
                          ),
                        );
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 30),
                          SizedBox(height: 8),
                          Text('Nota Fiscal'),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: SizedBox(
                    height: 110,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const NotaFiscalServicoView(),
                          ),
                        );
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description, size: 30),
                          SizedBox(height: 8),
                          Text(
                            'Nota Fiscal de Serviço',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),




          ],
        ),
      ),
    );
  }
}
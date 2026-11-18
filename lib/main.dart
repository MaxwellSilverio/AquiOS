
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app_routes.dart';
import 'service_locator.dart';
import 'View/cadastrar_view.dart';
import 'View/exibir_view.dart';
import 'View/iniciar_view.dart';
import 'View/sobre_view.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  configurarDependencias();

  runApp(const MeuApp());
}





class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquiOS',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),



      initialRoute: AppRoutes.inicio,
      routes: {
        AppRoutes.inicio: (context) => const InicioView(),
        AppRoutes.cadastrar: (context) => const CadastrarView(),
        AppRoutes.exibir: (context) => const ExibirView(),
        AppRoutes.sobre: (context) => const SobreView(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const InicioView(),
        );
      },
    );
  }
}
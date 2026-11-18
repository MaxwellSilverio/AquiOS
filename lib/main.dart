
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/firebase_options.dart';
import 'config/app_routes.dart';
import 'config/service_locator.dart';
import 'views/cadastrar_view.dart';
import 'views/exibir_view.dart';
import 'views/iniciar_view.dart';
import 'views/sobre_view.dart';


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
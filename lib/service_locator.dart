import 'package:get_it/get_it.dart';

import 'cadastrar_controller.dart';

final GetIt getIt = GetIt.instance;

void configurarDependencias() {
  getIt.registerSingleton<CadastrarController>(CadastrarController());
}
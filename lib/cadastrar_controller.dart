import 'package:flutter/material.dart';

class CadastrarController extends ChangeNotifier{

  String _nome = '';
  String _email = '';
  bool _receberNotificacoes = false;
  String _senha = '';
  String _telefone = '';

  String get nome => _nome;
  String get email => _email;
  String get senha => _senha;
  String get telefone => _telefone;
  bool get receberNotificacoes => _receberNotificacoes;



  String get notificacoesFormatadas {
    return _receberNotificacoes ? 'Sim' : 'Não';
  }


  bool get dadosValidos {
    return _nome.trim().isNotEmpty &&
        _email.trim().isNotEmpty &&
        _email.contains('@');
  }


  void alterarNome(String value) {
    _nome = value;
    notifyListeners();
  }

  void alterarEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void alterarSenha(String value) {
    _senha = value;
    notifyListeners();
  }

  void alterarTelefone(String value) {
    _telefone = value;
    notifyListeners();
  }


  void alterarReceberNotificacoes(bool value) {
    _receberNotificacoes = value;
    notifyListeners();
  }



  void limpar() {
    _nome = '';
    _email = '';
    _receberNotificacoes = false;
    _senha = '';
    _telefone = '';

    notifyListeners();
  }
}
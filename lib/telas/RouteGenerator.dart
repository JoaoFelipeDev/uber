import 'package:flutter/material.dart';
import 'package:uber/telas/Corrida.dart';
import 'package:uber/telas/PainelMorotista.dart';
import 'package:uber/telas/PainelPassageiro.dart';
import 'Cadastro.dart';

import 'Login.dart';

class RouteGenerator {
  static Route<dynamic> gerarRotas(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Login());

      case "/cadastro":
        return MaterialPageRoute(builder: (_) => Cadastro());

      case "/painel-motorista":
        return MaterialPageRoute(builder: (_) => PainelMotorista());

      case "/painel-passageiro":
        return MaterialPageRoute(builder: (_) => PainelPassageiro());

      case "/corrida":
        return MaterialPageRoute(builder: (_) => Corrida(
          args
        ));

      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}

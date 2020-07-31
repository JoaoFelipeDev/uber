import 'package:flutter/material.dart';
import 'Cadastro.dart';
import 'Home.dart';
import 'Login.dart';

class RouteGenerator {
  static Route <dynamic> gerarRotas (RouteSettings settings)  {
    


    switch (settings.name  ){
      case "/":
      return MaterialPageRoute(
        builder: (_) => Login()
         );

         case "/cadastro" :
         return MaterialPageRoute(
        builder: (_) => Cadastro()
         );

         case "/home" :
         return MaterialPageRoute(
        builder: (_) => Home()
         );






     default:
        _erroRota();    
    }

    
  }
  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
        builder: (_){
          return Scaffold(
            appBar: AppBar(title: Text("Tela não encontrada!"),),
            body: Center(
              child: Text("Tela não encontrada!"),
            ),
          );
        }
    );

  }
}
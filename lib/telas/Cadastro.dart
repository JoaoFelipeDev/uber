import 'package:flutter/material.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  bool _tipoUsuarioPassageiro = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        title: Text("Cadastro"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: TextField(
                  controller: _controllerNome,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      hintText: "Nome",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: TextField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      hintText: "E-mail",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
              ),
              TextField(
                controller: _controllerSenha,
                obscureText: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    hintText: "Senha",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Text("Passageiro"),
                    Switch(
                        value: _tipoUsuarioPassageiro,
                        onChanged: (bool valor) {
                          setState(() {
                            _tipoUsuarioPassageiro = valor;
                          });
                        }),
                    Text("Motorista"),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: RaisedButton(
                    child: Text(
                      "Cadastar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.cyan,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: () {}),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      "Erro",
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

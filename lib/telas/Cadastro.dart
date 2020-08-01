import 'package:flutter/material.dart';
import 'package:uber/model/Usuarios.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  bool _tipoUsuario = false;
  String _mensagemErro = "";

  _validarCampos() {
   
    //Recuperando Dados dos campos
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    

    if (nome.isNotEmpty) {
      print("Chegou nome");
      _mensagemErro = "";
      if (email.isNotEmpty && email.contains("@")) {
        
        _mensagemErro = "";
        if (senha.isNotEmpty && senha.length >= 6) {
          print("Chegou senha");
          _mensagemErro = "";
          Usuario usuario = Usuario();
          

          usuario.nome = nome;
          usuario.email = email;
          usuario.senha = senha;
          usuario.tipoUsuario = usuario.verificaTipoUsuario(_tipoUsuario);

         
          _cadastrarUsuario(usuario);
        } else {
          _mensagemErro = "Preencha a senha! digite mais de 6 caracteres";
        }
      } else {
        setState(() {
          _mensagemErro = "Preencha o email valido";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Preencha o nome";
      });
    }
  }

  _cadastrarUsuario(Usuario usuario) {
    print("chegou no metodo cadastro");
    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      db
          .collection("usuarios")
          .document(firebaseUser.user.uid)
          .setData(usuario.toMap());

      // redireciona para o painel, de acordo com o tipoUsuario
      switch (usuario.tipoUsuario) {
        case "motorista":
          Navigator.pushNamedAndRemoveUntil(
              context, "/painel-motorista", (_) => false);
          break;
        case "passageiro":
          Navigator.pushNamedAndRemoveUntil(
              context, "/painel-passageiro", (_) => false);
          break;
      }
    }).catchError((error) {
      _mensagemErro = "Erro ao cadastrar usuario, verifique os campos e tente novamente";
    });
  }

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
                        value: _tipoUsuario,
                        onChanged: (bool valor) {
                          setState(() {
                            _tipoUsuario = valor;
                          });
                        }),
                    Text("Motorista"),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: RaisedButton(
                    color: Colors.cyan,
                    child: Text(
                      "Cadastar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: () {
                      _validarCampos();
                      
                    }),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    _mensagemErro,
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

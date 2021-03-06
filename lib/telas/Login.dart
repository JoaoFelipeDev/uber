import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uber/model/Usuarios.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerUsuario =
      TextEditingController(text: "joao_passageiro@gmail.com");
  TextEditingController _controllerSenha =
      TextEditingController(text: "123456789");
  String _mensagemErro = "";
  bool _carregando = false;

  _validarCampos() {
    //Recuperando Dados dos campos
    String nome = _controllerUsuario.text;

    String senha = _controllerSenha.text;

    if (nome.isNotEmpty) {
      print("Chegou nome");
      _mensagemErro = "";

      _mensagemErro = "";
      if (senha.isNotEmpty && senha.length >= 6) {
        Usuario usuario = Usuario();
        usuario.email = nome;
        usuario.senha = senha;

        _logarUsuario(usuario);
      } else {
        _mensagemErro = "Preencha a senha! digite mais de 6 caracteres";
      }
    } else {
      setState(() {
        _mensagemErro = "O E-mail";
      });
    }
  }

  _logarUsuario(Usuario usuario) {
    setState(() {
      _carregando = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      _redirecionaPainelPorTipoUsuario(firebaseUser.user.uid);
    }).catchError((error) {
      setState(() {
        _carregando = false;
      });

      setState(() {
        _mensagemErro = "Erro ao autenticar usuario, verifique e-mail e senha";
      });
    });
  }

  _redirecionaPainelPorTipoUsuario(String idUsuario) async {
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").document(idUsuario).get();

    Map<String, dynamic> dados = snapshot.data;
    String tipoUsuario = dados["tipoUsuario"];

    setState(() {
      _carregando = false;
    });

    switch (tipoUsuario) {
      case "motorista":
        Navigator.pushReplacementNamed(context, "/painel-motorista");
        break;
      case "passageiro":
        Navigator.pushReplacementNamed(context, "/painel-passageiro");
    }
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseUser usuarioLogado = await auth.currentUser();

    if (usuarioLogado != null) {
      String idUsuario = usuarioLogado.uid;
      _redirecionaPainelPorTipoUsuario(idUsuario);
    }
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/fundo.png"), fit: BoxFit.cover)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Image.asset(
                    "imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: TextField(
                    controller: _controllerUsuario,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
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
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Entrar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.cyan,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      onPressed: () {
                        _validarCampos();
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Center(
                    child: GestureDetector(
                      child: Text("Não tem conta? cadastre-se!",
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pushNamed(context, "/cadastro");
                      },
                    ),
                  ),
                ),
                _carregando
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      )
                    : Container(),
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
      ),
    );
  }
}

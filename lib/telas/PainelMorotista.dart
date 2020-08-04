import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PainelMotorista extends StatefulWidget {
  @override
  _PainelMotoristaState createState() => _PainelMotoristaState();
}

class _PainelMotoristaState extends State<PainelMotorista> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore db = Firestore.instance;
  String _nome;
  List<String> itensMenu = ["Deslogar"];
  _deslogarUsuario() async {
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  _escolhaMenuItem(String escolha) {
    switch (escolha) {
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  _resgatarNome() async {
    FirebaseUser user = await auth.currentUser();

    DocumentSnapshot snapshot =
        await db.collection("usuarios").document(user.uid).get();

    Map<String, dynamic> dados = snapshot.data;
    String nomeUsuario = dados["nome"];
    setState(() {
      _nome = nomeUsuario;
    });
  }

  @override
  void initState() {
    super.initState();
    _resgatarNome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Motorista - " + _nome),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context) {
                return itensMenu.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              })
        ],
      ),
      body: Container(),
    );
  }
}

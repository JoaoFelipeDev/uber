import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber/model/Usuarios.dart';

class PainelPassageiro extends StatefulWidget {
  @override
  _PainelPassageiroState createState() => _PainelPassageiroState();
}

class _PainelPassageiroState extends State<PainelPassageiro> {
  String _nome = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore db = Firestore.instance;
  List<String> itensMenu = ["Deslogar"];
  Completer<GoogleMapController> _controller = Completer();
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

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
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
        title: Text("Painel Passageiro - " + _nome),
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
      body: Container(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition:
              CameraPosition(target: LatLng(-22.566671, -44.944692), zoom: 16),
          onMapCreated: _onMapCreated,
        ),
      ),
    );
  }
}

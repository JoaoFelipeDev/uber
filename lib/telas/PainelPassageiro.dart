import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class PainelPassageiro extends StatefulWidget {
  @override
  _PainelPassageiroState createState() => _PainelPassageiroState();
}

class _PainelPassageiroState extends State<PainelPassageiro> {
  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(-22.566671, -44.944692), zoom: 16);
  Set<Marker> _marcadores = {};
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

  _recuperarUltimaLocalizacaoConhecida() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      if (position != null) {
        _exibirMarcadorPassageiro(position);
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);
        _movimentarCamera(_cameraPosition);
      }
    });
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _adicionarListenerLocalizacao() {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      _exibirMarcadorPassageiro(position);
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);
      _movimentarCamera(_cameraPosition);
    });
  }

  _exibirMarcadorPassageiro(Position position) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            "imagens/passageiro.png")
        .then((BitmapDescriptor icon) {
      Marker marcadorPassageiro = Marker(
          markerId: MarkerId("marcador passageiro"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: "Meu local"),
          icon: icon);
      setState(() {
        _marcadores.add(marcadorPassageiro);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _resgatarNome();
    _recuperarUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();
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
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _cameraPosition,
              onMapCreated: _onMapCreated,
              //myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _marcadores,
            ),
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white),
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                          icon: Container(
                            margin: EdgeInsets.only(left: 15),
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.green,
                            ),
                          ),
                          hintText: "Meu Local",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15, top: 0)),
                    ),
                  ),
                )),
            Positioned(
                top: 55,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white),
                    child: TextField(
                      decoration: InputDecoration(
                          icon: Container(
                            margin: EdgeInsets.only(left: 15),
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.local_taxi,
                              color: Colors.black87,
                            ),
                          ),
                          hintText: "Digite o destino",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15, top: 0)),
                    ),
                  ),
                )),
            Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: RaisedButton(
                      child: Text(
                        "Chamar Uber",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.cyan,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      onPressed: () {}),
                ))
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber/model/Destino.dart';
import 'package:uber/model/Requisicao.dart';
import 'package:uber/model/Usuarios.dart';
import 'package:uber/util/StatusRequisicao.dart';
import 'package:uber/util/UsuarioFirebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PainelPassageiro extends StatefulWidget {
  @override
  _PainelPassageiroState createState() => _PainelPassageiroState();
}

class _PainelPassageiroState extends State<PainelPassageiro> {
  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(-22.566671, -44.944692), zoom: 16);
  Set<Marker> _marcadores = {};
  String _idRequisicao;
  String _nome = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore db = Firestore.instance;
  List<String> itensMenu = ["Deslogar"];
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _controllerDestino = TextEditingController();
  //Controles para exibição na tela
  bool _exibirCaixaEnderecoDestino = true;
  String _textoBotao = "Chamar Uber";
  Color _corBotao = Color(0xff1ebbd8);
  Function _funcaoBotao;
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

  _chamarUber() async {
    String enderecoDestino = _controllerDestino.text;

    if (enderecoDestino.isNotEmpty) {
      List<Placemark> listaEnderecos =
          await Geolocator().placemarkFromAddress(enderecoDestino);
      if (listaEnderecos != null && listaEnderecos.length > 0) {
        Placemark endereco = listaEnderecos[0];
        Destino destino = Destino();
        destino.cidade = endereco.subAdministrativeArea;
        destino.cep = endereco.postalCode;
        destino.bairro = endereco.subLocality;
        destino.rua = endereco.thoroughfare;
        destino.casaNumero = endereco.subThoroughfare;
        destino.latitude = endereco.position.latitude;
        destino.longitude = endereco.position.longitude;

        String enderecoConfirmacao;
        enderecoConfirmacao = "\n Cidade: " + destino.cidade;
        enderecoConfirmacao += "\n Rua: " + destino.rua;
        enderecoConfirmacao += "\n Bairro: " + destino.bairro;
        enderecoConfirmacao += "\n Cep: " + destino.cep;

        showDialog(
            context: context,
            builder: (contex) {
              return AlertDialog(
                title: Text("Confirmação de endereço"),
                content: Text(enderecoConfirmacao),
                actions: <Widget>[
                  FlatButton(
                    child:
                        Text("Cancelar", style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FlatButton(
                    child: Text("Confrimar",
                        style: TextStyle(color: Colors.green)),
                    onPressed: () {
                      _salvarRequisicao(destino);
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
    }
  }

  _salvarRequisicao(Destino destino) async {
    Usuario passageiro = await UsuarioFirebase.getDadosUsuarioLogado();

    Requisicao requisicao = Requisicao();
    requisicao.destino = destino;
    requisicao.passageiro = passageiro;
    requisicao.status = StatusRequisicao.AGUARDANDO;

    Firestore db = Firestore.instance;
    //Salvando Requisição

    db
        .collection("requisicoes")
        .document(requisicao.id)
        .setData(requisicao.toMap());

    //Salvar requisição ativa
    Map<String, dynamic> dadosRequisicaoAtiva = {};
    dadosRequisicaoAtiva["id_requisicao"] = requisicao.id;
    dadosRequisicaoAtiva["id_usuario"] = passageiro.idUsuario;
    dadosRequisicaoAtiva["status"] = StatusRequisicao.AGUARDANDO;

    db
        .collection("requisicao_ativa")
        .document(passageiro.idUsuario)
        .setData(dadosRequisicaoAtiva);
  }

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao) {
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  _cancelarUber() async {
    FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    Firestore db = Firestore.instance;
    db
        .collection("requisicoes")
        .document(_idRequisicao)
        .updateData({"status": StatusRequisicao.CANCELADA}).then((_) {
      db.collection("requisicao_ativa").document(firebaseUser.uid).delete();
    });
  }

  _statusUberNaoChamado() {
    _exibirCaixaEnderecoDestino = true;

    _alterarBotaoPrincipal("Chamar uber", Color(0xff1ebbd8), () {
      _chamarUber();
    });
  }

  _statusAguardando() {
    _exibirCaixaEnderecoDestino = false;

    _alterarBotaoPrincipal("Cancelar", Colors.red, () {
      _cancelarUber();
    });
  }

  _adicionarListenerRequisicaoAtiva() async {
    FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();

    Firestore db = Firestore.instance;

    await db
        .collection("requisicao_ativa")
        .document(firebaseUser.uid)
        .snapshots()
        .listen((snapshot) {
      // print("dados recuperado: " + snapshot.data.toString());

      if (snapshot.data != null) {
        Map<String, dynamic> dados = snapshot.data;
        String status = dados["status"];
        _idRequisicao = dados["id_requisicao"];

        switch (status) {
          case StatusRequisicao.AGUARDANDO:
            _statusAguardando();
            break;
          case StatusRequisicao.A_CAMINHO:
            break;
          case StatusRequisicao.VIAGEM:
            break;
          case StatusRequisicao.FINALIZADA:
            break;
        }
      } else {
        _statusUberNaoChamado();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _resgatarNome();
    _recuperarUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();
    // adicionar listener para requisicao ativa
    _adicionarListenerRequisicaoAtiva();
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
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              markers: _marcadores,
            ),
            Visibility(
                visible: _exibirCaixaEnderecoDestino,
                child: Stack(
                  children: <Widget>[
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
                                  contentPadding:
                                      EdgeInsets.only(left: 15, top: 0)),
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
                              controller: _controllerDestino,
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
                                  contentPadding:
                                      EdgeInsets.only(left: 15, top: 0)),
                            ),
                          ),
                        )),
                  ],
                )),
            Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      child: Text(
                        _textoBotao,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: _corBotao,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      onPressed: _funcaoBotao,
                    )))
          ],
        ),
      ),
    );
  }
}

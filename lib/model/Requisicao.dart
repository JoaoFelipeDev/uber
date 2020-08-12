import 'package:uber/model/Destino.dart';
import 'package:uber/model/Usuarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Requisicao {
  String _id;
  String _status;
  Usuario _passageiro;
  Usuario _motorista;
  Destino _destino;

  Requisicao() {
    Firestore db = Firestore.instance;

    DocumentReference ref = db.collection("requisicoes").document();
    this.id = ref.documentID;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> dadosPassageiro = {
      "nome": this.passageiro.nome,
      "email": this.passageiro.email,
      "idUsuario": this.passageiro.idUsuario
    };
    Map<String, dynamic> dadosDestino = {
      "rua": this.destino.rua,
      "numero": this.destino.casaNumero,
      "bairro": this.destino.bairro,
      "cep": this.destino.cep,
      "latitude": this.destino.latitude,
      "longitude": this.destino.longitude,
    };
    Map<String, dynamic> dadosRequisicao = {
      "status": this.status,
      "id": this.id,
      "passageiro": dadosPassageiro,
      "motorista": null,
      "destino": dadosDestino
    };
    return dadosRequisicao;
  }

  Destino get destino => _destino;

  set destino(Destino value) {
    _destino = value;
  }

  Usuario get motorista => _motorista;

  set motorista(Usuario value) {
    _motorista = value;
  }

  Usuario get passageiro => _passageiro;

  set passageiro(Usuario value) {
    _passageiro = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}

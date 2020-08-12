class Usuario {
  String _idUsuario;
  String _nome;
  String _email;
  String _senha;
  String _tipoUsuario;

  double _latitude;
  double _longetude;
 

  Usuario();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "nome": this.nome,
      "email": this.email,
      "tipoUsuario": this.tipoUsuario,
      "latitude": this.latitude,
      "longetude": this.longetude
    };
    return map;
  }

  String verificaTipoUsuario(bool tipoUsuario) {
    return tipoUsuario ? "motorista" : "passageiro";
  }
  double get latitude => _latitude;

 set latitude(double value) => _latitude = value;

 double get longetude => _longetude;

 set longetude(double value) => _longetude = value;

  String get idUsuario => _idUsuario;

  set idUsuario(String value) => _idUsuario = value;

  String get nome => _nome;

  set nome(String value) => _nome = value;

  String get email => _email;

  set email(String value) => _email = value;

  String get senha => _senha;

  set senha(String value) => _senha = value;

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String value) => _tipoUsuario = value;
}

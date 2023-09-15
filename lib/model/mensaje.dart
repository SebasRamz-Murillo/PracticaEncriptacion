class Mensaje {
  String? mensaje; //Mensaje a cifrar
  String? cifrado; //Mensaje cifrado
  String? descifrado; //Mensaje descifrado
  String? llave; //Llave para cifrar
  String? llaveDescifrado; //Llave para descifrar
  String idUsuario; //Id del usuario que envia el mensaje
  String idUsuarioDestino; //Id del usuario que recibe el mensaje
  String idMensaje; //Id del mensaje

  Mensaje({
    this.mensaje,
    this.cifrado,
    this.descifrado,
    this.llave,
    this.llaveDescifrado,
    required this.idUsuario,
    required this.idUsuarioDestino,
    required this.idMensaje,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      mensaje: json['mensaje'],
      cifrado: json['cifrado'],
      descifrado: json['descifrado'],
      llave: json['llave'],
      llaveDescifrado: json['llaveDescifrado'],
      idUsuario: json['idUsuario'],
      idUsuarioDestino: json['idUsuarioDestino'],
      idMensaje: json['idMensaje'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensaje': mensaje,
      'cifrado': cifrado,
      'descifrado': descifrado,
      'llave': llave,
      'llaveDescifrado': llaveDescifrado,
      'idUsuario': idUsuario,
      'idUsuarioDestino': idUsuarioDestino,
      'idMensaje': idMensaje,
    };
  }
}

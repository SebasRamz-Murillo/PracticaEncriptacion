class Usuario {
  int id;

  String nombre;

  String clave;

  Usuario({
    required this.id,
    required this.nombre,
    required this.clave,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      clave: json['clave'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'clave': clave,
    };
  }
}

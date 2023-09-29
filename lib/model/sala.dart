class Sala {
  String nombre;
  String password;
  String? contraAutorizada;
  Sala(this.nombre, this.password);

  factory Sala.fromJson(Map<String, dynamic> json) {
    return Sala(json['nombre'], json['password']);
  }
  Map<String, dynamic> toJson() =>
      {'"nombre"': '"$nombre"', '"password"': '"$password"'};
}

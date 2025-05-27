class Encargado {
  final int id;
  final String nombres;
  final String apellido1;
  final String apellido2;
  final String correo;

  Encargado({
    required this.id,
    required this.nombres,
    required this.apellido1,
    required this.apellido2,
    required this.correo,
  });

  factory Encargado.fromJson(Map<String, dynamic> json) {
    return Encargado(
      id: json['id'],
      nombres: json['nombres'],
      apellido1: json['apellido1'],
      apellido2: json['apellido2'],
      correo: json['correo'],
    );
  }
}

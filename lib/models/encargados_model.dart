class Encargado {
  final String id;
  final String nombres;
  final String apellido1;
  final String? apellido2;
  final String correo;

  Encargado({
    required this.id,
    required this.nombres,
    required this.apellido1,
    this.apellido2,
    required this.correo,
  });

  factory Encargado.fromJson(Map<String, dynamic> json) {
    if (json['correo'] == null) {
      throw Exception("Campo 'correo' no puede ser null");
    }

    return Encargado(
      id: json['id'] ?? json['id_encargado'] ?? '',
      nombres: json['nombres'] ?? '',
      apellido1: json['apellido1'] ?? '',
      apellido2: json['apellido2'],
      correo: json['correo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_encargado': id,
      'nombres': nombres,
      'apellido1': apellido1,
      'apellido2': apellido2,
      'correo': correo,
    };
  }
}

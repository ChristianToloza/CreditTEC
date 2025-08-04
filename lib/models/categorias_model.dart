class Categoria {
  final String id;
  final String nombre;

  Categoria({required this.id, required this.nombre});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('M')) {
      final m = json['M'] as Map<String, dynamic>;
      return Categoria(
        id: m['id_categoria']?['S'] ?? '',
        nombre: m['nombre']?['S'] ?? '',
      );
    }
    return Categoria(
      id: json['id'] ?? json['id_categoria'] ?? '',
      nombre: json['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }
}

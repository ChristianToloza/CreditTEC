import 'categorias_model.dart';
import 'encargados_model.dart';

class Actividad {
  final int id;
  final String actividad;
  final double creditos;
  final String ubicacion;
  final Categoria categoria;
  final Encargado encargado;

  Actividad({
    required this.id,
    required this.actividad,
    required this.creditos,
    required this.ubicacion,
    required this.categoria,
    required this.encargado,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'],
      actividad: json['actividad'],
      creditos: (json['creditos'] as num).toDouble(),
      ubicacion: json['ubicacion'],
      categoria: Categoria.fromJson(json['categoria']),
      encargado: Encargado.fromJson(json['encargado']),
    );
  }
}

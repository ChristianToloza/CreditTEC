import 'categorias_model.dart';
import 'encargados_model.dart';

class Actividad {
  final String id;
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
    final actividadData = json['data'] ?? json;

    if (actividadData == null) {
      throw Exception("No se encontraron datos de actividad en la respuesta");
    }

    return Actividad(
      id: actividadData['id_act'] ?? '',
      actividad: actividadData['actividad'] ?? '',
      creditos: (actividadData['creditos'] as num?)?.toDouble() ?? 0.0,
      ubicacion: actividadData['ubicacion'] ?? '',
      categoria: Categoria.fromJson(actividadData['categoria'] ?? {}),
      encargado: Encargado.fromJson(actividadData['encargado'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_act': id,
      'actividad': actividad,
      'creditos': creditos,
      'ubicacion': ubicacion,
      'categoria': categoria.toJson(),
      'encargado': encargado.toJson(),
    };
  }
}

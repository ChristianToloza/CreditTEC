import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../models/actividades_model.dart';
import '../models/categorias_model.dart';
import '../models/encargados_model.dart';

class ActividadService {
  static const String _baseUrl =
      'https://jepmen8f8a.execute-api.us-east-2.amazonaws.com';
  static const Duration _timeout = Duration(seconds: 30);

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final http.Client _client = http.Client();

  Future<Either<String, List<Actividad>>> obtenerActividades() async {
    try {
      print('Obteniendo actividades desde: $_baseUrl/activities');

      final response = await _client
          .get(Uri.parse('$_baseUrl/activities'), headers: _defaultHeaders)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final actividades = data.map((e) => Actividad.fromJson(e)).toList();
        return right(actividades);
      } else {
        return left('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return left('Error al obtener actividades: ${e.toString()}');
    }
  }

  Future<Either<String, List<Categoria>>> obtenerCategorias() async {
    try {
      print('Obteniendo categorías desde: $_baseUrl/categorias');

      final response = await _client
          .get(Uri.parse('$_baseUrl/categorias'), headers: _defaultHeaders)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final categorias = data.map((e) => Categoria.fromJson(e)).toList();
        return right(categorias);
      } else {
        return left('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return left('Error al obtener categorías: ${e.toString()}');
    }
  }

  Future<Either<String, List<Encargado>>> obtenerEncargados() async {
    try {
      final url = '$_baseUrl/encargados';
      print('Obteniendo encargados desde: $url');

      final response = await _client
          .get(Uri.parse(url), headers: _defaultHeaders)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final encargados = data.map((e) => Encargado.fromJson(e)).toList();
        return right(encargados);
      } else {
        return left('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return left('Error al obtener encargados: ${e.toString()}');
    }
  }

  Future<Either<String, Actividad>> insertarActividad({
    required String actividad,
    required double creditos,
    required String ubicacion,
    required String idCategoria,
    required String categoriaNombre,
    required String idEncargado,
    required String encargadoNombre,
    required String encargadoApellido1,
    String? encargadoApellido2,
    required String correoEncargado,
  }) async {
    try {
      print('Insertando actividad: $actividad');

      final body = {
        "actividad": actividad,
        "creditos": creditos,
        "ubicacion": ubicacion,
        "id_Categoria": idCategoria,
        "nombre_Categoria": categoriaNombre,
        "id_Encargado": idEncargado,
        "nombres_Encargado": encargadoNombre,
        "apellido1_Encargado": encargadoApellido1,
        "apellido2_Encargado": encargadoApellido2,
        "correo_Encargado": correoEncargado,
      };

      print('JSON a enviar: ${jsonEncode(body)}');

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/activity'),
            headers: _defaultHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return right(Actividad.fromJson(data));
      } else {
        return left('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return left('Error en insertarActividad: ${e.toString()}');
    }
  }

  Future<Either<String, Actividad>> insertarActividadConObjeto(
    Actividad actividad,
  ) async {
    return await insertarActividad(
      actividad: actividad.actividad,
      creditos: actividad.creditos,
      ubicacion: actividad.ubicacion,
      idCategoria: actividad.categoria.id,
      categoriaNombre: actividad.categoria.nombre,
      idEncargado: actividad.encargado.id,
      encargadoNombre: actividad.encargado.nombres,
      encargadoApellido1: actividad.encargado.apellido1,
      encargadoApellido2: actividad.encargado.apellido2,
      correoEncargado: actividad.encargado.correo,
    );
  }

  Future<Either<String, bool>> actualizarActividad(
    String id,
    Actividad actividad,
  ) async {
    try {
      final url = '$_baseUrl/activity/$id';
      final body = _actividadToJson(actividad);

      final response = await _client
          .put(Uri.parse(url), headers: _defaultHeaders, body: jsonEncode(body))
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return right(true);
      } else {
        return left(
          'Error al actualizar (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      return left('Error de red: ${e.toString()}');
    }
  }

  Future<Either<String, bool>> eliminarActividad(String id) async {
    try {
      final url = '$_baseUrl/activity/$id';
      final response = await _client
          .delete(Uri.parse(url), headers: _defaultHeaders)
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return right(true);
      } else if (response.statusCode == 404) {
        return left('La actividad no existe');
      } else {
        return left(
          'Error al eliminar (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      return left('Error de red: ${e.toString()}');
    }
  }

  Future<bool> verificarConectividad() async {
    try {
      print('Verificando conectividad...');

      final response = await _client
          .get(Uri.parse('$_baseUrl/health'), headers: _defaultHeaders)
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Sin conectividad: $e');
      return false;
    }
  }

  Future<bool> diagnosticarConexion() async {
    print('INICIANDO DIAGNÓSTICO DE CONEXIÓN CON AWS...');

    const baseUrl = 'https://jepmen8f8a.execute-api.us-east-2.amazonaws.com';
    const endpoint = '/activities';

    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('Probando conexión a: $url');

      final response = await _client
          .get(url, headers: _defaultHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        print('Conexión exitosa con AWS API Gateway');
        return true;
      } else {
        print('Respuesta inesperada: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al conectar con AWS: ${e.toString()}');
    }

    print('No se pudo establecer conexión con AWS');
    return false;
  }

  List<Actividad> _handleActividadesResponse(http.Response response) {
    print('Status Code: ${response.statusCode}');
    print(
      'Response: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}',
    );

    if (response.statusCode != 200) {
      throw HttpException(
        'Error del servidor (${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.isEmpty) {
      print('Respuesta vacía del servidor');
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(response.body);
      print('JSON parseado: ${data.length} actividades encontradas');

      final List<Actividad> actividades = [];
      for (int i = 0; i < data.length; i++) {
        try {
          final actividad = Actividad.fromJson(data[i]);
          actividades.add(actividad);
        } catch (e) {
          print('Error parseando actividad ${i + 1}: $e');
        }
      }

      return actividades;
    } catch (e) {
      throw FormatException('Error al procesar respuesta JSON: $e');
    }
  }

  List<Categoria> _handleCategoriasResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Error al obtener categorías: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Categoria.fromJson(json)).toList();
  }

  List<Encargado> _handleEncargadosResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Error al obtener encargados: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Encargado.fromJson(json)).toList();
  }

  Actividad? _handleInsertResponse(http.Response response) {
    print('Insert Status Code: ${response.statusCode}');
    print('Insert Response: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Actividad insertada exitosamente');

      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          return Actividad.fromJson(data);
        } catch (e) {
          print('No se pudo parsear la respuesta de inserción: $e');
          return null;
        }
      }
      return null;
    } else {
      throw HttpException(
        'Error al insertar actividad (${response.statusCode}): ${response.body}',
      );
    }
  }

  void _handleUpdateResponse(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw HttpException(
        'Error al actualizar actividad (${response.statusCode}): ${response.body}',
      );
    }
  }

  void _handleDeleteResponse(http.Response response) {
    print(
      'Analizando respuesta de eliminación - Status Code: ${response.statusCode}',
    );

    switch (response.statusCode) {
      case 200:
      case 204:
        print('Eliminación exitosa');
        return;
      case 404:
        throw HttpException('La actividad no existe o ya fue eliminada');
      case 405:
        throw HttpException(
          'El método de eliminación no está permitido. Contacta al administrador del sistema.',
        );
      case 401:
        throw HttpException(
          'No tienes autorización para eliminar esta actividad',
        );
      case 403:
        throw HttpException('No tienes permisos para eliminar esta actividad');
      default:
        throw HttpException(
          'Error al eliminar actividad (${response.statusCode}): ${response.body}',
        );
    }
  }

  Map<String, dynamic> _actividadToJson(Actividad actividad) {
    return {
      'actividad': actividad.actividad,
      'creditos': actividad.creditos,
      'ubicacion': actividad.ubicacion,
      'id_Categoria': actividad.categoria.id,
      'nombre_Categoria': actividad.categoria.nombre,
      'id_Encargado': actividad.encargado.id,
      'nombres_Encargado': actividad.encargado.nombres,
      'apellido1_Encargado': actividad.encargado.apellido1,
      'apellido2_Encargado': actividad.encargado.apellido2 ?? '',
      'correo_Encargado': actividad.encargado.correo,
    };
  }

  void dispose() {
    _client.close();
  }
}

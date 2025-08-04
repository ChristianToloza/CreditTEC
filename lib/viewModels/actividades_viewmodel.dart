import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import '../models/actividades_model.dart';
import '../models/categorias_model.dart';
import '../models/encargados_model.dart';
import '../services/actividad_service.dart';
import 'package:dartz/dartz.dart';

class ActividadViewModel extends ChangeNotifier {
  final ActividadService _service = ActividadService();

  List<Actividad> actividades = [];
  List<Categoria> categorias = [];
  List<Encargado> encargados = [];
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<void> fetchActividades() async {
    try {
      _setLoading(true);

      print('Iniciando carga de actividades...');
      final result = await _service.obtenerActividades();

      result.fold(
        (error) {
          _handleGenericError(
            error,
          ); // o algún método que maneje errores con mensaje String
        },
        (data) {
          actividades = data;
          print('${actividades.length} actividades cargadas exitosamente');
          _clearError();
        },
      );
    } catch (e) {
      _handleGenericError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarDatosFormulario() async {
    _setLoading(true);
    try {
      // Obtener resultados por separado con Either
      final categoriasResult = await _service.obtenerCategorias();
      final encargadosResult = await _service.obtenerEncargados();

      bool hasError = false;

      categoriasResult.fold(
        (error) {
          errorMessage = 'Error al obtener categorías: $error';
          hasError = true;
        },
        (data) {
          categorias = data;
        },
      );

      encargadosResult.fold(
        (error) {
          errorMessage = 'Error al obtener encargados: $error';
          hasError = true;
        },
        (data) {
          encargados = data;
        },
      );

      if (!hasError) {
        print(
          'Datos cargados: ${categorias.length} categorías, ${encargados.length} encargados',
        );
        _clearError();
      }
    } catch (e) {
      _handleGenericError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> insertarActividad({
    required String actividad,
    required double creditos,
    required String ubicacion,
    required String idCategoria,
    required String categoriaNombre,
    required String idEncargado,
    required String encargadoNombre,
    required String encargadoApellido1,
    required String encargadoApellido2,
    required String correoEncargado,
  }) async {
    _setLoading(true);
    _clearMessages();

    print('Insertando actividad: $actividad');

    final resultado = await _service.insertarActividad(
      actividad: actividad,
      creditos: creditos,
      ubicacion: ubicacion,
      idCategoria: idCategoria,
      categoriaNombre: categoriaNombre,
      idEncargado: idEncargado,
      encargadoNombre: encargadoNombre,
      encargadoApellido1: encargadoApellido1,
      encargadoApellido2: encargadoApellido2,
      correoEncargado: correoEncargado,
    );

    return resultado.fold(
      (error) {
        errorMessage = error;
        _setLoading(false);
        return false;
      },
      (actividadCreada) async {
        successMessage =
            'Actividad "${actividadCreada.actividad}" creada exitosamente';
        await fetchActividades();
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> insertarActividadConObjeto(Actividad actividad) async {
    _setLoading(true);
    _clearMessages();

    final resultado = await _service.insertarActividadConObjeto(actividad);

    return resultado.fold(
      (error) {
        errorMessage = error;
        _setLoading(false);
        return false;
      },
      (actividadCreada) async {
        successMessage =
            'Actividad "${actividadCreada.actividad}" creada exitosamente';
        await fetchActividades();
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> actualizarActividad(String id, Actividad actividad) async {
    _setLoading(true);
    _clearMessages();

    final resultado = await _service.actualizarActividad(id, actividad);

    return resultado.fold(
      (error) {
        errorMessage = error;
        _setLoading(false);
        return false;
      },
      (_) async {
        successMessage = 'Actividad actualizada exitosamente';
        await fetchActividades();
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> eliminarActividad(String id) async {
    _setLoading(true);
    _clearMessages();

    final resultado = await _service.eliminarActividad(id);

    return resultado.fold(
      (error) {
        errorMessage = error;
        _setLoading(false);
        return false;
      },
      (_) async {
        successMessage = 'Actividad eliminada exitosamente';
        await fetchActividades();
        _setLoading(false);
        return true;
      },
    );
  }

  Future<void> verificarConectividad() async {
    try {
      _setLoading(true);

      final conectado = await _service.verificarConectividad();

      if (conectado) {
        successMessage = 'Conectividad OK';
      } else {
        errorMessage = 'Sin conectividad al servidor';
      }
    } catch (e) {
      errorMessage = 'Error verificando conectividad: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> diagnosticarConexion() async {
    try {
      _setLoading(true);

      final ipFuncional = await _service.diagnosticarConexion();

      if (ipFuncional != null) {
        successMessage = '''
🎉 IP FUNCIONAL ENCONTRADA: $ipFuncional

Actualiza tu ActividadService para usar esta IP:
static const String _baseUrl = '$ipFuncional/api';
''';
      } else {
        errorMessage = '''
NINGUNA IP FUNCIONÓ

Soluciones:
1. Verifica que tu API esté ejecutándose
2. Obtén la IP correcta con:
   • Windows: ipconfig
   • Linux/Mac: ifconfig
3. Asegúrate de estar en la misma red WiFi
4. Revisa el firewall del servidor
''';
      }
    } catch (e) {
      errorMessage = 'Error en diagnóstico: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    errorMessage = null;
    successMessage = null;
  }

  void _handleTimeoutError(TimeoutException e) {
    errorMessage = '''
⏱Timeout de Conexión

El servidor tardó demasiado en responder.

Posibles causas:
• Servidor sobrecargado o no disponible
• Conexión de red lenta
• Firewall bloqueando la conexión

Soluciones:
1. Verifica que la API esté corriendo
2. Prueba el diagnóstico de conexión
3. Revisa tu conexión a internet
''';
    print('TimeoutException: $e');
  }

  void _handleConnectionError(SocketException e) {
    errorMessage = '''
🔌 Error de Conexión

No se puede conectar al servidor.

Verifica que:
• La API esté ejecutándose
• Estés en la misma red WiFi
• No haya firewall bloqueando el puerto
• La IP del servidor sea correcta

💡 Prueba el diagnóstico automático para encontrar la IP correcta.
''';
    print('SocketException: $e');
  }

  void _handleHttpError(HttpException e) {
    errorMessage = 'Error del servidor: ${e.message}';
    print('HttpException: $e');
  }

  void _handleFormatError(FormatException e) {
    errorMessage =
        'Error de formato en la respuesta del servidor: ${e.message}';
    print('FormatException: $e');
  }

  void _handleGenericError(dynamic e) {
    errorMessage = 'Error inesperado: $e';
    print('Error genérico: $e');
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void retry() {
    fetchActividades();
  }

  Categoria? obtenerCategoriaPorId(String id) {
    try {
      return categorias.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  Encargado? obtenerEncargadoPorId(String id) {
    try {
      return encargados.firstWhere((enc) => enc.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

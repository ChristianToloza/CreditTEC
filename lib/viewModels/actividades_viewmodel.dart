import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/actividades_model.dart';

class ActividadViewModel extends ChangeNotifier {
  List<Actividad> actividades = [];
  bool isLoading = false;
  String? errorMessage;

  // MÉTODO PRINCIPAL: Con mejor manejo de errores y diagnósticos
  Future<void> fetchActividades() async {
    try {
      print('🔄 Iniciando carga de actividades...');
      print('🔧 Verificando conectividad...');

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // PASO 1: Verificar si podemos hacer ping al servidor
      await _testConnectivity();

      final url = 'http://192.168.173.155:7211/api/actividades';
      print('📡 Haciendo petición a: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30), // Aumentamos timeout
            onTimeout: () {
              print('⏰ Timeout después de 30 segundos');
              throw TimeoutException(
                'La conexión tardó demasiado',
                const Duration(seconds: 30),
              );
            },
          );

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Headers: ${response.headers}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('⚠️ Respuesta vacía del servidor');
          actividades = [];
        } else {
          try {
            final List<dynamic> data = jsonDecode(response.body);
            print(
              '✅ JSON parseado exitosamente. ${data.length} elementos encontrados',
            );

            actividades = [];
            for (int i = 0; i < data.length; i++) {
              try {
                final actividad = Actividad.fromJson(data[i]);
                actividades.add(actividad);
                print('✅ Actividad ${i + 1} parseada: ${actividad.actividad}');
              } catch (e) {
                print('❌ Error parseando actividad ${i + 1}: $e');
                print('❌ JSON problemático: ${data[i]}');
              }
            }

            print('✅ Total de actividades cargadas: ${actividades.length}');
          } catch (e) {
            errorMessage = 'Error al procesar la respuesta del servidor: $e';
            print('💥 Error de parseo JSON: $e');
          }
        }
      } else {
        errorMessage =
            'Error del servidor (${response.statusCode}): ${response.body}';
        print('❌ Error HTTP: ${response.statusCode}');
        print('❌ Respuesta: ${response.body}');
      }
    } on TimeoutException catch (e) {
      errorMessage = '''
🕐 Error de Timeout: No se pudo conectar al servidor.

Posibles causas:
• El servidor no está ejecutándose en http://192.168.173.155:7211
• Tu dispositivo no está en la misma red WiFi
• El firewall está bloqueando la conexión
• La dirección IP ha cambiado

Soluciones:
1. Verifica que la API esté corriendo
2. Confirma la dirección IP del servidor
3. Asegúrate de estar en la misma red WiFi
4. Intenta usar la IP 10.0.2.2 si estás en emulador

Error técnico: $e''';
      print('⏰ TimeoutException: $e');
    } on SocketException catch (e) {
      errorMessage = '''
🌐 Error de Conexión: No se puede conectar al servidor.

Detalles del error: $e

Verifica que:
• La API esté ejecutándose en http://192.168.173.155:7211
• Tu dispositivo esté en la misma red WiFi
• No haya firewall bloqueando el puerto 7211

Si usas emulador Android, prueba con: http://10.0.2.2:7211''';
      print('🌐 SocketException: $e');
    } on HttpException catch (e) {
      errorMessage = 'Error HTTP: $e';
      print('📡 HttpException: $e');
    } on FormatException catch (e) {
      errorMessage = 'Error de formato en la respuesta del servidor: $e';
      print('📄 FormatException: $e');
    } catch (e) {
      errorMessage = 'Error inesperado: $e';
      print('💥 Exception general: $e');
    } finally {
      isLoading = false;
      notifyListeners();
      print(
        '🏁 Proceso finalizado. Loading: $isLoading, Error: $errorMessage, Actividades: ${actividades.length}',
      );
    }
  }

  // Método para verificar conectividad básica
  Future<void> _testConnectivity() async {
    try {
      print('🔍 Probando conectividad...');
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ Conexión a internet OK');
      }
    } on SocketException catch (_) {
      print('❌ Sin conexión a internet');
      throw SocketException('Sin conexión a internet');
    }
  }

  // Método alternativo para emulador
  Future<void> fetchActividadesEmulador() async {
    try {
      print('🔄 Iniciando carga para emulador...');

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Para emulador Android usa 10.0.2.2
      final url = 'http://10.0.2.2:7211/api/actividades';
      print('📡 Haciendo petición a: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        actividades = data.map((json) => Actividad.fromJson(json)).toList();
        print('✅ Total de actividades cargadas: ${actividades.length}');
      } else {
        errorMessage =
            'Error del servidor (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      print('💥 Exception: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // OPCIÓN 2: Si necesitas certificados SSL personalizados
  Future<void> fetchActividadesConHttpClient() async {
    HttpClient? httpClient;
    try {
      print('🔄 Iniciando carga de actividades con HttpClient...');

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Crear HttpClient personalizado
      httpClient =
          HttpClient()
            ..badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;

      final request = await httpClient.getUrl(
        Uri.parse('http://192.168.173.155:7211/api/actividades'),
      );

      // Agregar headers
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('📡 Response Body: $responseBody');

        if (responseBody.isEmpty) {
          print('⚠️ Respuesta vacía del servidor');
          actividades = [];
        } else {
          try {
            final List<dynamic> data = jsonDecode(responseBody);
            print(
              '✅ JSON parseado exitosamente. ${data.length} elementos encontrados',
            );

            actividades = [];
            for (int i = 0; i < data.length; i++) {
              try {
                final actividad = Actividad.fromJson(data[i]);
                actividades.add(actividad);
                print('✅ Actividad ${i + 1} parseada: ${actividad.actividad}');
              } catch (e) {
                print('❌ Error parseando actividad ${i + 1}: $e');
              }
            }

            print('✅ Total de actividades cargadas: ${actividades.length}');
          } catch (e) {
            errorMessage = 'Error al procesar la respuesta del servidor: $e';
            print('💥 Error de parseo JSON: $e');
          }
        }
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        errorMessage =
            'Error del servidor (${response.statusCode}): $errorBody';
        print('❌ Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      print('💥 Exception: $e');
    } finally {
      httpClient?.close();
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}

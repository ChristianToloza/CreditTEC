import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://192.168.8.6:7211/api/admin';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'email': email, 'password': password}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData.containsKey('token')) {
          return responseData as Map<String, dynamic>;
        } else {
          throw Exception('Respuesta del servidor no contiene token.');
        }
      } else {
        String errorMessage = 'Error de autenticación.';
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'] as String;
        } else if (responseData.containsKey('error')) {
          errorMessage = responseData['error'] as String;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('AuthService Error: $e');
      throw Exception('Error al conectar con el servidor: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String nombres,
    required String apellido1,
    String? apellido2,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/register');

    Map<String, String> body = {
      'nombres': nombres,
      'apellido1': apellido1,
      'email': email,
      'password': password,
    };

    if (apellido2 != null && apellido2.isNotEmpty) {
      body['apellido2'] = apellido2;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData as Map<String, dynamic>;
      } else {
        String errorMessage = 'Error en el registro.';
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'] as String;
        } else if (responseData.containsKey('error')) {
          errorMessage = responseData['error'] as String;
        } else if (responseData is Map && responseData.containsKey('errors')) {
          try {
            final errors = responseData['errors'] as Map<String, dynamic>;
            errorMessage = errors.values
                .map((e) => (e as List).join(' '))
                .join(' \n');
          } catch (_) {}
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('AuthService Register Error: $e');
      throw Exception(
        'Error al conectar con el servidor para registrar: ${e.toString()}',
      );
    }
  }
}

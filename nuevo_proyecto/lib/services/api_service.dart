//lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://api-stand.onrender.com/api';

  static Future<bool> registrarVisitante(Map<String, dynamic> visitante) async {
    final url = Uri.parse('$baseUrl/visitantes');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(visitante),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error al registrar visitante: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }
}

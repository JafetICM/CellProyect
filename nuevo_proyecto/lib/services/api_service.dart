//lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://api-stand.onrender.com/api';

    static Future<List<String>> obtenerProductos() async {
    final url = Uri.parse('$baseUrl/productos'); // Ajusta el endpoint según tu API

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        // Suponiendo que data es lista de objetos con campo "nombre"
        return data.map<String>((item) => item['nombre'].toString()).toList();
      } else {
        print('Error al obtener productos: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error conexión productos: $e');
      return [];
    }
  }

  /// Registra un visitante enviando sus datos al servidor.
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

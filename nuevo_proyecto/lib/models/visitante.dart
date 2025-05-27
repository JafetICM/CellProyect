//lib/models/visitante.dart
class Visitante {
  final String nombreCompleto;
  final String correo;
  final String telefono;
  final String? empresa;
  final String? cargo;
  final List<String> productosInteres;
  final String? notas;

  Visitante({
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    this.empresa,
    this.cargo,
    required this.productosInteres,
    this.notas,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'telefono': telefono,
      'empresa': empresa,
      'cargo': cargo,
      'productos_interes': productosInteres,
      'notas': notas,
    };
  }
}

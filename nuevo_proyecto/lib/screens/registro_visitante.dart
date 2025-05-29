import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../models/visitante.dart';
import '../services/api_service.dart';

enum CanalNotificacion { correo, telefono }

class RegistroVisitanteScreen extends StatefulWidget {
  const RegistroVisitanteScreen({Key? key}) : super(key: key);

  @override
  State<RegistroVisitanteScreen> createState() => _RegistroVisitanteScreenState();
}

class _RegistroVisitanteScreenState extends State<RegistroVisitanteScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final empresaController = TextEditingController();
  final cargoController = TextEditingController();
  final notasController = TextEditingController();

  List<String> productos = [];
  List<String> seleccionados = [];

  CanalNotificacion? _canalSeleccionado;

  bool _isLoading = false;
  bool _registrado = false;
  bool _cargandoProductos = true;
  late Visitante _visitanteRegistrado;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final productosApi = await ApiService.obtenerProductos();
    if (productosApi.isNotEmpty) {
      setState(() {
        productos = productosApi;
      });
    }
    setState(() {
      _cargandoProductos = false;
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    empresaController.dispose();
    cargoController.dispose();
    notasController.dispose();
    super.dispose();
  }

  String? validarCorreo(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Correo no válido';
    return null;
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_canalSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un canal de notificación')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Visitante visitante = Visitante(
      nombreCompleto: nombreController.text,
      correo: correoController.text,
      telefono: telefonoController.text,
      empresa: empresaController.text.isEmpty ? null : empresaController.text,
      cargo: cargoController.text.isEmpty ? null : cargoController.text,
      productosInteres: seleccionados,
      notas: notasController.text.isEmpty ? null : notasController.text,
    );

    // Aquí podrías añadir el canal de notificación si tu backend lo soporta
    Map<String, dynamic> jsonVisitante = visitante.toJson();
    jsonVisitante['canal_notificacion'] = _canalSeleccionado == CanalNotificacion.correo ? 'correo' : 'telefono';

    bool exito = await ApiService.registrarVisitante(jsonVisitante);

    setState(() => _isLoading = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitante registrado con éxito')),
      );

      setState(() {
        _registrado = true;
        _visitanteRegistrado = visitante;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar visitante')),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF0080FF), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_registrado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Código QR del visitante')),
        body: Center(
          child: QrImageView(
            data: _visitanteRegistrado.toJson().toString(),
            size: 280,
          ),
        ),
      );
    }

    if (_cargandoProductos) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registro de Visitante')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Visitante'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: _inputDecoration('Nombre completo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: correoController,
                decoration: _inputDecoration('Correo electrónico'),
                validator: validarCorreo,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefonoController,
                decoration: _inputDecoration('Teléfono'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value.length != 10) return 'El teléfono debe tener 10 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: empresaController,
                decoration: _inputDecoration('Empresa (opcional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cargoController,
                decoration: _inputDecoration('Cargo (opcional)'),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Productos de interés:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...productos.map((producto) => CheckboxListTile(
                    title: Text(
                      producto,
                      style: const TextStyle(fontSize: 15),
                    ),
                    activeColor: const Color(0xFF4CAF50),
                    value: seleccionados.contains(producto),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          seleccionados.add(producto);
                        } else {
                          seleccionados.remove(producto);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
              const SizedBox(height: 24),
              TextFormField(
                controller: notasController,
                decoration: _inputDecoration('Notas adicionales'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Por dónde quieres recibir notificaciones?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  RadioListTile<CanalNotificacion>(
                    title: const Text('Correo electrónico'),
                    value: CanalNotificacion.correo,
                    groupValue: _canalSeleccionado,
                    onChanged: (CanalNotificacion? value) {
                      setState(() {
                        _canalSeleccionado = value;
                      });
                    },
                  ),
                  RadioListTile<CanalNotificacion>(
                    title: const Text('Teléfono'),
                    value: CanalNotificacion.telefono,
                    groupValue: _canalSeleccionado,
                    onChanged: (CanalNotificacion? value) {
                      setState(() {
                        _canalSeleccionado = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Colors.green.shade700,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Registrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// El código anterior define una pantalla de registro de visitantes en Flutter. Permite ingresar datos personales, seleccionar productos de interés y elegir un canal de notificación. Al enviar el formulario, se valida la información y se registra al visitante, mostrando un código QR con los datos registrados. La interfaz es responsiva y utiliza un diseño limpio y moderno. Además, incluye validaciones para campos obligatorios y formatos específicos como el correo electrónico y el número de teléfono.
// También maneja el estado de carga y muestra mensajes de éxito o error según el resultado del registro. La lista de productos se carga desde un servicio API, y se utiliza un formulario para capturar la información del visitante. La pantalla es fácil de navegar y está diseñada para ser intuitiva para el usuario final.
// El código utiliza widgets de Flutter como `TextFormField`, `CheckboxListTile`, y `RadioListTile` para crear una experiencia de usuario interactiva. Además, emplea `QrImageView` para generar un código QR con los datos del visitante registrado, lo que facilita el acceso a la información de manera rápida y eficiente.
// Este código es un ejemplo completo de cómo implementar un registro de visitantes en una aplicación Flutter, integrando validaciones, selección de productos y generación de códigos QR.
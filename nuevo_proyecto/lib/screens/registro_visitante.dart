import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/visitante.dart';
import '../services/api_service.dart';

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

  List<String> productos = ['Producto A', 'Producto B', 'Producto C'];
  List<String> seleccionados = [];

  bool _isLoading = false;
  bool _registrado = false;
  late Visitante _visitanteRegistrado;

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

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

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

    bool exito = await ApiService.registrarVisitante(visitante.toJson());

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

  @override
  Widget build(BuildContext context) {
    if (_registrado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Código QR del visitante')),
        body: Center(
          child: QrImageView(
            data: _visitanteRegistrado.toJson().toString(),
            size: 250,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Visitante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: empresaController,
                  decoration: const InputDecoration(labelText: 'Empresa (opcional)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: cargoController,
                  decoration: const InputDecoration(labelText: 'Cargo (opcional)'),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Productos de interés:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...productos.map((producto) => CheckboxListTile(
                      title: Text(producto),
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
                    )),
                TextFormField(
                  controller: notasController,
                  decoration: const InputDecoration(labelText: 'Notas adicionales'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrar,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Registrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

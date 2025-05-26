//lib/screens/registro_visitante.dart
import 'package:flutter/material.dart';

class RegistroVisitanteScreen extends StatefulWidget {
  const RegistroVisitanteScreen({Key? key}) : super(key: key);

  @override
  State<RegistroVisitanteScreen> createState() => _RegistroVisitanteScreenState();
}

class _RegistroVisitanteScreenState extends State<RegistroVisitanteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final empresaController = TextEditingController();
  final cargoController = TextEditingController();
  final notasController = TextEditingController();

  // Simulación productos de interés
  List<String> productos = ['Producto A', 'Producto B', 'Producto C'];
  List<String> seleccionados = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Visitante')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: empresaController,
                  decoration: const InputDecoration(labelText: 'Empresa (opcional)'),
                ),
                TextFormField(
                  controller: cargoController,
                  decoration: const InputDecoration(labelText: 'Cargo (opcional)'),
                ),
                const SizedBox(height: 16),
                const Text('Productos de interés:'),
                ...productos.map((producto) => CheckboxListTile(
                  title: Text(producto),
                  value: seleccionados.contains(producto),
                  onChanged: (value) {
                    setState(() {
                      value!
                          ? seleccionados.add(producto)
                          : seleccionados.remove(producto);
                    });
                  },
                )),
                TextFormField(
                  controller: notasController,
                  decoration: const InputDecoration(labelText: 'Notas adicionales'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Aquí se puede guardar o enviar los datos
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Visitante registrado')),
                      );
                    }
                  },
                  child: const Text('Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

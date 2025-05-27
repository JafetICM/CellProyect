//lib/screens/qr_visitante_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/visitante.dart';

class QrVisitanteScreen extends StatelessWidget {
  final Visitante visitante;

  const QrVisitanteScreen({Key? key, required this.visitante}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convierte los datos del visitante a JSON string para el QR
    final qrData = visitante.toJson().toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Código QR del visitante')),
      body: Center(
        child: QrImageView(
          data: qrData,
          size: 250,
        ),
      ),
    );
  }
}

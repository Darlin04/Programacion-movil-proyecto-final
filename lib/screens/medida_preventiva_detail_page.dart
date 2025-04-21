import 'package:flutter/material.dart';
import '../models/medida_preventiva.dart';

class MedidaPreventivaDetailPage extends StatelessWidget {
  final MedidaPreventiva medida;

  const MedidaPreventivaDetailPage({super.key, required this.medida});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medida.titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medida.titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),

            if (medida.fotoUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    medida.fotoUrl,
                    fit: BoxFit.contain,
                     height: 250,
                     width: double.infinity,
                     loadingBuilder: (context, child, progress) =>
                         progress == null ? child : const Center(child: CircularProgressIndicator()),
                     errorBuilder: (context, error, stackTrace) =>
                         const Text('No se pudo cargar la imagen.', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ),
             if (medida.fotoUrl.isNotEmpty)
                const SizedBox(height: 20.0),

            Text(
              'Descripción:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              medida.descripcion,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
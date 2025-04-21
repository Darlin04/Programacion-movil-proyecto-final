import 'package:flutter/material.dart';
import '../models/albergue.dart';

class AlbergueDetailPage extends StatelessWidget {
  final Albergue albergue;

  const AlbergueDetailPage({super.key, required this.albergue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(albergue.edificio),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(context, Icons.business, 'Edificio', albergue.edificio),
            _buildDetailItem(context, Icons.location_city, 'Ciudad', albergue.ciudad),
            _buildDetailItem(context, Icons.person, 'Coordinador', albergue.coordinador),
            _buildDetailItem(context, Icons.phone, 'Teléfono', albergue.telefono),
            _buildDetailItem(context, Icons.people, 'Capacidad', albergue.capacidad),
             _buildDetailItem(context, Icons.tag, 'Código', albergue.codigo),
            _buildDetailItem(context, Icons.map, 'Coordenadas', 'Lat: ${albergue.lat}, Lon: ${albergue.lng}'),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
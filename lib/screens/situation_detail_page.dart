import 'package:flutter/material.dart';
import '../models/situation.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class SituationDetailPage extends StatelessWidget {
  final Situation situation;

  const SituationDetailPage({required this.situation, super.key});

  @override
  Widget build(BuildContext context) {
     final formattedDate = DateFormat('dd/MM/yyyy hh:mm a', 'es_DO').format(situation.createdAt);
     final Uint8List? imageBytes = situation.imageBytes;

    return Scaffold(
      appBar: AppBar(
        title: Text(situation.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                 constraints: const BoxConstraints(maxHeight: 300),
                 child: imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                           print("Image.memory error for situation ${situation.id}: $error");
                           return _buildImageErrorPlaceholder();
                        },
                      ),
                    )
                  : _buildImagePlaceholder(),
              ),
            ),
            const SizedBox(height: 24.0),

            _buildDetailRow(context, Icons.tag, 'Código (ID):', situation.id),
            _buildDetailRow(context, Icons.calendar_today, 'Fecha:', formattedDate),
            _buildDetailRow(context, Icons.title, 'Título:', situation.title),

            if (situation.estado != null && situation.estado!.isNotEmpty)
              _buildDetailRow(
                  context,
                  Icons.label_important_outline,
                  'Estado:',
                  situation.estado!
               ),

            const SizedBox(height: 12),
             Text('Descripción:', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),),
             const SizedBox(height: 4),
             Text(situation.description, style: Theme.of(context).textTheme.bodyLarge,),
             const SizedBox(height: 12),

             const Divider(height: 24),
              Text('Ubicación Reportada:', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),),
             const SizedBox(height: 4),
              Text('Latitud: ${situation.latitude.toStringAsFixed(6)}'),
              Text('Longitud: ${situation.longitude.toStringAsFixed(6)}'),
             const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            '$label ',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildImagePlaceholder() {
     return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
        ),
     );
   }

   Widget _buildImageErrorPlaceholder() {
      return Container(
         height: 200,
         decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.red[200]!)
         ),
         child: Center(
           child: Icon(Icons.broken_image, size: 60, color: Colors.red[300]),
         ),
      );
   }
}
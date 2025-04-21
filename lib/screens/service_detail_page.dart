import 'package:flutter/material.dart';
import '../models/service_item.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceItem service;

  const ServiceDetailPage({required this.service, super.key});

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Icon(Icons.support_agent, size: 60, color: Colors.grey[400]),
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
           child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.red[300]),
         ),
      );
   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.photoUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    service.photoUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                       return progress == null
                          ? child
                          : SizedBox(
                              height: 250,
                              child: Center(child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                              )),
                            );
                    },
                    errorBuilder: (context, error, stackTrace) {
                       print("Error loading service detail image ${service.photoUrl}: $error");
                       return _buildImageErrorPlaceholder();
                    },
                  ),
                ),
              )
            else
              Center(child: _buildImagePlaceholder()),

            const SizedBox(height: 24.0),

            Text(
              service.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const SizedBox(height: 16.0),
             const Divider(),
            const SizedBox(height: 16.0),

             Text(
               'Descripción del Servicio:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800]
                )
             ),
             const SizedBox(height: 8.0),
            Text(
              service.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
             const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
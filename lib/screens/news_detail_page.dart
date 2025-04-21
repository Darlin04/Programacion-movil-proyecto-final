import 'package:flutter/material.dart';
import '../models/news_item.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsItem newsItem;

  const NewsDetailPage({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(newsItem.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItem.titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),

             Text(
               'Fecha: ${newsItem.fechaFormateada}',
               style: Theme.of(context).textTheme.titleSmall?.copyWith(
                     color: Colors.grey[600],
                   ),
             ),
            const SizedBox(height: 16.0),


            if (newsItem.foto.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    newsItem.foto,
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
            if (newsItem.foto.isNotEmpty)
              const SizedBox(height: 20.0),

            Text(
              newsItem.contenido,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
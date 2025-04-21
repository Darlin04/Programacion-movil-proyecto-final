import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'news_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  static const routeName = '/news';

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<NewsItem>> _newsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _newsFuture = _apiService.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<NewsItem>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar noticias: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          else if (snapshot.hasData) {
            final newsList = snapshot.data!;
            if (newsList.isEmpty) {
              return const Center(child: Text('No hay noticias disponibles.'));
            }

            return ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final newsItem = newsList[index];
                final imageUrl = newsItem.foto;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  elevation: 3,
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                      ? SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                             borderRadius: BorderRadius.circular(8.0),
                             child: Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                return progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2));
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print("Error cargando imagen: $imageUrl, Error: $error");
                                return const Icon(Icons.broken_image, color: Colors.grey, size: 40);
                              },
                            ),
                           )
                        )
                      : const SizedBox(width: 80, height: 80, child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                    title: Text(newsItem.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                       newsItem.contenido,
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailPage(newsItem: newsItem),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          else {
            return const Center(child: Text('Algo salió mal.'));
          }
        },
      ),
    );
  }
}
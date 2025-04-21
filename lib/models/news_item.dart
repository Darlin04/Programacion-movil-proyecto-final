import 'dart:convert';

class NewsItem {
  final String id;
  final String fecha;
  final String titulo;
  final String contenido;
  final String foto;

  NewsItem({
    required this.id,
    required this.fecha,
    required this.titulo,
    required this.contenido,
    required this.foto,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      fecha: json['fecha'] ?? 'Fecha desconocida',
      titulo: json['titulo'] ?? 'Sin título',
      contenido: json['contenido'] ?? 'Sin contenido',
      foto: json['foto'] ?? '',
    );
  }

  static List<NewsItem> listFromJson(String jsonString) {
    final data = json.decode(jsonString);
    if (data['exito'] == true && data['datos'] != null) {
      final List<dynamic> jsonData = data['datos'];
      return jsonData.map((item) => NewsItem.fromJson(item)).toList();
    } else {
      print("Error en API noticias o datos vacíos: ${data['mensaje']}");
      return [];
    }
  }

   String get fechaFormateada {
     try {
        final date = DateTime.parse(fecha);
        return "${date.day}/${date.month}/${date.year}";
     } catch (e) {
        return fecha;
     }
   }
}
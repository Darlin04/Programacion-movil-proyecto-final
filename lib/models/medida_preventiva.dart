import 'dart:convert';

class MedidaPreventiva {
  final String id;
  final String titulo;
  final String descripcion;
  final String fotoUrl;

  MedidaPreventiva({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fotoUrl,
  });

  factory MedidaPreventiva.fromJson(Map<String, dynamic> json) {
    return MedidaPreventiva(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? 'Sin título',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      fotoUrl: json['foto'] ?? '',
    );
  }

  static List<MedidaPreventiva> listFromJson(String jsonString) {
    final data = json.decode(jsonString);
    if (data['exito'] == true && data['datos'] != null) {
      final List<dynamic> jsonData = data['datos'];
      return jsonData.map((item) => MedidaPreventiva.fromJson(item)).toList();
    } else {
      print("Error en API medidas_preventivas o datos vacíos: ${data['mensaje']}");
      return [];
    }
  }
}
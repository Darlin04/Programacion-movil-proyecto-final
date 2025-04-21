import 'dart:convert';

class Miembro {
  final String id;
  final String fotoUrl;
  final String nombre;
  final String cargo;

  Miembro({
    required this.id,
    required this.fotoUrl,
    required this.nombre,
    required this.cargo,
  });

  factory Miembro.fromJson(Map<String, dynamic> json) {
    return Miembro(
      id: json['id'] ?? '',
      fotoUrl: json['foto'] ?? '',
      nombre: json['nombre'] ?? 'Nombre no disponible',
      cargo: json['cargo'] ?? 'Cargo no disponible',
    );
  }

  static List<Miembro> listFromJson(String jsonString) {
    final data = json.decode(jsonString);
    if (data['exito'] == true && data['datos'] != null) {
      final List<dynamic> jsonData = data['datos'];
      return jsonData.map((item) => Miembro.fromJson(item)).toList();
    } else {
      print("Error en API miembros o datos vacíos: ${data['mensaje']}");
      return [];
    }
  }
}
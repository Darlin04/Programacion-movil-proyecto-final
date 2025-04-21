import 'dart:convert';

class Albergue {
  final String ciudad;
  final String codigo;
  final String edificio;
  final String coordinador;
  final String telefono;
  final String capacidad;
  final String lat;
  final String lng;

  Albergue({
    required this.ciudad,
    required this.codigo,
    required this.edificio,
    required this.coordinador,
    required this.telefono,
    required this.capacidad,
    required this.lat,
    required this.lng,
  });

  factory Albergue.fromJson(Map<String, dynamic> json) {
    return Albergue(
      ciudad: json['ciudad'] ?? 'Ciudad no disponible',
      codigo: json['codigo'] ?? 'Código no disponible',
      edificio: json['edificio'] ?? 'Edificio no disponible',
      coordinador: json['coordinador'] ?? 'Coordinador no disponible',
      telefono: json['telefono'] ?? 'Teléfono no disponible',
      capacidad: json['capacidad'] ?? '0 personas',
      lat: json['lat'] ?? '0.0',
      lng: json['lng'] ?? '0.0',
    );
  }

  static List<Albergue> listFromJson(String jsonString) {
    final data = json.decode(jsonString);
    if (data['exito'] == true && data['datos'] != null) {
      final List<dynamic> jsonData = data['datos'];
      return jsonData.map((item) => Albergue.fromJson(item)).toList();
    } else {
      print("Error en API albergues o datos vacíos: ${data['mensaje']}");
      return [];
    }
  }

  int get capacidadNumerica {
    final match = RegExp(r'^\d+').firstMatch(capacidad);
    return int.tryParse(match?.group(0) ?? '0') ?? 0;
  }

  double get latitudNumerica {
    return double.tryParse(lat) ?? 0.0;
  }
   double get longitudNumerica {
    return double.tryParse(lng) ?? 0.0;
  }
}
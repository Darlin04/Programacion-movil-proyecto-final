import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class Situation {
  final String id;
  final String title;
  final String description;
  final String volunteerId;
  final String? photoBase64;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String? estado;

  Situation({
    required this.id,
    required this.title,
    required this.description,
    required this.volunteerId,
    this.photoBase64,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.estado,
  });

  factory Situation.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String? dateString = json['fecha'];

    return Situation(
      id: json['id']?.toString() ?? 'N/A',
      title: json['titulo'] ?? 'Sin Título',
      description: json['descripcion'] ?? 'Sin Descripción',
      volunteerId: json['voluntario']?.toString() ?? 'N/A',
      photoBase64: json['foto'],
      latitude: parseDouble(json['latitud']),
      longitude: parseDouble(json['longitud']),
      createdAt: DateTime.tryParse(dateString ?? '') ?? DateTime.now(),
      estado: json['estado'],
    );
  }

  Uint8List? get imageBytes {
    if (photoBase64 == null || photoBase64!.isEmpty || photoBase64 == "base64") {
      return null;
    }
    try {
      String base64String = photoBase64!;
      if (base64String.startsWith('data:image')) {
        base64String = base64String.split(',').last;
      }
      String normalizedBase64 = base64.normalize(base64String);
      return base64Decode(normalizedBase64);
    } catch (e) {
      if (kDebugMode) {
          print("======================================================");
          print("Error decoding base64 image for situation ID: $id");
          print("Error type: ${e.runtimeType}");
          print("Error message: $e");
          print("Base64 start: ${photoBase64?.substring(0, (photoBase64?.length ?? 0) < 100 ? photoBase64?.length : 100)}...");
          print("======================================================");
      }
      return null;
    }
  }
}
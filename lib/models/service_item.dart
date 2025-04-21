class ServiceItem {
  final String id;
  final String name;
  final String description;
  final String photoUrl;

  ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id']?.toString() ?? 'N/A',
      name: json['nombre'] ?? 'Sin Nombre',
      description: json['descripcion'] ?? 'Sin Descripción',
      photoUrl: json['foto'] ?? '',
    );
  }
}
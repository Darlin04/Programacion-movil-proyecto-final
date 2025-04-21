import 'package:flutter/material.dart';
import '../models/miembro.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class MiembrosPage extends StatefulWidget {
  const MiembrosPage({super.key});

  static const routeName = '/miembros';

  @override
  State<MiembrosPage> createState() => _MiembrosPageState();
}

class _MiembrosPageState extends State<MiembrosPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Miembro>> _miembrosFuture;

  @override
  void initState() {
    super.initState();
    _miembrosFuture = _apiService.fetchMiembros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Miembro>>(
        future: _miembrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar miembros: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          else if (snapshot.hasData) {
            final miembros = snapshot.data!;
            if (miembros.isEmpty) {
              return const Center(child: Text('No hay miembros disponibles.'));
            }

            return ListView.builder(
              itemCount: miembros.length,
              itemBuilder: (context, index) {
                final miembro = miembros[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: miembro.fotoUrl.isNotEmpty
                          ? NetworkImage(miembro.fotoUrl)
                          : null,
                      child: miembro.fotoUrl.isEmpty
                          ? const Icon(Icons.person, size: 30, color: Colors.grey)
                          : null,
                    ),
                    title: Text(miembro.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(miembro.cargo),
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
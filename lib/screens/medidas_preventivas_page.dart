import 'package:flutter/material.dart';
import '../models/medida_preventiva.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'medida_preventiva_detail_page.dart';

class MedidasPreventivasPage extends StatefulWidget {
  const MedidasPreventivasPage({super.key});

  static const routeName = '/medidas-preventivas';

  @override
  State<MedidasPreventivasPage> createState() => _MedidasPreventivasPageState();
}

class _MedidasPreventivasPageState extends State<MedidasPreventivasPage> {
  final ApiService _apiService = ApiService();
  late Future<List<MedidaPreventiva>> _medidasFuture;

  @override
  void initState() {
    super.initState();
    _medidasFuture = _apiService.fetchMedidasPreventivas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medidas Preventivas'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<MedidaPreventiva>>(
        future: _medidasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar medidas: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          else if (snapshot.hasData) {
            final medidas = snapshot.data!;
            if (medidas.isEmpty) {
              return const Center(child: Text('No hay medidas preventivas disponibles.'));
            }

            return ListView.builder(
              itemCount: medidas.length,
              itemBuilder: (context, index) {
                final medida = medidas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    leading: medida.fotoUrl.isNotEmpty
                        ? SizedBox(
                            width: 60,
                            height: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                medida.fotoUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) =>
                                    progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              ),
                            ),
                          )
                        : const SizedBox(width: 60, height: 60, child: Icon(Icons.shield_outlined, color: Colors.grey, size: 40)),
                    title: Text(medida.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedidaPreventivaDetailPage(medida: medida),
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
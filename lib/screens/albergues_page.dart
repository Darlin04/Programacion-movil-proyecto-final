import 'package:flutter/material.dart';
import '../models/albergue.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'albergue_detail_page.dart';

class AlberguesPage extends StatefulWidget {
  const AlberguesPage({super.key});

  static const routeName = '/albergues';

  @override
  State<AlberguesPage> createState() => _AlberguesPageState();
}

class _AlberguesPageState extends State<AlberguesPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Albergue>> _alberguesFuture;
  List<Albergue> _allAlbergues = [];
  List<Albergue> _filteredAlbergues = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _alberguesFuture = _fetchAndSetAlbergues();
    _searchController.addListener(_filterAlbergues);
  }

  Future<List<Albergue>> _fetchAndSetAlbergues() async {
    try {
      final albergues = await _apiService.fetchAlbergues();
      setState(() {
        _allAlbergues = albergues;
        _filteredAlbergues = List.from(_allAlbergues);
      });
      return albergues;
    } catch (e) {
       print("Error en _fetchAndSetAlbergues: $e");
       setState(() {
         _allAlbergues = [];
         _filteredAlbergues = [];
       });
       throw e;
    }
  }


  void _filterAlbergues() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredAlbergues = List.from(_allAlbergues);
      } else {
        _filteredAlbergues = _allAlbergues.where((albergue) {
          final edificioLower = albergue.edificio.toLowerCase();
          final ciudadLower = albergue.ciudad.toLowerCase();
          final codigoLower = albergue.codigo.toLowerCase();
          return edificioLower.contains(query) ||
                 ciudadLower.contains(query) ||
                 codigoLower.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAlbergues);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albergues'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por edificio, ciudad o código',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Albergue>>(
              future: _alberguesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (_allAlbergues.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
                else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error al cargar albergues: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                 else if (_allAlbergues.isEmpty) {
                  return const Center(child: Text('No hay albergues disponibles.'));
                 }
                 else if (_filteredAlbergues.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(child: Text('No se encontraron albergues con ese criterio.'));
                 }

                 return ListView.builder(
                   itemCount: _filteredAlbergues.length,
                   itemBuilder: (context, index) {
                     final albergue = _filteredAlbergues[index];
                     return Card(
                       margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                       child: ListTile(
                         title: Text(albergue.edificio, style: const TextStyle(fontWeight: FontWeight.bold)),
                         subtitle: Text('${albergue.ciudad} - Cap: ${albergue.capacidadNumerica}'),
                         trailing: const Icon(Icons.chevron_right),
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => AlbergueDetailPage(albergue: albergue),
                             ),
                           );
                         },
                       ),
                     );
                   },
                 );

              },
            ),
          ),
        ],
      ),
    );
  }
}
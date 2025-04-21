import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/albergue.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class AlberguesMapPage extends StatefulWidget {
  const AlberguesMapPage({super.key});

  static const routeName = '/mapa-albergues';

  @override
  State<AlberguesMapPage> createState() => _AlberguesMapPageState();
}

class _AlberguesMapPageState extends State<AlberguesMapPage> {
  final ApiService _apiService = ApiService();
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(18.7357, -70.1627),
    zoom: 8.0,
  );

  @override
  void initState() {
    super.initState();
    _loadAlberguesData();
  }

  Future<void> _loadAlberguesData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _markers = {};
    });
    print("Iniciando carga de datos de albergues...");
    try {
      final List<Albergue> albergues = await _apiService.fetchAlbergues();
      print("Albergues recibidos de la API: ${albergues.length}");
      if (!mounted) return;
      _createMarkers(albergues);
    } catch (e) {
      print("Error detallado al cargar albergues: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error al cargar albergues. Verifica la conexión.";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print("Carga de datos finalizada. isLoading: $_isLoading");
    }
  }

  void _createMarkers(List<Albergue> albergues) {
    print("Creando marcadores (con inversión lat/lng)...");
    final Set<Marker> tempMarkers = {};
    int markersCreados = 0;

    for (final albergue in albergues) {
      final double? parsedLatitude = double.tryParse(albergue.lng);
      final double? parsedLongitude = double.tryParse(albergue.lat);

      if (parsedLatitude != null && parsedLongitude != null) {

        if (parsedLatitude >= -90 && parsedLatitude <= 90 &&
            parsedLongitude >= -180 && parsedLongitude <= 180) {

              tempMarkers.add(
                Marker(
                  markerId: MarkerId(albergue.codigo),
                  position: LatLng(parsedLatitude, parsedLongitude),
                  infoWindow: InfoWindow(
                    title: albergue.edificio,
                    snippet: '${albergue.ciudad} | Cap: ${albergue.capacidad}',
                  ),
                  onTap: () {
                    print("Marker tapped: ${albergue.codigo}");
                    _showAlbergueDetailsSnackbar(albergue);
                  }
                ),
              );
              markersCreados++;
        } else {
           print(" (!) Coordenadas CORREGIDAS fuera de rango para ${albergue.codigo}: Lat=$parsedLatitude, Lng=$parsedLongitude");
        }
      } else {
         print(" (!) Error parseando coordenadas para ${albergue.codigo}: API lng='${albergue.lng}' (para Lat), API lat='${albergue.lat}' (para Lng)");
      }
    }

    print("Total de marcadores creados: $markersCreados de ${albergues.length} albergues");

    if (mounted) {
       setState(() {
         _markers = tempMarkers;
       });
    }
    print("Estado actualizado. Número de marcadores en _markers: ${_markers.length}");
  }


  void _showAlbergueDetailsSnackbar(Albergue albergue) {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(albergue.edificio, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Ciudad: ${albergue.ciudad}"),
            Text("Coordinador: ${albergue.coordinador}"),
            Text("Teléfono: ${albergue.telefono}"),
            Text("Capacidad: ${albergue.capacidad}"),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
           label: 'Cerrar',
           onPressed: () {
             ScaffoldMessenger.of(context).hideCurrentSnackBar();
           },
         ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    print("Construyendo widget AlberguesMapPage. isLoading: $_isLoading, errorMessage: $_errorMessage, markers: ${_markers.length}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Albergues'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
               print("Mapa creado!");
              if (!_controller.isCompleted) {
                 _controller.complete(controller);
              }
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
          if (_isLoading)
            Container(
               color: Colors.black.withOpacity(0.3),
               child: const Center(child: CircularProgressIndicator()),
            ),
          if (_errorMessage != null && !_isLoading)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                color: Colors.redAccent.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _loadAlberguesData,
        tooltip: 'Recargar Albergues',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
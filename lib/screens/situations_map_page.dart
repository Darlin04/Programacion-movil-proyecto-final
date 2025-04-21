import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/situation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'login_page.dart';

class SituationsMapPage extends StatefulWidget {
  const SituationsMapPage({super.key});

  static const routeName = '/situations-map';

  @override
  State<SituationsMapPage> createState() => _SituationsMapPageState();
}

class _SituationsMapPageState extends State<SituationsMapPage> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(18.7357, -70.1627),
    zoom: 8.0,
  );

  @override
  void initState() {
    super.initState();
    _loadSituationsData();
  }

  Future<void> _loadSituationsData() async {
    final token = _authService.token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Debes iniciar sesión para ver el mapa.";
        _markers = {};
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_authService.isLoggedIn) {
          Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, inicia sesión.')),
          );
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _markers = {};
    });
    print("Iniciando carga de datos de situaciones...");

    try {
      final List<Situation> situations = await _apiService.fetchMySituations(token);
      print("Situaciones recibidas de la API: ${situations.length}");
      if (!mounted) return;

      _createMarkers(situations);

    } catch (e) {
      print("Error detallado al cargar situaciones: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error al cargar situaciones. Intenta de nuevo.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Carga de datos de situaciones finalizada. isLoading: $_isLoading");
    }
  }

  void _createMarkers(List<Situation> situations) {
    print("Creando marcadores para ${situations.length} situaciones...");
    final Set<Marker> tempMarkers = {};
    int markersCreados = 0;

    if (situations.isEmpty) {
       print("No hay situaciones para crear marcadores.");
       if (mounted) {
          setState(() {
             _errorMessage ??= "Aún no has reportado ninguna situación.";
          });
       }
    }

    for (final situation in situations) {
      final double? lat = situation.latitude;
      final double? lon = situation.longitude;

      if (lat != null && lon != null &&
          lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180)
      {
          tempMarkers.add(
            Marker(
              markerId: MarkerId('situation_${situation.id}'),
              position: LatLng(lat, lon),
              infoWindow: InfoWindow(
                title: situation.title,
                snippet: 'Reportado: ${situation.createdAt != null ? DateFormat('dd/MM/yyyy', 'es_DO').format(situation.createdAt!) : 'N/A'}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );
          markersCreados++;
      } else {
         print(" (!) Coordenadas inválidas o fuera de rango para situación ${situation.id}: Lat=$lat, Lng=$lon");
      }
    }

    print("Total de marcadores de situación creados: $markersCreados de ${situations.length} situaciones");

    if (mounted) {
       setState(() {
         _markers = tempMarkers;
         if (markersCreados == 0 && situations.isNotEmpty && _errorMessage == null) {
            _errorMessage = "No se pudieron mostrar situaciones (problema con coordenadas).";
         }
       });
    }
    print("Estado actualizado. Número de marcadores en _markers: ${_markers.length}");
  }


  @override
  Widget build(BuildContext context) {
    print("Construyendo widget SituationsMapPage. isLoading: $_isLoading, errorMessage: $_errorMessage, markers: ${_markers.length}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Mis Situaciones'),
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
               print("Mapa de situaciones creado!");
              if (!_controllerCompleter.isCompleted) {
                 _controllerCompleter.complete(controller);
              }
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
             mapToolbarEnabled: false,
             compassEnabled: true,
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
                color: (_errorMessage!.contains("Error") || _errorMessage!.contains("Debes iniciar"))
                       ? Colors.redAccent.withOpacity(0.9)
                       : Colors.amber.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                      color: (_errorMessage!.contains("Error") || _errorMessage!.contains("Debes iniciar"))
                             ? Colors.white
                             : Colors.black87
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _loadSituationsData,
        tooltip: 'Recargar Situaciones',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
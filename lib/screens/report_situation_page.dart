import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class ReportSituationPage extends StatefulWidget {
  const ReportSituationPage({super.key});
  static const routeName = '/report-situation';
  @override
  State<ReportSituationPage> createState() => _ReportSituationPageState();
}

class _ReportSituationPageState extends State<ReportSituationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Uint8List? _resizedImageBytes;
  String? _base64Image;
  Position? _currentPosition;
  bool _isLoading = false;
  bool _isProcessingImage = false;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessingImage) return;

    setState(() {
      _isProcessingImage = true;
      _resizedImageBytes = null;
      _base64Image = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Procesando imagen...'), duration: Duration(seconds: 4)),
    );

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        Uint8List originalImageBytes = await imageFile.readAsBytes();

        img.Image? originalImage = await compute(img.decodeImage, originalImageBytes);

        if (originalImage == null) {
           throw Exception("No se pudo decodificar la imagen.");
        }

        img.Image processedImage;
        const int maxSize = 360;

        if (originalImage.width > maxSize || originalImage.height > maxSize) {
           if (kDebugMode) {
              print("Image dimensions (${originalImage.width}w x ${originalImage.height}h) exceed ${maxSize}px limit. Resizing...");
           }
           if (originalImage.width >= originalImage.height) {
                processedImage = await compute(
                  (img.Image imgToResize) => img.copyResize(
                      imgToResize,
                      width: maxSize,
                      interpolation: img.Interpolation.average,
                  ),
                  originalImage
               );
               if (kDebugMode) print("Resized based on width to: ${processedImage.width}w x ${processedImage.height}h");

           } else {
                processedImage = await compute(
                  (img.Image imgToResize) => img.copyResize(
                      imgToResize,
                      height: maxSize,
                      interpolation: img.Interpolation.average,
                  ),
                  originalImage
               );
                if (kDebugMode) print("Resized based on height to: ${processedImage.width}w x ${processedImage.height}h");
           }
        } else {
           if (kDebugMode) {
              print("Image dimensions (${originalImage.width}w x ${originalImage.height}h) are within ${maxSize}px limits. No resize needed.");
           }
           processedImage = originalImage;
        }

        Uint8List processedBytes = await compute(
          (img.Image imgToEncode) => Uint8List.fromList(img.encodeJpg(imgToEncode, quality: 85)),
          processedImage
        );

        String base64String = base64Encode(processedBytes);

        setState(() {
          _resizedImageBytes = processedBytes;
          _base64Image = base64String;
        });

         if (!mounted) return;
         ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Imagen lista.'), duration: Duration(seconds: 1)),
         );

      } else {
         if (!mounted) return;
         ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
         );
      }
    } catch (e) {
      print("Error picking/processing image: $e");
      if (!mounted) return;
       ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar imagen: ${e.toString()}')),
      );
       setState(() {
         _resizedImageBytes = null;
         _base64Image = null;
       });
    } finally {
       if(mounted){
          setState(() {
            _isProcessingImage = false;
         });
       }
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Los servicios de ubicación están desactivados.')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
         if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado.')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
       if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado permanentemente.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;
    setState(() { _isGettingLocation = true; });
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
       if (mounted) { setState(() { _isGettingLocation = false; }); }
       return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
         setState(() { _currentPosition = position; });
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ubicación obtenida.'), duration: Duration(seconds: 1)),);
      }
    } catch (e) {
      print("Error getting location: $e");
       if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener ubicación: ${e.toString()}')),); }
    } finally {
        if (mounted) { setState(() { _isGettingLocation = false; }); }
    }
  }

  Future<void> _submitReport() async {
     if (_isLoading || _isProcessingImage) return;
     if (!_formKey.currentState!.validate()) return;
     if (_base64Image == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, seleccione y procese una foto.')),);
       return;
     }
     if (_currentPosition == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, obtenga la ubicación actual.')),);
       return;
     }
     final token = _authService.token;
     if (token == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No estás autenticado.')),);
       return;
     }
     setState(() { _isLoading = true; });
     try {
       final result = await _apiService.reportSituation(
         token: token,
         title: _titleController.text,
         description: _descriptionController.text,
         photoBase64: _base64Image!,
         latitude: _currentPosition!.latitude,
         longitude: _currentPosition!.longitude,
       );
       if (!mounted) return;
       if (result['exito'] == true) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['mensaje'] ?? 'Reporte enviado con éxito.'), backgroundColor: Colors.green,),);
         _formKey.currentState?.reset();
         _titleController.clear(); _descriptionController.clear();
         setState(() { _resizedImageBytes = null; _base64Image = null; _currentPosition = null; });
       } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar: ${result['mensaje'] ?? 'Error desconocido'}'), backgroundColor: Colors.red,),);
       }
     } catch (e) {
       if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión: ${e.toString()}'), backgroundColor: Colors.red,),); }
     } finally {
       if (mounted) { setState(() { _isLoading = false; }); }
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Situación'), centerTitle: true,),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título', hintText: 'Ej: Inundación en Calle Principal',),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un título' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción', hintText: 'Describa la situación...', alignLabelWithHint: true,),
                maxLines: 4,
                textInputAction: TextInputAction.done,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 24.0),

              Text('Foto de la Situación', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8.0),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8), color: Colors.grey.shade50,),
                child: Center(
                  child: _isProcessingImage
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 12), Text("Procesando imagen...", style: TextStyle(color: Colors.grey))])
                      : _resizedImageBytes == null
                          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_enhance, size: 60, color: Colors.grey.shade500), const SizedBox(height: 8), Text("Seleccione una imagen", style: TextStyle(color: Colors.grey.shade600))])
                          : Padding(padding: const EdgeInsets.all(8.0), child: Image.memory(_resizedImageBytes!, fit: BoxFit.contain, errorBuilder: (ctx, err, st) => const Center(child: Text("Error preview", textAlign: TextAlign.center, style: TextStyle(color: Colors.red))))),
                ),
              ),
              const SizedBox(height: 8.0),
              Opacity(
                 opacity: _isProcessingImage || _isLoading ? 0.5 : 1.0,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                      ElevatedButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Galería'), onPressed: (_isProcessingImage || _isLoading) ? null : () => _pickImage(ImageSource.gallery), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),),
                      ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Cámara'), onPressed: (_isProcessingImage || _isLoading) ? null : () => _pickImage(ImageSource.camera), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),),
                   ],
                 ),
              ),
              const SizedBox(height: 24.0),

              Text('Ubicación del Reporte', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8.0),
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8), color: Colors.grey.shade50,),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(children: [Icon(Icons.location_on_outlined, color: Colors.grey.shade700, size: 20), const SizedBox(width: 8), Expanded(child: _currentPosition != null ? Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(5)}') : const Text('Ubicación no obtenida aún.', style: TextStyle(color: Colors.grey)),),],),
                       const SizedBox(height: 8),
                       Center(child: _isGettingLocation ? const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3)),) : TextButton.icon(icon: const Icon(Icons.location_searching, size: 20), label: const Text('Obtener Ubicación Actual'), onPressed: (_isLoading || _isGettingLocation) ? null : _getCurrentLocation,),),
                    ],
                 )
              ),
              const SizedBox(height: 32.0),

              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator(),))
                  : ElevatedButton.icon(icon: const Icon(Icons.send), label: const Text('Enviar Reporte'), onPressed: (_isProcessingImage || _isGettingLocation) ? null : _submitReport, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16),),),
               const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
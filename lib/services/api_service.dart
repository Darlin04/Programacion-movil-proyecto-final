import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/news_item.dart';
import '../models/albergue.dart';
import '../models/medida_preventiva.dart';
import '../models/miembro.dart';
import '../models/situation.dart';
import '../models/service_item.dart';

class ApiService {
  static const String _baseUrl = 'https://adamix.net/defensa_civil/def/';

  Future<Map<String, dynamic>> registerVolunteer({
    required String cedula,
    required String nombre,
    required String apellido,
    required String clave,
    required String correo,
    required String telefono,
  }) async {
    final url = Uri.parse('${_baseUrl}registro.php');
    try {
      final response = await http.post(
        url,
        body: {
          'cedula': cedula,
          'nombre': nombre,
          'apellido': apellido,
          'clave': clave,
          'correo': correo,
          'telefono': telefono,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        return decodedData;
      } else {
         try {
           final Map<String, dynamic> errorData = json.decode(response.body);
           return {
             "exito": false,
             "mensaje": "Error (${response.statusCode}): ${errorData['mensaje'] ?? response.body}",
             "datos": []
           };
         } catch (_) {
            return {
             "exito": false,
             "mensaje": "Error en la solicitud de registro: ${response.statusCode}",
             "datos": []
           };
         }
      }
    } catch (e) {
      print('Error in registerVolunteer: $e');
       return {
         "exito": false,
         "mensaje": "No se pudo conectar al servidor. Verifica tu conexión.",
         "datos": []
       };
    }
  }

  Future<Map<String, dynamic>> login(String cedula, String password) async {
    final url = Uri.parse('${_baseUrl}iniciar_sesion.php');
    try {
      final response = await http.post(
        url,
        body: {
          'cedula': cedula,
          'clave': password,
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['exito'] == true && decodedData['datos'] != null && decodedData['datos'] is Map) {
           return decodedData;
        } else {
          throw Exception(decodedData['mensaje'] ?? 'Credenciales incorrectas o respuesta inesperada.');
        }
      } else {
         try {
           final errorData = json.decode(response.body);
           throw Exception('Error de conexión (${response.statusCode}): ${errorData['mensaje'] ?? 'Error desconocido'}');
         } catch (_) {
            throw Exception('Error de conexión: ${response.statusCode}');
         }
      }
    } catch (e) {
      print('Error en login: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('${_baseUrl}cambiar_clave.php');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'clave_anterior': oldPassword,
          'clave_nueva': newPassword,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        return decodedData;
      } else {
         try {
           final Map<String, dynamic> errorData = json.decode(response.body);
            return {
              "exito": false,
              "mensaje": "Error (${response.statusCode}): ${errorData['mensaje'] ?? response.body}",
              "datos": []
            };
         } catch (_) {
             return {
               "exito": false,
               "mensaje": "Error al cambiar contraseña: ${response.statusCode}",
               "datos": []
             };
         }
      }
    } catch (e) {
      print('Error in changePassword: $e');
       return {
         "exito": false,
         "mensaje": "No se pudo conectar al servidor. Verifica tu conexión.",
         "datos": []
       };
    }
  }

  Future<Map<String, dynamic>> reportSituation({
    required String token,
    required String title,
    required String description,
    required String photoBase64,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('${_baseUrl}nueva_situacion.php');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'titulo': title,
          'descripcion': description,
          'foto': photoBase64,
          'latitud': latitude.toString(),
          'longitud': longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        return decodedData;
      } else {
         try {
           final Map<String, dynamic> errorData = json.decode(response.body);
            return {
              "exito": false,
              "mensaje": "Error (${response.statusCode}): ${errorData['mensaje'] ?? response.body}",
              "datos": []
            };
         } catch (_) {
             return {
               "exito": false,
               "mensaje": "Error al enviar reporte: ${response.statusCode}",
               "datos": []
             };
         }
      }
    } catch (e) {
      print('Error in reportSituation: $e');
       return {
         "exito": false,
         "mensaje": "No se pudo conectar al servidor. Verifica tu conexión.",
         "datos": []
       };
    }
  }

  Future<List<Situation>> fetchMySituations(String token) async {
    final url = Uri.parse('${_baseUrl}situaciones.php');
    try {
      final response = await http.post(
        url,
        body: {'token': token},
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['exito'] == true && decodedData['datos'] != null && decodedData['datos'] is List) {
          final List<dynamic> situationsData = decodedData['datos'];
          return situationsData
              .map((jsonMap) => Situation.fromJson(jsonMap as Map<String, dynamic>))
              .toList();
        } else if (decodedData['exito'] == true && (decodedData['datos'] == null || (decodedData['datos'] is List && decodedData['datos'].isEmpty)) ) {
           return [];
        }
        else {
          throw Exception('Error de API al obtener situaciones: ${decodedData['mensaje'] ?? 'Respuesta inesperada o datos inválidos'}');
        }
      } else {
         try {
           final errorData = json.decode(response.body);
           throw Exception('Error HTTP al obtener situaciones (${response.statusCode}): ${errorData['mensaje'] ?? response.body}');
         } catch (_) {
            throw Exception('Error HTTP al obtener situaciones: ${response.statusCode}');
         }
      }
    } catch (e) {
      print('Error in fetchMySituations: $e');
       throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<ServiceItem>> fetchServices() async {
    final url = Uri.parse('${_baseUrl}servicios.php');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['exito'] == true && decodedData['datos'] != null && decodedData['datos'] is List) {
          final List<dynamic> servicesData = decodedData['datos'];
          return servicesData
              .map((jsonMap) => ServiceItem.fromJson(jsonMap as Map<String, dynamic>))
              .toList();
       } else if (decodedData['exito'] == true && (decodedData['datos'] == null || (decodedData['datos'] is List && decodedData['datos'].isEmpty))) {
           return [];
        } else {
          throw Exception('Error de API al obtener servicios: ${decodedData['mensaje'] ?? 'Respuesta inesperada'}');
        }
      } else {
         throw Exception('Error HTTP al obtener servicios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchServices: $e');
      throw Exception('No se pudieron obtener los servicios: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }


  Future<List<NewsItem>> fetchNews() async {
    final url = Uri.parse('${_baseUrl}noticias.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['exito'] == true && decodedData['datos'] != null && decodedData['datos'] is List) {
          final List<dynamic> newsData = decodedData['datos'];
          return newsData.map((jsonMap) => NewsItem.fromJson(jsonMap as Map<String, dynamic>)).toList();
        } else if (decodedData['exito'] == true && (decodedData['datos'] == null || (decodedData['datos'] is List && decodedData['datos'].isEmpty))) {
           return [];
        }
        else {
          throw Exception('Error de API Noticias: ${decodedData['mensaje'] ?? 'Respuesta inesperada'}');
        }
      } else {
        throw Exception('Error HTTP Noticias: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchNews: $e');
      throw Exception('No se pudieron obtener las noticias. Verifica tu conexión.');
    }
  }

  Future<List<Albergue>> fetchAlbergues() async {
    final url = Uri.parse('${_baseUrl}albergues.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['exito'] == true && decodedData['datos'] != null && decodedData['datos'] is List) {
          final List<dynamic> alberguesData = decodedData['datos'];
          return alberguesData.map((jsonMap) => Albergue.fromJson(jsonMap as Map<String, dynamic>)).toList();
        } else if (decodedData['exito'] == true && (decodedData['datos'] == null || (decodedData['datos'] is List && decodedData['datos'].isEmpty))) {
            return [];
        }
         else {
          throw Exception('Error de API Albergues: ${decodedData['mensaje'] ?? 'Respuesta inesperada'}');
        }
      } else {
        throw Exception('Error HTTP Albergues: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchAlbergues: $e');
      throw Exception('No se pudieron obtener los albergues. Verifica tu conexión.');
    }
  }

  Future<List<MedidaPreventiva>> fetchMedidasPreventivas() async {
    final url = Uri.parse('${_baseUrl}medidas_preventivas.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['exito'] == true && decodedData['datos'] != null && decodedData['datos'] is List) {
          final List<dynamic> medidasData = decodedData['datos'];
          return medidasData.map((jsonMap) => MedidaPreventiva.fromJson(jsonMap as Map<String, dynamic>)).toList();
        } else if (decodedData['exito'] == true && (decodedData['datos'] == null || (decodedData['datos'] is List && decodedData['datos'].isEmpty))) {
           return [];
        }
         else {
          throw Exception('Error de API Medidas Preventivas: ${decodedData['mensaje'] ?? 'Respuesta inesperada'}');
        }
      } else {
        throw Exception('Error HTTP Medidas Preventivas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchMedidasPreventivas: $e');
      throw Exception('No se pudieron obtener las medidas preventivas. Verifica tu conexión.');
    }
  }

  Future<List<Miembro>> fetchMiembros() async {
    final url = Uri.parse('${_baseUrl}miembros.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['exito'] == true && decodedData['datos'] != null && decodedData['datos'] is List) {
          final List<dynamic> miembrosData = decodedData['datos'];
          return miembrosData.map((jsonMap) => Miembro.fromJson(jsonMap as Map<String, dynamic>)).toList();
        } else if (decodedData['exito'] == true && (decodedData['datos'] == null || (decodedData['datos'] is List && decodedData['datos'].isEmpty))) {
           return [];
        }
         else {
          throw Exception('Error de API Miembros: ${decodedData['mensaje'] ?? 'Respuesta inesperada'}');
        }
      } else {
        throw Exception('Error HTTP Miembros: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchMiembros: $e');
      throw Exception('No se pudieron obtener los miembros. Verifica tu conexión.');
    }
  }
}
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final ValueNotifier<String?> tokenNotifier = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> userDataNotifier = ValueNotifier(null);

  bool get isLoggedIn => tokenNotifier.value != null;
  String? get token => tokenNotifier.value;
  Map<String, dynamic>? get userData => userDataNotifier.value;

  Future<Map<String, dynamic>> login(String cedula, String clave) async {
    try {
      final Map<String, dynamic> apiResponse = await _apiService.login(cedula, clave);

      if (apiResponse['exito'] == true && apiResponse['datos'] != null && apiResponse['datos'] is Map<String, dynamic>) {

        final Map<String, dynamic> userDataMap = apiResponse['datos'];

        if (userDataMap.containsKey('token')) {
          tokenNotifier.value = userDataMap['token'] as String?;
          userDataNotifier.value = userDataMap;
          print("Login successful, token: ${tokenNotifier.value}");
          print("User data: ${userDataNotifier.value}");
          return userDataMap;
        } else {
           print("Login failed: Token not found within 'datos' field in API response.");
           throw Exception("Login failed: Token not found in user data");
        }
      } else {
         print("Login failed: API reported failure or missing data. Message: ${apiResponse['mensaje']}");
         throw Exception(apiResponse['mensaje'] ?? "Login failed: API reported failure");
      }
    } catch (e) {
       print("Login exception: $e");
      tokenNotifier.value = null;
      userDataNotifier.value = null;
      rethrow;
    }
  }

  Future<void> logout() async {
     print("Logging out");
    tokenNotifier.value = null;
    userDataNotifier.value = null;
  }

   Future<void> tryAutoLogin() async {
      print("Attempting auto-login (placeholder)");
   }
}
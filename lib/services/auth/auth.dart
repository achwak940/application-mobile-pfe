// lib/services/auth_service.dart
import 'dart:convert';
import 'package:appmobile/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:3000'; // Pour iOS ou web
  // static const String baseUrl = 'http://votre-ip:3000'; // Pour appareil physique

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Clés pour le stockage sécurisé
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/authentification/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'mot_de_passe': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Vérifier si la réponse contient une erreur
        if (data.containsKey('erreur')) {
          return AuthResponse(success: false, message: data['erreur']);
        }

        // Sauvegarder le token et l'utilisateur
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: json.encode(data['user']));

        return AuthResponse(
          success: true,
          message: data['message'] ?? 'Connexion réussie',
          token: data['token'],
          user: UserModel.fromJson(data['user']),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Erreur de connexion',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}

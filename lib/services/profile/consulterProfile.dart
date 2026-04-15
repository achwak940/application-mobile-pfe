// services/profil/profil_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appmobile/models/user_model.dart';
import 'package:appmobile/services/auth/auth.dart';

class ProfilService {
  static const String baseUrl =
      'http://localhost:3000/utilisateur'; // À modifier selon votre configuration

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Consulter le profil d'un utilisateur
  Future<Map<String, dynamic>> consulterProfil(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profil/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // La réponse a une structure {message: "...", profil: {...}}
        Map<String, dynamic> userData;
        if (data.containsKey('profil')) {
          userData = data['profil'];
        } else {
          userData = data;
        }

        final user = UserModel.fromJson(userData);

        return {
          'success': true,
          'message': data['message'] ?? 'Profil récupéré avec succès',
          'profil': user,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Non autorisé. Veuillez vous reconnecter.',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Utilisateur non trouvé'};
      } else {
        try {
          final error = json.decode(response.body);
          return {
            'success': false,
            'message':
                error['erreur'] ??
                error['message'] ??
                'Erreur lors du chargement du profil',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Erreur consulterProfil: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Récupérer le profil de l'utilisateur connecté
  Future<Map<String, dynamic>> getMyProfile() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) {
      return {'success': false, 'message': 'Utilisateur non connecté'};
    }
    return await consulterProfil(currentUser.id);
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'package:cross_file/cross_file.dart' show XFile;

class AuthService {
  static const String baseUrl = 'https://intactly-leal-beverley.ngrok-free.dev';

  // Classe pour gérer les images cross-platform
  static Future<Map<String, dynamic>> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    dynamic profileImage, // Accepte File (mobile) ou XFile (web)
  }) async {
    try {
      print('📤 Début inscription: $email');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/utilisateur/register'),
      );

      // Ajout des champs texte
      request.fields['prenom'] = prenom;
      request.fields['nom'] = nom;
      request.fields['email'] = email;
      request.fields['mot_de_passe'] = password;

      // Ajout de l'image si elle existe
      if (profileImage != null) {
        print('📸 Ajout image');

        if (kIsWeb) {
          // Web: Utiliser XFile
          await _addImageWeb(request, profileImage);
        } else {
          // Mobile: Utiliser File
          await _addImageMobile(request, profileImage);
        }
      } else {
        print('ℹ️ Aucune image fournie');
      }

      // Envoi de la requête
      print('📡 Envoi requête à ${request.url}');
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      print('📥 Status code: ${response.statusCode}');
      print('📄 Réponse: $responseString');

      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(responseString);
      } catch (e) {
        responseData = {'message': responseString};
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Inscription réussie',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['erreur'] ??
              responseData['message'] ??
              'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      print('❌ Erreur: $e');
      print('Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  // Méthode pour le mobile
  static Future<void> _addImageMobile(
    http.MultipartRequest request,
    File imageFile,
  ) async {
    try {
      if (await imageFile.exists()) {
        List<int> imageBytes = await imageFile.readAsBytes();
        print('📊 Taille image: ${imageBytes.length} bytes');

        String mimeType = _getMimeType(imageFile.path);
        String extension = _getExtension(imageFile.path);

        var multipartFile = http.MultipartFile.fromBytes(
          'photo_profil',
          imageBytes,
          filename:
              'profile_${DateTime.now().millisecondsSinceEpoch}.$extension',
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
        print('✅ Image mobile ajoutée');
      } else {
        print('❌ Fichier image non trouvé');
      }
    } catch (e) {
      print('❌ Erreur ajout image mobile: $e');
    }
  }

  // Méthode pour le web
  static Future<void> _addImageWeb(
    http.MultipartRequest request,
    XFile imageFile,
  ) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      print('📊 Taille image web: ${imageBytes.length} bytes');

      String mimeType = imageFile.mimeType ?? 'image/jpeg';
      String fileName = imageFile.name;

      var multipartFile = http.MultipartFile.fromBytes(
        'photo_profil',
        imageBytes,
        filename: fileName.isNotEmpty
            ? fileName
            : 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);
      print('✅ Image web ajoutée');
    } catch (e) {
      print('❌ Erreur ajout image web: $e');
    }
  }

  static String _getMimeType(String path) {
    if (path.toLowerCase().endsWith('.png')) {
      return 'image/png';
    } else if (path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (path.toLowerCase().endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/jpeg';
  }

  static String _getExtension(String path) {
    if (path.toLowerCase().endsWith('.png')) {
      return 'png';
    } else if (path.toLowerCase().endsWith('.jpg')) {
      return 'jpg';
    } else if (path.toLowerCase().endsWith('.jpeg')) {
      return 'jpeg';
    } else if (path.toLowerCase().endsWith('.gif')) {
      return 'gif';
    }
    return 'jpg';
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Tentative de connexion: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/utilisateur/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'mot_de_passe': password}),
      );

      final responseData = json.decode(response.body);
      print('📥 Login status: ${response.statusCode}');
      print('📄 Login response: $responseData');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Connexion réussie',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['erreur'] ??
              responseData['message'] ??
              'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
      print('❌ Erreur login: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }
}

// Import pour mobile uniquement

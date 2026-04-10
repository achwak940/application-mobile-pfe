import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ CORRIGÉ : suppression de l'espace à la fin
  static const String baseUrl = 'http://localhost:3000/utilisateur/get/all';

  Future<List<dynamic>> getUsers() async {
    try {
      print('🌐 Appel API: $baseUrl');

      final response = await http
          .get(Uri.parse('$baseUrl'))
          .timeout(const Duration(seconds: 10));

      print('✅ Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> usersList = jsonDecode(response.body);
        print('📦 ${usersList.length} utilisateurs trouvés');
        return usersList;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }
}

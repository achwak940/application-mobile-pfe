import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, dynamic>> getEnqueteById(int id) async {
    final String url = 'http://localhost:3000/enquete/detailes/$id';

    print('==============================');
    print('🚀 START API CALL');
    print('🌐 URL: $url');

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      print('📡 RESPONSE RECEIVED');
      print('📊 STATUS CODE: ${response.statusCode}');
      print('📦 RAW BODY: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        print('✅ JSON DECODE SUCCESS');
        print('📌 MESSAGE: ${body['message']}');

        print('📥 DATA TYPE: ${body['data'].runtimeType}');
        print('📥 DATA: ${body['data']}');

        print('==============================');
        print('🎯 END SUCCESS API CALL');

        return body['data'];
      } else {
        print('❌ HTTP ERROR');
        print('ERROR CODE: ${response.statusCode}');
        print('ERROR BODY: ${response.body}');
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('==============================');
      print('🔥 EXCEPTION OCCURRED');
      print('ERROR: $e');
      print('==============================');
      throw Exception('Erreur de connexion: $e');
    }
  }
}
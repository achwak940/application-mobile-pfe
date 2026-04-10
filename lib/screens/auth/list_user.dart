import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appmobile/services/list_users.dart'; // Votre ApiService

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _testDirectApi(); // Test direct
    _loadUsers(); // Charge les utilisateurs
  }

  // Test direct de l'API
  Future<void> _testDirectApi() async {
    try {
      print('=== TEST DIRECT API ===');
      
      // Test 1: localhost
      print('Test 1: localhost');
      var response = await http.get(
        Uri.parse('http://localhost:3000/utilisateur/get/all'),
      ).timeout(const Duration(seconds: 5));
      print('✅ Status localhost: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}');
      }

      // Test 2: 127.0.0.1
      print('Test 2: 127.0.0.1');
      response = await http.get(
        Uri.parse('http://127.0.0.1:3000/utilisateur/get/all'),
      ).timeout(const Duration(seconds: 5));
      print('✅ Status 127.0.0.1: ${response.statusCode}');

      // Test 3: Votre IP
      print('Test 3: IP 10.31.77.179');
      response = await http.get(
        Uri.parse('http://10.31.77.179:3000/utilisateur/get/all'),
      ).timeout(const Duration(seconds: 5));
      print('✅ Status IP: ${response.statusCode}');
      
      print('=== FIN TEST ===');
    } catch (e) {
      print('❌ Erreur test: $e');
    }
  }

  // Charge les utilisateurs via ApiService
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final users = await _apiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Utilisateurs'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Chargement des utilisateurs...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun utilisateur trouvé',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(dynamic user) {
    // Extraction sécurisée des données
    final String prenom = user['prenom'] ?? '?';
    final String nom = user['nom'] ?? '?';
    final String email = user['email'] ?? 'Pas d\'email';
    final String role = user['role'] ?? 'Rôle inconnu';
    final String statut = user['statut'] ?? 'Statut inconnu';

    // Couleur selon le rôle
    Color roleColor = Colors.blue;
    if (role == 'ROLE_ADMIN') {
      roleColor = Colors.red;
    } else if (role == 'ROLE_USER_CONNECTE') {
      roleColor = Colors.green;
    }

    // Couleur selon le statut
    Color statutColor = statut == 'ACTIF' ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          radius: 25,
          child: Text(
            prenom.isNotEmpty ? prenom[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '$prenom $nom',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.replaceFirst('ROLE_', ''),
                    style: TextStyle(
                      fontSize: 11,
                      color: roleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statutColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statut,
                    style: TextStyle(
                      fontSize: 11,
                      color: statutColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showUserDetails(user);
        },
      ),
    );
  }

  void _showUserDetails(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                (user['prenom'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${user['prenom'] ?? ''} ${user['nom'] ?? ''}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.email, 'Email', user['email'] ?? 'Non renseigné'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.phone, 'Téléphone', user['telephone'] ?? 'Non renseigné'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.admin_panel_settings, 'Rôle', (user['role'] ?? 'Inconnu').replaceFirst('ROLE_', '')),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.circle, 'Statut', user['statut'] ?? 'Inconnu'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_today, 'Date création', user['date_creation']?.split('T')[0] ?? 'Inconnue'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
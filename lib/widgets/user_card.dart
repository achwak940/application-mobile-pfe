import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final dynamic user;
  
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Text(
            user['name'][0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user['email']),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showUserDetails(context, user);
        },
      ),
    );
  }

  void _showUserDetails(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(user['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Détails utilisateur :'),
            const SizedBox(height: 12),
            Text('📧 Email: ${user['email']}'),
            if (user['phone'] != null) 
              Text('📱 Téléphone: ${user['phone']}'),
            if (user['website'] != null)
              Text('🌐 Site: ${user['website']}'),
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
}
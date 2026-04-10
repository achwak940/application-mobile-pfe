import 'package:appmobile/screens/auth/login_screen.dart';
import 'package:appmobile/screens/auth/register_screen.dart';
import 'package:appmobile/screens/gestionProfil/profil.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const Register(),
        '/profile': (context) => const ProfileConsultationScreen(),
      },
    );
  }
}

import 'package:appmobile/screens/daschbord/acceuil.dart';
import 'package:appmobile/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:appmobile/screens/auth/login_screen.dart';
import 'package:appmobile/screens/auth/register_screen.dart';
import 'package:appmobile/screens/enquete/enquete_interface.dart';
import 'package:appmobile/screens/gestionProfil/profil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      initialRoute: '/dashboard', // Changé pour démarrer sur le dashboard
      routes: {
        '/dashboard': (context) =>
            const DashboardAccueilScreen(), // Dashboard comme page principale
        '/enquete': (context) => EnqueteScreen(id: 21),
        '/register': (context) => const Register(),
        '/profile': (context) => const ProfileConsultationScreen(),
        '/login': (context) => const LoginForm(),
      },
    );
  }
}

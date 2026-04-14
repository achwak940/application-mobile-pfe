import 'package:appmobile/screens/auth/login_screen.dart';
import 'package:appmobile/screens/auth/register_screen.dart';
import 'package:appmobile/screens/daschbord/HistoriqueEnquetes.dart';
import 'package:appmobile/screens/daschbord/acceuil.dart';
import 'package:appmobile/screens/daschbord/reclamations.dart';
import 'package:appmobile/screens/daschbord/settings.dart';
import 'package:appmobile/screens/enquete/enquete_interface.dart';
import 'package:appmobile/screens/gestionProfil/profil.dart';
import 'package:appmobile/widgets/login_form.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoCare Plus',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const DashboardAccueilScreen(),
        '/enquete': (context) => const EnqueteScreen(id: 21),
        '/register': (context) => const Register(),
        '/profile': (context) => const ProfileConsultationScreen(),
        '/login': (context) => const LoginForm(),
        '/HistoriqueEnquetes': (context) => const HistoriqueEnquetesScreen(),
        '/HistoriqueReclamations': (context) => const ReclamationScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const DashboardAccueilScreen(),
        );
      },
    );
  }
}

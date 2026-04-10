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
      theme: ThemeData(primarySwatch: Colors.deepPurple),

      // 🟢 START APP
      initialRoute: '/',

      routes: {
        '/': (context) => const Enquete(id: 26), // 👈 screen enquête
        '/register': (context) => const Register(),
        '/profile': (context) => const ProfileConsultationScreen(),
      },
    );
  }
}

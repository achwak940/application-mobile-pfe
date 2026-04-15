// lib/models/user_model.dart
class UserModel {
  final int id;
  final String email;
  final String role;
  final String prenom;
  final String nom;
  final String? photoProfil;
  final String? telephone;
  final bool? estVerifie;
  final String? statut;
  final DateTime? dateCreation;
  final String? adresse;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.prenom,
    required this.nom,
    this.photoProfil,
    this.telephone,
    this.estVerifie,
    this.statut,
    this.dateCreation,
    this.adresse,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      // Support des différents formats: photo_profil (snake_case) ou photoProfil (camelCase)
      photoProfil: json['photo_profil'] ?? json['photoProfil'],
      telephone: json['telephone'],
      estVerifie: json['est_verifie'] ?? false,
      statut: json['statut'] ?? 'ACTIF',
      dateCreation: json['date_creation'] != null
          ? DateTime.tryParse(json['date_creation'])
          : null,
      adresse: json['adresse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'prenom': prenom,
      'nom': nom,
      'photo_profil': photoProfil,
      'telephone': telephone,
      'est_verifie': estVerifie,
      'statut': statut,
      'date_creation': dateCreation?.toIso8601String(),
      'adresse': adresse,
    };
  }

  String get fullName => '$prenom $nom';

  String get displayName {
    if (prenom.isNotEmpty && nom.isNotEmpty) {
      return '$prenom $nom';
    } else if (prenom.isNotEmpty) {
      return prenom;
    } else if (nom.isNotEmpty) {
      return nom;
    }
    return email.split('@').first;
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? role,
    String? prenom,
    String? nom,
    String? photoProfil,
    String? telephone,
    bool? estVerifie,
    String? statut,
    DateTime? dateCreation,
    String? adresse,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      photoProfil: photoProfil ?? this.photoProfil,
      telephone: telephone ?? this.telephone,
      estVerifie: estVerifie ?? this.estVerifie,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      adresse: adresse ?? this.adresse,
    );
  }
}

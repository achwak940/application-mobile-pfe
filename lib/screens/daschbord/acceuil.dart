// screens/dashboard/dashboard_accueil_screen.dart
import 'dart:convert';
import 'package:appmobile/screens/Menu/MenuApp.dart';
import 'package:appmobile/services/auth/auth.dart';
import 'package:appmobile/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardAccueilScreen extends StatefulWidget {
  const DashboardAccueilScreen({super.key});

  @override
  State<DashboardAccueilScreen> createState() => _DashboardAccueilScreenState();
}

class _DashboardAccueilScreenState extends State<DashboardAccueilScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Données utilisateur réelles
  UserModel? _currentUser;
  bool _isLoadingUser = true;
  ImageProvider? _cachedProfileImage;

  // KPI Data
  int _enquiriesAnswered = 148;
  int _reclamations = 23;
  double _completionRate = 92.0;

  // Notifications
  List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Nouvelle réponse à votre enquête',
      'message': 'Sarah a répondu à votre enquête sur les produits',
      'time': 'Il y a 5 minutes',
      'isRead': false,
      'type': 'enquiry',
      'enqueteId': '100',
    },
    {
      'id': '2',
      'title': 'Réclamation mise à jour',
      'message': 'Votre réclamation #R002 a été prise en compte',
      'time': 'Il y a 1 heure',
      'isRead': false,
      'type': 'complaint',
      'reclamationId': 'R002',
    },
    {
      'id': '3',
      'title': 'Rapport hebdomadaire',
      'message': 'Votre taux de complétion est en hausse de 8% cette semaine',
      'time': 'Il y a 3 heures',
      'isRead': true,
      'type': 'system',
    },
    {
      'id': '4',
      'title': 'Nouvelle enquête disponible',
      'message': 'Une nouvelle enquête de satisfaction est disponible',
      'time': 'Il y a 1 jour',
      'isRead': false,
      'type': 'enquiry',
      'enqueteId': '26',
    },
  ];

  // Mes propres enquêtes et réclamations
  List<Map<String, dynamic>> _myActivities = [];

  // Contrôleur pour le bottom sheet
  bool _isNotificationsOpen = false;

  final AuthService _authService = AuthService();

  // URL de base de votre API - À modifier selon votre configuration
  static const String _baseApiUrl =
      'http://10.0.2.2:3000'; // Pour émulateur Android
  // static const String _baseApiUrl = 'http://localhost:3000'; // Pour iOS
  // static const String _baseApiUrl = 'https://votre-api.com'; // Pour production

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
    _loadCurrentUser();
    _loadUserData();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoadingUser = true;
    });

    final user = await _authService.getCurrentUser();

    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });

      // Charger l'image de profil en cache
      if (_currentUser != null) {
        _loadProfileImage();
        _loadMyActivities();
      }
    }
  }

  Future<void> _loadProfileImage() async {
    if (_currentUser?.photoProfil == null ||
        _currentUser!.photoProfil!.isEmpty) {
      return;
    }

    final imageProvider = await _getProfileImageAsync();
    if (mounted && imageProvider != null) {
      setState(() {
        _cachedProfileImage = imageProvider;
      });
    }
  }

  Future<ImageProvider?> _getProfileImageAsync() async {
    if (_currentUser == null ||
        _currentUser!.photoProfil == null ||
        _currentUser!.photoProfil!.isEmpty) {
      return null;
    }

    final photoProfil = _currentUser!.photoProfil!;

    try {
      // Cas 1: URL HTTP/HTTPS
      if (photoProfil.startsWith('http://') ||
          photoProfil.startsWith('https://')) {
        return NetworkImage(photoProfil);
      }

      // Cas 2: Chemin local /uploads/
      if (photoProfil.startsWith('/uploads/')) {
        // Vérifier si l'image existe
        final imageUrl = '$_baseApiUrl$photoProfil';
        try {
          final response = await http.head(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            return NetworkImage(imageUrl);
          }
        } catch (e) {
          print('Image non trouvée: $e');
        }
        return null;
      }

      // Cas 3: Base64
      String cleanBase64 = photoProfil;

      // Supprimer le préfixe data:image/...;base64, si présent
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.substring(cleanBase64.indexOf(',') + 1);
      }

      // Nettoyer la chaîne (supprimer guillemets, espaces, retours à la ligne)
      cleanBase64 = cleanBase64
          .replaceAll('"', '')
          .replaceAll('\'', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '');

      // Valider le format base64
      if (cleanBase64.isNotEmpty && cleanBase64.length % 4 == 0) {
        try {
          final bytes = base64Decode(cleanBase64);
          if (bytes.isNotEmpty && bytes.length > 100) {
            // Vérifier que l'image n'est pas vide
            return MemoryImage(bytes);
          }
        } catch (e) {
          print('Erreur décodage base64: $e');
        }
      }

      return null;
    } catch (e) {
      print('Erreur chargement image: $e');
      return null;
    }
  }

  ImageProvider _getProfileImage() {
    // Image en cache
    if (_cachedProfileImage != null) {
      return _cachedProfileImage!;
    }

    // Image par défaut
    return const AssetImage('images/logo1.png');
  }

  Future<void> _loadUserData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _enquiriesAnswered = 152;
        _reclamations = 24;
        _completionRate = 93.5;
      });
    }
  }

  void _loadMyActivities() {
    final userName =
        _currentUser?.fullName ?? _currentUser?.prenom ?? "Utilisateur";

    _myActivities = [
      {
        'id': 'act1',
        'type': 'enquiry',
        'title': 'Question sur les délais de livraison',
        'user': userName,
        'time': 'Hier',
        'status': 'repondu',
        'message':
            'Quels sont les délais de livraison pour la livraison express ?',
        'enqueteId': '100',
      },
      {
        'id': 'act2',
        'type': 'complaint',
        'title': 'Colis endommagé',
        'user': userName,
        'time': 'Il y a 2 jours',
        'status': 'en_attente',
        'message': 'J\'ai reçu mon colis avec le produit endommagé',
        'reclamationId': 'R001',
      },
      {
        'id': 'act3',
        'type': 'enquiry',
        'title': 'Demande de remboursement',
        'user': userName,
        'time': 'Il y a 3 jours',
        'status': 'en_cours',
        'message': 'Je souhaite me faire rembourser ma commande',
        'enqueteId': '26',
      },
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _userDisplayName {
    if (_currentUser != null) {
      return _currentUser!.fullName;
    }
    return "Utilisateur";
  }

  String get _userFirstName {
    if (_currentUser != null) {
      return _currentUser!.prenom;
    }
    return "Utilisateur";
  }

  String get _userEmail {
    if (_currentUser != null) {
      return _currentUser!.email;
    }
    return "";
  }

  int get _unreadNotificationsCount {
    return _notifications.where((n) => n['isRead'] == false).length;
  }

  void _showNotificationsPanel() {
    _isNotificationsOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _isNotificationsOpen = false;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB794F4),
                                    Color(0xFFD4B8FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            if (_unreadNotificationsCount > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$_unreadNotificationsCount',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFB794F4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _isNotificationsOpen = false;
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFFB794F4),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                setStateBottomSheet(() {
                                  for (
                                    var i = 0;
                                    i < _notifications.length;
                                    i++
                                  ) {
                                    _notifications[i]['isRead'] = true;
                                  }
                                });
                                setState(() {});
                              },
                              child: const Text(
                                'Tout marquer',
                                style: TextStyle(
                                  color: Color(0xFFB794F4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setStateBottomSheet(() {
                                  _notifications.clear();
                                });
                                setState(() {});
                              },
                              child: const Text(
                                'Tout supprimer',
                                style: TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _notifications.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_off,
                                  size: 64,
                                  color: Color(0xFFC4C4D4),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aucune notification',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8A8A9E),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Les notifications apparaîtront ici',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFC4C4D4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              final isEnquiry =
                                  notification['type'] == 'enquiry';
                              return Dismissible(
                                key: Key(notification['id']),
                                background: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  setStateBottomSheet(() {
                                    _notifications.removeAt(index);
                                  });
                                  setState(() {});
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    setStateBottomSheet(() {
                                      notification['isRead'] = true;
                                    });
                                    setState(() {});
                                    Navigator.pop(context);
                                    _isNotificationsOpen = false;
                                    _handleNotificationTap(notification);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: notification['isRead'] == false
                                          ? const Color(0xFFF9F5FF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: notification['isRead'] == false
                                            ? const Color(0xFFB794F4)
                                            : const Color(0xFFF0F0F0),
                                        width: 1.5,
                                      ),
                                      boxShadow: notification['isRead'] == false
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFFB794F4,
                                                ).withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isEnquiry
                                                ? const Color(
                                                    0xFFB794F4,
                                                  ).withOpacity(0.1)
                                                : notification['type'] ==
                                                      'complaint'
                                                ? const Color(
                                                    0xFFFF6B6B,
                                                  ).withOpacity(0.1)
                                                : const Color(
                                                    0xFF4CAF50,
                                                  ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Icon(
                                            isEnquiry
                                                ? Icons.quiz_rounded
                                                : notification['type'] ==
                                                      'complaint'
                                                ? Icons.report_problem_rounded
                                                : Icons.info_rounded,
                                            color: isEnquiry
                                                ? const Color(0xFFB794F4)
                                                : notification['type'] ==
                                                      'complaint'
                                                ? const Color(0xFFFF6B6B)
                                                : const Color(0xFF4CAF50),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification['title'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      notification['isRead'] ==
                                                          false
                                                      ? FontWeight.w800
                                                      : FontWeight.w600,
                                                  color: const Color(
                                                    0xFF1A1A2E,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                notification['message'],
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF6B6B7E),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                notification['time'],
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF8A8A9E),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (notification['isRead'] == false)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFB794F4),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_notifications.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _isNotificationsOpen = false;
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text('Fermer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB794F4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      _isNotificationsOpen = false;
    });
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    if (notification['type'] == 'enquiry' &&
        notification.containsKey('enqueteId')) {
      _navigateToEnqueteDetail(notification['enqueteId']);
    } else if (notification['type'] == 'complaint' &&
        notification.containsKey('reclamationId')) {
      _navigateToReclamationDetail(notification['reclamationId']);
    }
  }

  void _navigateToEnqueteDetail(String enqueteId) {
    Navigator.pushNamed(
      context,
      '/HistoriqueEnquetes',
      arguments: {'selectedEnqueteId': enqueteId},
    );
  }

  void _navigateToReclamationDetail(String reclamationId) {
    Navigator.pushNamed(
      context,
      '/HistoriqueReclamations',
      arguments: {'selectedReclamationId': reclamationId},
    );
  }

  void _navigateToHistoriqueEnquetes() {
    Navigator.pushNamed(context, '/HistoriqueEnquetes');
  }

  void _navigateToHistoriqueReclamations() {
    Navigator.pushNamed(context, '/HistoriqueReclamations');
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToStatistics() {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToActivityDetail(Map<String, dynamic> activity) {
    if (activity['type'] == 'enquiry' && activity.containsKey('enqueteId')) {
      _navigateToEnqueteDetail(activity['enqueteId']);
    } else if (activity['type'] == 'complaint' &&
        activity.containsKey('reclamationId')) {
      _navigateToReclamationDetail(activity['reclamationId']);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'repondu':
        return 'Répondu';
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'repondu':
        return const Color(0xFF4CAF50);
      case 'en_attente':
        return const Color(0xFFFF9800);
      case 'en_cours':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF8A8A9E);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'repondu':
        return Icons.check_circle_rounded;
      case 'en_attente':
        return Icons.pending_rounded;
      case 'en_cours':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF9F7FD),
      body: CustomScrollView(
        slivers: [
          // AppBar avec les vraies données utilisateur
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB794F4), Color(0xFF9B7BDF)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _navigateToProfile,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFB794F4,
                                          ).withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: _isLoadingUser
                                            ? const AssetImage(
                                                    'images/logo1.png',
                                                  )
                                                  as ImageProvider
                                            : _getProfileImage(),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
                                          print(
                                            'Erreur affichage image: $exception',
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isLoadingUser)
                                      Container(
                                        width: 100,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        _userFirstName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    if (!_isLoadingUser &&
                                        _userEmail.isNotEmpty)
                                      Text(
                                        _userEmail,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: IconButton(
                                    onPressed: _showNotificationsPanel,
                                    icon: const Icon(
                                      Icons.notifications_none,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                if (_unreadNotificationsCount > 0)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF6B6B),
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        '$_unreadNotificationsCount',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenu
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Cartes KPI
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Enquêtes',
                        value: '$_enquiriesAnswered',
                        icon: Icons.quiz_rounded,
                        color: const Color(0xFFB794F4),
                        progress: _enquiriesAnswered / 200,
                        onTap: _navigateToHistoriqueEnquetes,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Réclamations',
                        value: '$_reclamations',
                        icon: Icons.report_problem_rounded,
                        color: const Color(0xFFFF6B6B),
                        progress: _reclamations / 50,
                        onTap: _navigateToHistoriqueReclamations,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Complétion',
                        value: '${_completionRate.toStringAsFixed(1)}%',
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFF4CAF50),
                        progress: _completionRate / 100,
                        onTap: _navigateToStatistics,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section Mes activités
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB794F4).withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.assignment_turned_in_rounded,
                              color: Color(0xFFB794F4),
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Mes activités récentes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_myActivities.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 48,
                                  color: Color(0xFFC4C4D4),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Aucune activité récente',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF8A8A9E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _myActivities.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          itemBuilder: (context, index) {
                            final activity = _myActivities[index];
                            final isEnquiry = activity['type'] == 'enquiry';
                            final statusText = _getStatusText(
                              activity['status'],
                            );
                            final statusColor = _getStatusColor(
                              activity['status'],
                            );
                            final statusIcon = _getStatusIcon(
                              activity['status'],
                            );

                            return GestureDetector(
                              onTap: () => _navigateToActivityDetail(activity),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isEnquiry
                                            ? const Color(
                                                0xFFB794F4,
                                              ).withOpacity(0.1)
                                            : const Color(
                                                0xFFFF6B6B,
                                              ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        isEnquiry
                                            ? Icons.quiz_rounded
                                            : Icons.car_repair_rounded,
                                        size: 22,
                                        color: isEnquiry
                                            ? const Color(0xFFB794F4)
                                            : const Color(0xFFFF6B6B),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity['title'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            activity['message'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B6B7E),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time_rounded,
                                                size: 10,
                                                color: Color(0xFF8A8A9E),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                activity['time'],
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF8A8A9E),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusIcon,
                                            size: 12,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Actions rapides
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.analytics_rounded,
                        label: 'Statistiques',
                        color: const Color(0xFFB794F4),
                        onTap: _navigateToStatistics,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.history_rounded,
                        label: 'Enquêtes',
                        color: const Color(0xFF4CAF50),
                        onTap: _navigateToHistoriqueEnquetes,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.car_repair_rounded,
                        label: 'Réclamations',
                        color: const Color(0xFFFF6B6B),
                        onTap: _navigateToHistoriqueReclamations,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double progress,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A8A9E),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

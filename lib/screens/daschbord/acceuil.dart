// screens/dashboard/dashboard_accueil_screen.dart
import 'dart:convert';
import 'package:appmobile/screens/Menu/MenuApp.dart';
import 'package:flutter/material.dart';

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

  // KPI Data
  int _enquiriesAnswered = 148;
  int _reclamations = 23;
  double _completionRate = 92.0;

  final String _userName = "Jean Dupont";
  final String _userEmail = "";

  // Profile image base64
  final String _profileImageBase64 =
      "data:image/jpeg;base64,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";

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
    _loadUserData();
    _loadMyActivities();
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
    _myActivities = [
      {
        'id': 'act1',
        'type': 'enquiry',
        'title': 'Question sur les délais de livraison',
        'user': _userName,
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
        'user': _userName,
        'time': 'Il y a 2 jours',
        'status': 'en_attente',
        'message': 'J\'ai reçu mon colis avec le produit endommagé',
        'reclamationId': 'R001',
      },
      {
        'id': 'act3',
        'type': 'enquiry',
        'title': 'Demande de remboursement',
        'user': _userName,
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

  ImageProvider _getProfileImage() {
    try {
      final bytes = base64Decode(_profileImageBase64.split(',').last);
      return MemoryImage(bytes);
    } catch (e) {
      return const AssetImage('assets/default_avatar.png');
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
          // AppBar réduite
          SliverAppBar(
            expandedHeight: 120, // Réduit de 220 à 120
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
                                    width: 50, // Réduit de 65 à 50
                                    height: 50, // Réduit de 65 à 50
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
                                        image: _getProfileImage(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userName.split(' ')[0],
                                      style: const TextStyle(
                                        fontSize: 20, // Réduit de 24 à 20
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
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
                                      size: 22, // Réduit de 26 à 22
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

// screens/historique/historique_enquetes_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';

class HistoriqueEnquetesScreen extends StatefulWidget {
  const HistoriqueEnquetesScreen({super.key});

  @override
  State<HistoriqueEnquetesScreen> createState() =>
      _HistoriqueEnquetesScreenState();
}

class _HistoriqueEnquetesScreenState extends State<HistoriqueEnquetesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  List<Map<String, dynamic>> _enquetes = [];
  bool _isSelectionMode = false;
  List<String> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    _loadEnquetes();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  void _loadEnquetes() {
    _enquetes = [
      {
        'id': '1',
        'titre': 'Délais livraison express',
        'message': 'Quels sont les délais pour la livraison express ?',
        'reponse': '24 à 48 heures ouvrées.',
        'date': '15/01/2024',
        'dateEnvoi': '15/01/2024 14:30',
        'dateReponse': '16/01/2024 09:15',
        'statut': 'repondu',
        'categorie': 'Livraison',
      },
      {
        'id': '2',
        'titre': 'Garantie accidentelle',
        'message': 'La garantie couvre-t-elle les dégâts accidentels ?',
        'reponse': 'Extension de garantie disponible.',
        'date': '10/01/2024',
        'dateEnvoi': '10/01/2024 11:20',
        'dateReponse': '11/01/2024 14:45',
        'statut': 'repondu',
        'categorie': 'Garantie',
      },
      {
        'id': '3',
        'titre': 'Remboursement commande',
        'message': 'Remboursement commande #CMD-2024-001',
        'reponse': 'Traitement sous 5-7 jours.',
        'date': '05/01/2024',
        'dateEnvoi': '05/01/2024 09:00',
        'dateReponse': '06/01/2024 16:30',
        'statut': 'repondu',
        'categorie': 'Remboursement',
      },
      {
        'id': '4',
        'titre': 'Certification bio',
        'message': 'Les produits sont-ils certifiés bio ?',
        'reponse': 'Certifiés bio par ECOCERT.',
        'date': '28/12/2023',
        'dateEnvoi': '28/12/2023 10:15',
        'dateReponse': '29/12/2023 11:00',
        'statut': 'repondu',
        'categorie': 'Produits',
      },
    ];
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _deleteSelected() {
    if (_selectedIds.isEmpty) return;
    _showDeleteDialog(
      title: 'Supprimer',
      content: 'Supprimer ${_selectedIds.length} enquête(s) ?',
      onConfirm: () {
        setState(() {
          _enquetes.removeWhere((e) => _selectedIds.contains(e['id']));
          _selectedIds.clear();
          _isSelectionMode = false;
        });
        _showSnackbar(
          '${_selectedIds.length} enquête(s) supprimée(s)',
          const Color(0xFFFF8A8A),
        );
      },
    );
  }

  void _deleteSingle(String id, int index) {
    _showDeleteDialog(
      title: 'Supprimer',
      content: 'Supprimer cette enquête ?',
      onConfirm: () {
        setState(() => _enquetes.removeAt(index));
        _showSnackbar('Enquête supprimée', const Color(0xFFFF8A8A));
      },
    );
  }

  void _deleteAll() {
    if (_enquetes.isEmpty) {
      _showSnackbar('Aucune enquête à supprimer', const Color(0xFFFF8A8A));
      return;
    }
    _showDeleteDialog(
      title: 'Supprimer tout',
      content: 'Supprimer tout l\'historique ? Action irréversible.',
      onConfirm: () {
        setState(() => _enquetes.clear());
        _showSnackbar(
          'Toutes les enquêtes supprimées',
          const Color(0xFFFF8A8A),
        );
      },
    );
  }

  void _showDeleteDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF8A8A9E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A8A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repondues = _enquetes.where((e) => e['statut'] == 'repondu').length;
    final enAttente = _enquetes.length - repondues;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _enquetes.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  setState(() => _loadEnquetes());
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildStatsCard(repondues, enAttente),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final enquete = _enquetes[index];
                        final isSelected = _selectedIds.contains(enquete['id']);
                        return SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: _buildEnqueteCard(
                              enquete,
                              index,
                              isSelected,
                            ),
                          ),
                        );
                      }, childCount: _enquetes.length),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text(
        'Historique',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFB794F4),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        if (_enquetes.isNotEmpty)
          IconButton(
            onPressed: _enterSelectionMode,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.checklist, color: Colors.white, size: 20),
            ),
          ),
        IconButton(
          onPressed: _deleteAll,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_sweep,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      title: Text(
        '${_selectedIds.length} sélectionné(s)',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFB794F4),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: _exitSelectionMode,
        icon: const Icon(Icons.close, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: _deleteSelected,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsCard(int repondues, int enAttente) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB794F4), Color(0xFFD4B8FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.forum_outlined, '${_enquetes.length}', 'Total'),
          Container(width: 1, height: 35, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(Icons.check_circle_outline, '$repondues', 'Répondues'),
          Container(width: 1, height: 35, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(Icons.pending_actions, '$enAttente', 'Attente'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildEnqueteCard(
    Map<String, dynamic> enquete,
    int index,
    bool isSelected,
  ) {
    final isRepondu = enquete['statut'] == 'repondu';
    final statusColor = isRepondu
        ? const Color(0xFF81C784)
        : const Color(0xFFFFB74D);
    final statusText = isRepondu ? 'Répondu' : 'Attente';

    return Material(
      elevation: 1,
      shadowColor: const Color(0xFFB794F4).withOpacity(0.15),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB794F4).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: const Color(0xFFB794F4), width: 1.2)
              : null,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFB794F4)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          color: isSelected
                              ? const Color(0xFFB794F4)
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enquete['titre'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB794F4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                enquete['categorie'],
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB794F4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.calendar_today,
                              size: 9,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              enquete['date'],
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor, statusColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.message_outlined,
                      size: 14,
                      color: Color(0xFFB794F4),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        enquete['message'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A4A5E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showEnqueteDetails(enquete),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: Color(0xFFB794F4),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Détails',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFB794F4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 25, color: Colors.grey.shade200),
                  Expanded(
                    child: InkWell(
                      onTap: () => _deleteSingle(enquete['id'], index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Color(0xFFFF8A8A),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Supprimer',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFF8A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void _showEnqueteDetails(Map<String, dynamic> enquete) {
    final isRepondu = enquete['statut'] == 'repondu';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB794F4), Color(0xFFD4B8FF)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enquete['titre'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                Text(
                                  'Envoyée le ${enquete['dateEnvoi']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8A8A9E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isRepondu
                                    ? [
                                        const Color(0xFF81C784),
                                        const Color(0xFFA5D6A5),
                                      ]
                                    : [
                                        const Color(0xFFFFB74D),
                                        const Color(0xFFFFD699),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              isRepondu ? 'Répondu' : 'Attente',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB794F4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          enquete['categorie'],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB794F4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Votre message',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F4FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          enquete['message'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A4A5E),
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (isRepondu) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Réponse',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FFF0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF81C784).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF81C784,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.support_agent,
                                      size: 14,
                                      color: Color(0xFF81C784),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Support',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF81C784),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${enquete['dateReponse']}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                enquete['reponse'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4A4A5E),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Fermer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB794F4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) =>
            Opacity(opacity: value, child: child),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB794F4).withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 50,
                color: Color(0xFFB794F4),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune enquête',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vous n\'avez pas encore posé de questions',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9E)),
            ),
          ],
        ),
      ),
    );
  }
}

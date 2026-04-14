// screens/historique/historique_enquetes_screen.dart
import 'package:appmobile/screens/Menu/MenuApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  List<Map<String, dynamic>> _allEnquetes = [];
  List<Map<String, dynamic>> _displayedEnquetes = [];
  bool _isSelectionMode = false;
  List<String> _selectedIds = [];

  // Pagination
  int _currentPage = 1;
  int _itemsPerPage = 5;
  int _totalPages = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEnquetesFromDatabase();

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

  void _loadEnquetesFromDatabase() {
    _allEnquetes = [
      {
        'id': '100',
        'titre': 'Enquête satisfaction complète - Mars 2026',
        'message':
            'Enquête détaillée sur la satisfaction client avec plusieurs questions',
        'reponse': 'Merci pour votre participation complète.',
        'date': '20/03/2026',
        'dateEnvoi': '20/03/2026 09:00',
        'dateReponse': '21/03/2026 15:30',
        'statut': 'repondu',
        'categorie': 'Satisfaction',
        'icon': Icons.emoji_emotions_outlined,
        'iconColor': Color(0xFF4CAF50),
        'questionsReponses': [
          {
            'question': 'Comment évaluez-vous la qualité de nos produits ?',
            'reponse': 'Très bonne qualité, je suis satisfait',
          },
          {
            'question': 'Que pensez-vous des délais de livraison ?',
            'reponse': 'Délais respectés, livraison rapide',
          },
          {
            'question': 'Recommanderiez-vous notre service à un ami ?',
            'reponse': 'Oui, certainement, note de 9/10',
          },
          {
            'question': 'Quelles améliorations suggérez-vous ?',
            'reponse': 'Ajouter plus de moyens de paiement',
          },
        ],
      },
      {
        'id': '26',
        'titre': 'Feedback employés – Trimestre 1',
        'message':
            'Recueillir les impressions des employés sur l\'environnement de travail',
        'reponse':
            'Merci pour votre feedback. Nous allons améliorer les conditions de travail.',
        'date': '05/03/2026',
        'dateEnvoi': '05/03/2026 10:30',
        'dateReponse': '06/03/2026 14:30',
        'statut': 'repondu',
        'categorie': 'Feedback',
        'icon': Icons.people_alt_outlined,
        'iconColor': Color(0xFF2196F3),
        'questionsReponses': [
          {
            'question':
                'Êtes-vous satisfait de votre environnement de travail ?',
            'reponse': 'Globalement satisfait, mais espace un peu petit',
          },
          {
            'question': 'Comment évaluez-vous la communication interne ?',
            'reponse': 'Bonne communication, réunions régulières',
          },
          {
            'question': 'Avez-vous besoin de formations supplémentaires ?',
            'reponse': 'Oui, formation sur les nouveaux outils',
          },
        ],
      },
      {
        'id': '25',
        'titre': 'Satisfaction clients – Mars 2026',
        'message': 'Enquête destinée à évaluer la satisfaction des clients',
        'reponse': '',
        'date': '16/03/2026',
        'dateEnvoi': '16/03/2026 09:00',
        'dateReponse': '',
        'statut': 'en_attente',
        'categorie': 'Satisfaction',
        'icon': Icons.star_border_outlined,
        'iconColor': Color(0xFFFF9800),
        'questionsReponses': [],
      },
      {
        'id': '27',
        'titre': 'Satisfaction après achat – Mars 2026',
        'message':
            'Mesurer la satisfaction des clients ayant acheté une voiture',
        'reponse': '',
        'date': '16/03/2026',
        'dateEnvoi': '16/03/2026 11:15',
        'dateReponse': '',
        'statut': 'en_attente',
        'categorie': 'Satisfaction',
        'icon': Icons.shopping_cart_outlined,
        'iconColor': Color(0xFFFF9800),
        'questionsReponses': [],
      },
      {
        'id': '21',
        'titre': 'Enquête de satisfaction',
        'message': 'Enquête de satisfaction pour test date 11 mars',
        'reponse': '',
        'date': '11/03/2026',
        'dateEnvoi': '11/03/2026 14:20',
        'dateReponse': '',
        'statut': 'en_attente',
        'categorie': 'Satisfaction',
        'icon': Icons.thumb_up_alt_outlined,
        'iconColor': Color(0xFFFF9800),
        'questionsReponses': [],
      },
      {
        'id': '19',
        'titre': 'Enquête API',
        'message': 'Pour test API',
        'reponse': '',
        'date': '09/03/2026',
        'dateEnvoi': '09/03/2026 08:45',
        'dateReponse': '',
        'statut': 'en_attente',
        'categorie': 'Technique',
        'icon': Icons.api_outlined,
        'iconColor': Color(0xFF9C27B0),
        'questionsReponses': [],
      },
      {
        'id': '12',
        'titre': 'Enquête nouvelles questions',
        'message': 'Test de création de nouvelles questions',
        'reponse': '',
        'date': '09/03/2026',
        'dateEnvoi': '09/03/2026 13:00',
        'dateReponse': '',
        'statut': 'en_attente',
        'categorie': 'Questionnaire',
        'icon': Icons.quiz_outlined,
        'iconColor': Color(0xFF00BCD4),
        'questionsReponses': [],
      },
      {
        'id': '3',
        'titre': 'Évaluation nouveau produit X',
        'message': 'Sondage pour connaître l\'avis sur le produit X',
        'reponse': '',
        'date': '23/02/2026',
        'dateEnvoi': '23/02/2026 15:30',
        'dateReponse': '',
        'statut': 'en_attente',
        'categorie': 'Produit',
        'icon': Icons.new_releases_outlined,
        'iconColor': Color(0xFFE91E63),
        'questionsReponses': [],
      },
    ];

    _totalPages = (_allEnquetes.length / _itemsPerPage).ceil();
    _loadPage();
  }

  void _loadPage() {
    setState(() {
      _isLoading = true;
      final startIndex = (_currentPage - 1) * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;
      _displayedEnquetes = _allEnquetes.sublist(
        startIndex,
        endIndex > _allEnquetes.length ? _allEnquetes.length : endIndex,
      );
      _isLoading = false;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _loadPage();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _loadPage();
      });
      HapticFeedback.lightImpact();
    }
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
    HapticFeedback.selectionClick();
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.clear();
    });
    HapticFeedback.mediumImpact();
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
          _allEnquetes.removeWhere((e) => _selectedIds.contains(e['id']));
          _selectedIds.clear();
          _isSelectionMode = false;
          _totalPages = (_allEnquetes.length / _itemsPerPage).ceil();
          if (_currentPage > _totalPages && _totalPages > 0) {
            _currentPage = _totalPages;
          }
          _loadPage();
        });
        _showSnackbar(
          '${_selectedIds.length} enquête(s) supprimée(s)',
          const Color(0xFFFF6B6B),
        );
      },
    );
  }

  void _deleteSingle(String id, int index) {
    _showDeleteDialog(
      title: 'Supprimer',
      content: 'Supprimer cette enquête ?',
      onConfirm: () {
        setState(() {
          _allEnquetes.removeWhere((e) => e['id'] == id);
          _totalPages = (_allEnquetes.length / _itemsPerPage).ceil();
          if (_currentPage > _totalPages && _totalPages > 0) {
            _currentPage = _totalPages;
          }
          _loadPage();
        });
        _showSnackbar('Enquête supprimée', const Color(0xFFFF6B6B));
      },
    );
  }

  void _deleteAll() {
    if (_allEnquetes.isEmpty) {
      _showSnackbar('Aucune enquête à supprimer', const Color(0xFFFF6B6B));
      return;
    }
    _showDeleteDialog(
      title: 'Supprimer tout',
      content: 'Supprimer tout l\'historique ? Action irréversible.',
      onConfirm: () {
        setState(() {
          _allEnquetes.clear();
          _displayedEnquetes.clear();
          _currentPage = 1;
          _totalPages = 1;
        });
        _showSnackbar(
          'Toutes les enquêtes supprimées',
          const Color(0xFFFF6B6B),
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
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Color(0xFF8A8A9E)),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
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
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final repondues = _allEnquetes
        .where((e) => e['statut'] == 'repondu')
        .length;
    final enAttente = _allEnquetes.length - repondues;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _allEnquetes.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  setState(() => _loadEnquetesFromDatabase());
                },
                color: const Color(0xFFB794F4),
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildStatsCard(repondues, enAttente),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 8)),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: _isLoading
                                ? const SliverFillRemaining(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFFB794F4),
                                            ),
                                      ),
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final enquete = _displayedEnquetes[index];
                                      final isSelected = _selectedIds.contains(
                                        enquete['id'],
                                      );
                                      return SlideTransition(
                                        position: _slideAnimation,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: _buildEnqueteCard(
                                            enquete,
                                            index,
                                            isSelected,
                                          ),
                                        ),
                                      );
                                    }, childCount: _displayedEnquetes.length),
                                  ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        ],
                      ),
                    ),
                    if (_totalPages > 1) _buildPagination(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $_currentPage sur $_totalPages',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A8A9E),
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _currentPage > 1
                          ? Color(0xFFB794F4).withOpacity(0.2)
                          : Colors.transparent,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _previousPage,
                  icon: Icon(Icons.chevron_left),
                  color: _currentPage > 1
                      ? const Color(0xFFB794F4)
                      : Colors.grey.shade300,
                  iconSize: 24,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB794F4), Color(0xFFD4B8FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$_currentPage',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _currentPage < _totalPages
                          ? Color(0xFFB794F4).withOpacity(0.2)
                          : Colors.transparent,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _nextPage,
                  icon: const Icon(Icons.chevron_right),
                  color: _currentPage < _totalPages
                      ? const Color(0xFFB794F4)
                      : Colors.grey.shade300,
                  iconSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text(
        'Mes enquêtes',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: const Color(0xFFB794F4),
      elevation: 0,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        if (_allEnquetes.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _enterSelectionMode,
              icon: const Icon(Icons.checklist_rounded, color: Colors.white),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _deleteAll,
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      title: Text(
        '${_selectedIds.length} sélectionné${_selectedIds.length > 1 ? 's' : ''}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFB794F4),
      elevation: 0,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: _exitSelectionMode,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _deleteSelected,
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(int repondues, int enAttente) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFB794F4), const Color(0xFF9B7BDF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.forum_rounded,
            '${_allEnquetes.length}',
            'Total',
            Colors.white,
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            Icons.check_circle_rounded,
            '$repondues',
            'Répondues',
            Colors.white,
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            Icons.pending_rounded,
            '$enAttente',
            'Attente',
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
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
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
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
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF9800);
    final statusText = isRepondu ? 'Répondu ✓' : 'En attente ⏳';
    final hasMultipleQuestions =
        enquete['questionsReponses'] != null &&
        enquete['questionsReponses'].isNotEmpty;
    final categoryIcon = enquete['icon'] ?? Icons.article_outlined;
    final categoryColor = enquete['iconColor'] ?? const Color(0xFFB794F4);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Opacity(opacity: value, child: child),
      ),
      child: Material(
        elevation: isSelected ? 4 : 2,
        shadowColor: const Color(0xFFB794F4).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFB794F4).withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: const Color(0xFFB794F4), width: 2)
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    if (_isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
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
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor.withOpacity(0.2),
                            categoryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(categoryIcon, size: 24, color: categoryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  enquete['titre'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasMultipleQuestions)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFB794F4,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.quiz_rounded,
                                        size: 10,
                                        color: Color(0xFFB794F4),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${enquete['questionsReponses'].length}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFB794F4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.category_rounded,
                                      size: 10,
                                      color: categoryColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      enquete['categorie'],
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: categoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 10,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                enquete['date'],
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
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
                          colors: [statusColor, statusColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7FD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.message_rounded,
                        size: 14,
                        color: const Color(0xFFB794F4).withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          enquete['message'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B6B7E),
                            fontWeight: FontWeight.w500,
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showEnqueteDetails(enquete),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasMultipleQuestions
                                    ? Icons.quiz_rounded
                                    : Icons.visibility_rounded,
                                size: 16,
                                color: const Color(0xFFB794F4),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                hasMultipleQuestions
                                    ? 'Voir détails'
                                    : 'Consulter',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB794F4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _deleteSingle(enquete['id'], index),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: const Color(0xFFFF6B6B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Supprimer',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ).withOpacity(0.9),
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
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnqueteDetails(Map<String, dynamic> enquete) {
    final isRepondu = enquete['statut'] == 'repondu';
    final hasMultipleQuestions =
        enquete['questionsReponses'] != null &&
        enquete['questionsReponses'].isNotEmpty;
    final categoryIcon = enquete['icon'] ?? Icons.article_outlined;
    final categoryColor = enquete['iconColor'] ?? const Color(0xFFB794F4);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: hasMultipleQuestions ? 0.85 : 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
              const SizedBox(height: 8),
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  categoryColor,
                                  categoryColor.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              categoryIcon,
                              color: Colors.white,
                              size: 24,
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
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Envoyée le ${enquete['dateEnvoi']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8A8A9E),
                                    fontWeight: FontWeight.w500,
                                  ),
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
                              gradient: LinearGradient(
                                colors: isRepondu
                                    ? [Color(0xFF4CAF50), Color(0xFF81C784)]
                                    : [Color(0xFFFF9800), Color(0xFFFFB74D)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isRepondu
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFFFF9800))
                                          .withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isRepondu
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isRepondu ? 'Répondu' : 'Attente',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 14,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              enquete['categorie'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Affichage des questions et réponses
                      if (hasMultipleQuestions) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.quiz_rounded,
                                size: 20,
                                color: const Color(0xFFB794F4),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Détail du questionnaire',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB794F4,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${enquete['questionsReponses'].length} questions',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB794F4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...enquete['questionsReponses'].asMap().entries.map((
                          entry,
                        ) {
                          final idx = entry.key;
                          final qr = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F7FD),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFB794F4).withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFB794F4),
                                            Color(0xFFD4B8FF),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${idx + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        qr['question'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A2E),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isRepondu && qr['reponse'].isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF4CAF50,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.reply_rounded,
                                          size: 14,
                                          color: Color(0xFF4CAF50),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          qr['reponse'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B6B7E),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.message_rounded,
                                size: 20,
                                color: Color(0xFFB794F4),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Message',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F7FD),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFB794F4).withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            enquete['message'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B6B7E),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],

                      if (isRepondu && !hasMultipleQuestions) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.support_agent_rounded,
                                size: 20,
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Réponse du support',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF4CAF50).withOpacity(0.05),
                                const Color(0xFF81C784).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF4CAF50,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.support_agent_rounded,
                                      size: 14,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Support client',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    enquete['dateReponse'] ?? 'Date inconnue',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                enquete['reponse'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B6B7E),
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
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text(
                            'Fermer',
                            style: TextStyle(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB794F4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) =>
            Opacity(opacity: value, child: child),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB794F4), Color(0xFFD4B8FF)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB794F4).withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.forum_rounded,
                size: 48,
                color: Colors.white,
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
              'Vous n\'avez pas encore participé à des enquêtes',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9E)),
            ),
          ],
        ),
      ),
    );
  }
}

// screens/reclamation/reclamation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Modèle de données pour les réclamations
enum ReclamationStatut {
  enAttente,
  enCours,
  enDiagnostic,
  resolu,
  rejete;

  String get label {
    switch (this) {
      case ReclamationStatut.enAttente:
        return 'En attente';
      case ReclamationStatut.enCours:
        return 'En cours';
      case ReclamationStatut.enDiagnostic:
        return 'Diagnostic';
      case ReclamationStatut.resolu:
        return 'Résolu';
      case ReclamationStatut.rejete:
        return 'Rejeté';
    }
  }

  Color get color {
    switch (this) {
      case ReclamationStatut.enAttente:
        return Color(0xFFFF9800);
      case ReclamationStatut.enCours:
        return Color(0xFF2196F3);
      case ReclamationStatut.enDiagnostic:
        return Color(0xFF9C27B0);
      case ReclamationStatut.resolu:
        return Color(0xFF4CAF50);
      case ReclamationStatut.rejete:
        return Color(0xFFF44336);
    }
  }

  IconData get icon {
    switch (this) {
      case ReclamationStatut.enAttente:
        return Icons.pending_rounded;
      case ReclamationStatut.enCours:
        return Icons.engineering_rounded;
      case ReclamationStatut.enDiagnostic:
        return Icons.science_rounded;
      case ReclamationStatut.resolu:
        return Icons.check_circle_rounded;
      case ReclamationStatut.rejete:
        return Icons.cancel_rounded;
    }
  }
}

enum GraviteIA {
  leger,
  moyen,
  eleve,
  critique;

  String get label {
    switch (this) {
      case GraviteIA.leger:
        return 'Léger';
      case GraviteIA.moyen:
        return 'Moyen';
      case GraviteIA.eleve:
        return 'Élevé';
      case GraviteIA.critique:
        return 'Critique ⚠️';
    }
  }

  Color get color {
    switch (this) {
      case GraviteIA.leger:
        return Color(0xFF4CAF50);
      case GraviteIA.moyen:
        return Color(0xFFFF9800);
      case GraviteIA.eleve:
        return Color(0xFFFF6B6B);
      case GraviteIA.critique:
        return Color(0xFFD32F2F);
    }
  }

  int get score {
    switch (this) {
      case GraviteIA.leger:
        return 25;
      case GraviteIA.moyen:
        return 50;
      case GraviteIA.eleve:
        return 75;
      case GraviteIA.critique:
        return 100;
    }
  }
}

class AnalyseIA {
  final String problemDetected;
  final double confiance;
  final List<String> recommandations;
  final List<String> piecesDetectees;
  final double tempsEstime;
  final double coutEstime;

  AnalyseIA({
    required this.problemDetected,
    required this.confiance,
    required this.recommandations,
    required this.piecesDetectees,
    required this.tempsEstime,
    required this.coutEstime,
  });
}

class StatusHistory {
  final DateTime date;
  final String action;
  final ReclamationStatut statut;

  StatusHistory(this.date, this.action, this.statut);
}

class Reclamation {
  final String id;
  String titre;
  String description;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String voiture;
  final String immatriculation;
  final DateTime dateCreation;
  ReclamationStatut statut;
  final GraviteIA gravite;
  final List<String> imageUrls;
  final AnalyseIA analyseIA;
  final List<StatusHistory> historiqueStatus;
  String? commentaireReponse;

  Reclamation({
    required this.id,
    required this.titre,
    required this.description,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.voiture,
    required this.immatriculation,
    required this.dateCreation,
    required this.statut,
    required this.gravite,
    required this.imageUrls,
    required this.analyseIA,
    required this.historiqueStatus,
    this.commentaireReponse,
  });
}

class ReclamationScreen extends StatefulWidget {
  const ReclamationScreen({super.key});

  @override
  State<ReclamationScreen> createState() => _ReclamationScreenState();
}

class _ReclamationScreenState extends State<ReclamationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Reclamation> _allReclamations = [];
  List<Reclamation> _filteredReclamations = [];
  List<Reclamation> _displayedReclamations = [];
  bool _isSelectionMode = false;
  List<String> _selectedIds = [];

  // Filtres
  String _selectedStatus = 'Tous';
  String _selectedGravite = 'Tous';
  String _searchQuery = '';
  bool _showFilters = false;

  // Pagination
  int _currentPage = 1;
  int _itemsPerPage = 5;
  int _totalPages = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReclamations();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  void _loadReclamations() {
    _allReclamations = [
      Reclamation(
        id: 'R001',
        titre: 'Problème moteur - Bruit anormal',
        description:
            'La voiture émet un bruit métallique au démarrage et perd de la puissance. Le voyant moteur est allumé.',
        clientName: 'Jean Dupont',
        clientEmail: 'jean.dupont@email.com',
        clientPhone: '+33 6 12 34 56 78',
        voiture: 'Renault Clio V - 2023',
        immatriculation: 'AB-123-CD',
        dateCreation: DateTime(2026, 3, 15, 10, 30),
        statut: ReclamationStatut.enCours,
        gravite: GraviteIA.critique,
        imageUrls: [
          'https://images.unsplash.com/photo-1622445275463-afa1ab738dce?w=400',
          'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=400',
        ],
        analyseIA: AnalyseIA(
          problemDetected: 'Usure des segments de piston + Soupape défectueuse',
          confiance: 0.92,
          recommandations: [
            'Remplacer les segments de piston',
            'Vérifier et remplacer la soupape d\'admission',
            'Effectuer une vidange moteur complète',
            'Contrôler la compression des cylindres',
          ],
          piecesDetectees: [
            'Segments de piston',
            'Soupape d\'admission',
            'Joint de culasse',
            'Bougies',
          ],
          tempsEstime: 8.5,
          coutEstime: 1250,
        ),
        historiqueStatus: [
          StatusHistory(
            DateTime(2026, 3, 15, 10, 30),
            'Réclamation créée',
            ReclamationStatut.enAttente,
          ),
          StatusHistory(
            DateTime(2026, 3, 16, 9, 0),
            'Prise en charge par l\'équipe technique',
            ReclamationStatut.enCours,
          ),
        ],
      ),
      Reclamation(
        id: 'R002',
        titre: 'Problème freins - Bruit de grincement',
        description:
            'Les freins grincent fortement lors du freinage, surtout à basse vitesse. Vibrations dans la pédale.',
        clientName: 'Marie Martin',
        clientEmail: 'marie.martin@email.com',
        clientPhone: '+33 6 98 76 54 32',
        voiture: 'Peugeot 208 - 2024',
        immatriculation: 'XY-789-ZW',
        dateCreation: DateTime(2026, 3, 10, 14, 20),
        statut: ReclamationStatut.resolu,
        gravite: GraviteIA.moyen,
        imageUrls: [
          'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=400',
        ],
        analyseIA: AnalyseIA(
          problemDetected: 'Plaquettes de frein usées + Disques voilés',
          confiance: 0.88,
          recommandations: [
            'Remplacer les plaquettes de frein avant et arrière',
            'Rectifier ou remplacer les disques de frein',
            'Contrôler le niveau de liquide de frein',
            'Purger le circuit de freinage',
          ],
          piecesDetectees: [
            'Plaquettes de frein',
            'Disques de frein',
            'Liquide de frein',
          ],
          tempsEstime: 3.5,
          coutEstime: 450,
        ),
        historiqueStatus: [
          StatusHistory(
            DateTime(2026, 3, 10, 14, 20),
            'Réclamation créée',
            ReclamationStatut.enAttente,
          ),
          StatusHistory(
            DateTime(2026, 3, 11, 8, 30),
            'Diagnostic en cours',
            ReclamationStatut.enDiagnostic,
          ),
          StatusHistory(
            DateTime(2026, 3, 12, 10, 0),
            'Réparation en cours',
            ReclamationStatut.enCours,
          ),
          StatusHistory(
            DateTime(2026, 3, 14, 16, 30),
            'Réparation terminée',
            ReclamationStatut.resolu,
          ),
        ],
        commentaireReponse:
            'Merci pour votre confiance. Les freins ont été entièrement remplacés et testés.',
      ),
      Reclamation(
        id: 'R003',
        titre: 'Climatisation défectueuse',
        description:
            'La climatisation ne souffle plus d\'air froid, même à pleine puissance. Odeur désagréable.',
        clientName: 'Pierre Durand',
        clientEmail: 'pierre.durand@email.com',
        clientPhone: '+33 6 45 67 89 01',
        voiture: 'Citroën C3 - 2022',
        immatriculation: 'CD-456-EF',
        dateCreation: DateTime(2026, 3, 18, 11, 45),
        statut: ReclamationStatut.enDiagnostic,
        gravite: GraviteIA.leger,
        imageUrls: [
          'https://images.unsplash.com/photo-1603988492906-4fb0fb251cf8?w=400',
        ],
        analyseIA: AnalyseIA(
          problemDetected: 'Manque de gaz réfrigérant + Compresseur faible',
          confiance: 0.75,
          recommandations: [
            'Recharger le circuit de climatisation',
            'Vérifier les joints d\'étanchéité',
            'Contrôler le compresseur',
            'Nettoyer l\'évaporateur',
          ],
          piecesDetectees: [
            'Gaz réfrigérant',
            'Joint torique',
            'Filtre habitacle',
          ],
          tempsEstime: 2.5,
          coutEstime: 180,
        ),
        historiqueStatus: [
          StatusHistory(
            DateTime(2026, 3, 18, 11, 45),
            'Réclamation créée',
            ReclamationStatut.enAttente,
          ),
          StatusHistory(
            DateTime(2026, 3, 19, 8, 30),
            'Diagnostic en cours',
            ReclamationStatut.enDiagnostic,
          ),
        ],
      ),
      Reclamation(
        id: 'R004',
        titre: 'Problème électrique - Voyants allumés',
        description:
            'Plusieurs voyants au tableau de bord restent allumés (ABS, ESP, moteur). Perte de puissance intermittente.',
        clientName: 'Sophie Bernard',
        clientEmail: 'sophie.bernard@email.com',
        clientPhone: '+33 6 23 45 67 89',
        voiture: 'Tesla Model 3 - 2024',
        immatriculation: 'EL-987-MO',
        dateCreation: DateTime(2026, 3, 5, 9, 15),
        statut: ReclamationStatut.enAttente,
        gravite: GraviteIA.eleve,
        imageUrls: [
          'https://images.unsplash.com/photo-1551918120-9739cb430c6d?w=400',
          'https://images.unsplash.com/photo-1625047509168-a7026f36de04?w=400',
        ],
        analyseIA: AnalyseIA(
          problemDetected:
              'Problème de faisceau électrique + Calculateur défectueux',
          confiance: 0.85,
          recommandations: [
            'Diagnostic complet du faisceau électrique',
            'Vérification du calculateur moteur',
            'Test des capteurs ABS et ESP',
            'Mise à jour du logiciel embarqué',
          ],
          piecesDetectees: [
            'Faisceau électrique',
            'Calculateur',
            'Capteurs ABS',
            'Batterie',
          ],
          tempsEstime: 6.0,
          coutEstime: 890,
        ),
        historiqueStatus: [
          StatusHistory(
            DateTime(2026, 3, 5, 9, 15),
            'Réclamation créée',
            ReclamationStatut.enAttente,
          ),
        ],
      ),
      Reclamation(
        id: 'R005',
        titre: 'Fuite d\'huile moteur',
        description:
            'Fuite d\'huile importante sous le véhicule. Niveau d\'huile descend rapidement.',
        clientName: 'Lucas Petit',
        clientEmail: 'lucas.petit@email.com',
        clientPhone: '+33 6 34 56 78 90',
        voiture: 'Volkswagen Golf 8 - 2023',
        immatriculation: 'VW-456-GT',
        dateCreation: DateTime(2026, 3, 12, 15, 0),
        statut: ReclamationStatut.enCours,
        gravite: GraviteIA.critique,
        imageUrls: [
          'https://images.unsplash.com/photo-1632149872165-d6b43c6c5fbc?w=400',
        ],
        analyseIA: AnalyseIA(
          problemDetected: 'Joint de culasse défectueux + Fuite turbo',
          confiance: 0.89,
          recommandations: [
            'Remplacer le joint de culasse',
            'Contrôler le turbo et ses durites',
            'Nettoyer le circuit d\'huile',
            'Effectuer une vidange complète',
          ],
          piecesDetectees: [
            'Joint de culasse',
            'Turbo',
            'Durites d\'huile',
            'Filtre à huile',
          ],
          tempsEstime: 10.0,
          coutEstime: 1650,
        ),
        historiqueStatus: [
          StatusHistory(
            DateTime(2026, 3, 12, 15, 0),
            'Réclamation créée',
            ReclamationStatut.enAttente,
          ),
          StatusHistory(
            DateTime(2026, 3, 13, 9, 30),
            'Prise en charge urgente',
            ReclamationStatut.enCours,
          ),
        ],
      ),
      Reclamation(
        id: 'R006',
        titre: 'Suspension bruyante',
        description:
            'Bruit de claquement à l\'avant gauche quand je passe sur des bosses.',
        clientName: 'Emma Richard',
        clientEmail: 'emma.richard@email.com',
        clientPhone: '+33 6 45 67 89 01',
        voiture: 'Ford Focus - 2022',
        immatriculation: 'FD-789-HJ',
        dateCreation: DateTime(2026, 3, 20, 10, 0),
        statut: ReclamationStatut.enDiagnostic,
        gravite: GraviteIA.moyen,
        imageUrls: [
          'https://images.unsplash.com/photo-1568605117036-5fe5e7fa0ac7?w=400',
        ],
        analyseIA: AnalyseIA(
          problemDetected: 'Silent-bloc usé + Amortisseur fatigué',
          confiance: 0.82,
          recommandations: [
            'Remplacer les silent-blocs de suspension',
            'Changer l\'amortisseur avant gauche',
            'Contrôler la géométrie des roues',
          ],
          piecesDetectees: [
            'Silent-bloc',
            'Amortisseur',
            'Biellette de barre stab',
          ],
          tempsEstime: 4.0,
          coutEstime: 520,
        ),
        historiqueStatus: [
          StatusHistory(
            DateTime(2026, 3, 20, 10, 0),
            'Réclamation créée',
            ReclamationStatut.enAttente,
          ),
          StatusHistory(
            DateTime(2026, 3, 21, 8, 0),
            'Diagnostic en cours',
            ReclamationStatut.enDiagnostic,
          ),
        ],
      ),
    ];

    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredReclamations = _allReclamations.where((r) {
        if (_selectedStatus != 'Tous' && r.statut.label != _selectedStatus) {
          return false;
        }
        if (_selectedGravite != 'Tous' && r.gravite.label != _selectedGravite) {
          return false;
        }
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          return r.titre.toLowerCase().contains(query) ||
              r.description.toLowerCase().contains(query) ||
              r.clientName.toLowerCase().contains(query) ||
              r.immatriculation.toLowerCase().contains(query) ||
              r.voiture.toLowerCase().contains(query);
        }
        return true;
      }).toList();

      _totalPages = (_filteredReclamations.length / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;
      if (_currentPage > _totalPages) _currentPage = _totalPages;
      _loadPage();
    });
  }

  void _loadPage() {
    setState(() {
      _isLoading = true;
      final startIndex = (_currentPage - 1) * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;
      _displayedReclamations = _filteredReclamations.sublist(
        startIndex,
        endIndex > _filteredReclamations.length
            ? _filteredReclamations.length
            : endIndex,
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
      content: 'Supprimer ${_selectedIds.length} réclamation(s) ?',
      onConfirm: () {
        setState(() {
          _allReclamations.removeWhere((e) => _selectedIds.contains(e.id));
          _selectedIds.clear();
          _isSelectionMode = false;
          _applyFilters();
        });
        _showSnackbar(
          '${_selectedIds.length} réclamation(s) supprimée(s)',
          const Color(0xFFFF6B6B),
        );
      },
    );
  }

  void _deleteSingle(String id) {
    _showDeleteDialog(
      title: 'Supprimer',
      content: 'Supprimer cette réclamation ?',
      onConfirm: () {
        setState(() {
          _allReclamations.removeWhere((e) => e.id == id);
          _applyFilters();
        });
        _showSnackbar('Réclamation supprimée', const Color(0xFFFF6B6B));
      },
    );
  }

  void _modifierReclamation(Reclamation reclamation) {
    final titreController = TextEditingController(text: reclamation.titre);
    final descriptionController = TextEditingController(
      text: reclamation.description,
    );
    ReclamationStatut newStatut = reclamation.statut;
    String? commentaire = reclamation.commentaireReponse;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('Modifier la réclamation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titreController,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ReclamationStatut>(
                    value: newStatut,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                    ),
                    items: ReclamationStatut.values.map((statut) {
                      return DropdownMenuItem(
                        value: statut,
                        child: Row(
                          children: [
                            Icon(statut.icon, size: 18, color: statut.color),
                            const SizedBox(width: 8),
                            Text(statut.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        newStatut = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(text: commentaire),
                    decoration: const InputDecoration(
                      labelText: 'Commentaire de réponse (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (value) => commentaire = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final index = _allReclamations.indexWhere(
                      (r) => r.id == reclamation.id,
                    );
                    if (index != -1) {
                      _allReclamations[index].titre = titreController.text;
                      _allReclamations[index].description =
                          descriptionController.text;
                      _allReclamations[index].statut = newStatut;
                      if (commentaire?.isNotEmpty == true) {
                        _allReclamations[index].commentaireReponse =
                            commentaire;
                      }
                      _allReclamations[index].historiqueStatus.add(
                        StatusHistory(
                          DateTime.now(),
                          'Modification manuelle',
                          newStatut,
                        ),
                      );
                    }
                    _applyFilters();
                  });
                  Navigator.pop(context);
                  _showSnackbar('Réclamation modifiée', Colors.green);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB794F4),
                ),
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
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
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
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

  double get _graviteTotale {
    if (_allReclamations.isEmpty) return 0;
    final total = _allReclamations.fold<int>(
      0,
      (sum, r) => sum + r.gravite.score,
    );
    return total / _allReclamations.length;
  }

  Map<ReclamationStatut, int> get _statutsCount {
    final map = <ReclamationStatut, int>{};
    for (final statut in ReclamationStatut.values) {
      map[statut] = _allReclamations.where((r) => r.statut == statut).length;
    }
    return map;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statutsCount = _statutsCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchAndFilters(),
            if (_showFilters) _buildFilterChips(),
            Expanded(
              child: _allReclamations.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(milliseconds: 500));
                        setState(() => _loadReclamations());
                      },
                      color: const Color(0xFFB794F4),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildStatsCard(statutsCount),
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
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final reclamation =
                                            _displayedReclamations[index];
                                        final isSelected = _selectedIds
                                            .contains(reclamation.id);
                                        return SlideTransition(
                                          position: _slideAnimation,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: _buildReclamationCard(
                                              reclamation,
                                              isSelected,
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: _displayedReclamations.length,
                                    ),
                                  ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        ],
                      ),
                    ),
            ),
            if (_totalPages > 1) _buildPagination(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReclamationDialog(),
        backgroundColor: const Color(0xFFB794F4),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher une réclamation...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFB794F4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _showFilters ? const Color(0xFFB794F4) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              icon: Icon(
                Icons.filter_list_rounded,
                color: _showFilters ? Colors.white : const Color(0xFFB794F4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Tous'),
            selected: _selectedStatus == 'Tous',
            onSelected: (selected) {
              setState(() {
                _selectedStatus = 'Tous';
                _applyFilters();
              });
            },
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFFB794F4).withOpacity(0.2),
            checkmarkColor: const Color(0xFFB794F4),
          ),
          const SizedBox(width: 8),
          ...ReclamationStatut.values.map((statut) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(statut.label),
                selected: _selectedStatus == statut.label,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? statut.label : 'Tous';
                    _applyFilters();
                  });
                },
                avatar: Icon(statut.icon, size: 16, color: statut.color),
                backgroundColor: Colors.white,
                selectedColor: statut.color.withOpacity(0.2),
                checkmarkColor: statut.color,
              ),
            );
          }).toList(),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: VerticalDivider(),
          ),
          ...GraviteIA.values.map((gravite) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(gravite.label),
                selected: _selectedGravite == gravite.label,
                onSelected: (selected) {
                  setState(() {
                    _selectedGravite = selected ? gravite.label : 'Tous';
                    _applyFilters();
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: gravite.color.withOpacity(0.2),
                checkmarkColor: gravite.color,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<ReclamationStatut, int> statutsCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB794F4), Color(0xFF9B7BDF)],
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.assignment_rounded,
                '${_allReclamations.length}',
                'Total',
                Colors.white,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatItem(
                Icons.warning_rounded,
                '${_graviteTotale.toInt()}%',
                'Gravité totale',
                Colors.white,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatItem(
                Icons.timeline_rounded,
                '${statutsCount[ReclamationStatut.resolu] ?? 0}/${_allReclamations.length}',
                'Résolues',
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReclamationStatut.values.map((statut) {
              final count = statutsCount[statut] ?? 0;
              if (count == 0) return const SizedBox();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statut.icon, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${statut.label}: $count',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ],
                ),
              );
            }).toList(),
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
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
      ],
    );
  }

  Widget _buildReclamationCard(Reclamation reclamation, bool isSelected) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    if (_isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => _toggleSelection(reclamation.id),
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
                      ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            reclamation.gravite.color.withOpacity(0.2),
                            reclamation.gravite.color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.car_repair_rounded,
                        size: 24,
                        color: reclamation.gravite.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reclamation.titre,
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
                              Icon(
                                Icons.directions_car_rounded,
                                size: 10,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  reclamation.voiture,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.badge_rounded,
                                size: 10,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reclamation.immatriculation,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                reclamation.statut.color,
                                reclamation.statut.color.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                reclamation.statut.icon,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reclamation.statut.label,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: reclamation.gravite.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            reclamation.gravite.label,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: reclamation.gravite.color,
                            ),
                          ),
                        ),
                      ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.description_rounded,
                            size: 12,
                            color: Color(0xFFB794F4),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              reclamation.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B6B7E),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.analytics_rounded,
                            size: 12,
                            color: Color(0xFFB794F4),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'IA: ${reclamation.analyseIA.problemDetected} (${(reclamation.analyseIA.confiance * 100).toInt()}% confiance)',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFB794F4),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                        onTap: () => _showReclamationDetails(reclamation),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.visibility_rounded,
                                size: 16,
                                color: Color(0xFFB794F4),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Détails',
                                style: TextStyle(
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
                        onTap: () => _modifierReclamation(reclamation),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: Color(0xFF2196F3),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Modifier',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2196F3),
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
                        onTap: () => _deleteSingle(reclamation.id),
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(reclamation.dateCreation),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    if (reclamation.imageUrls.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.image_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${reclamation.imageUrls.length}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReclamationDetails(Reclamation reclamation) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
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
                                  reclamation.gravite.color,
                                  reclamation.gravite.color.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.car_repair_rounded,
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
                                  reclamation.titre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${reclamation.voiture} - ${reclamation.immatriculation}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              icon: reclamation.statut.icon,
                              label: reclamation.statut.label,
                              color: reclamation.statut.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.warning_rounded,
                              label: reclamation.gravite.label,
                              color: reclamation.gravite.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.analytics_rounded,
                              label:
                                  '${(reclamation.analyseIA.confiance * 100).toInt()}%',
                              color: const Color(0xFFB794F4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (reclamation.imageUrls.isNotEmpty) ...[
                        const Text(
                          'Photos du véhicule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: reclamation.imageUrls.length,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    reclamation.imageUrls[index],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F7FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reclamation.description,
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Analyse IA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFB794F4).withOpacity(0.1),
                              const Color(0xFFD4B8FF).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFB794F4).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.bug_report_rounded,
                                  size: 16,
                                  color: Color(0xFFB794F4),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    reclamation.analyseIA.problemDetected,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Pièces détectées:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: reclamation.analyseIA.piecesDetectees
                                  .map(
                                    (piece) => Chip(
                                      label: Text(
                                        piece,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: const Color(
                                          0xFFB794F4,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Recommandations:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...reclamation.analyseIA.recommandations.map(
                              (rec) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 12,
                                      color: Color(0xFF4CAF50),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        rec,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.timer_rounded,
                                          size: 16,
                                          color: Color(0xFFFF9800),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${reclamation.analyseIA.tempsEstime}h',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Temps estimé',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.euro_rounded,
                                          size: 16,
                                          color: Color(0xFF4CAF50),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${reclamation.analyseIA.coutEstime}€',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Coût estimé',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Historique',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...reclamation.historiqueStatus
                          .map(
                            (history) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F7FD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: history.statut.color.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      history.statut.icon,
                                      size: 14,
                                      color: history.statut.color,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          history.action,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          dateFormat.format(history.date),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: history.statut.color.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      history.statut.label,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: history.statut.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      if (reclamation.commentaireReponse != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.support_agent_rounded,
                                    size: 16,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Réponse du support',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(reclamation.commentaireReponse!),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Fermer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB794F4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9E)),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _previousPage,
                icon: const Icon(Icons.chevron_left),
                color: _currentPage > 1
                    ? const Color(0xFFB794F4)
                    : Colors.grey.shade300,
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
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextPage,
                icon: const Icon(Icons.chevron_right),
                color: _currentPage < _totalPages
                    ? const Color(0xFFB794F4)
                    : Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              Icons.car_crash_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune réclamation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vous n\'avez pas encore de réclamation',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9E)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text(
        'Mes réclamations',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        if (_allReclamations.isNotEmpty)
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
            onPressed: () {
              if (_allReclamations.isEmpty) {
                _showSnackbar(
                  'Aucune réclamation à supprimer',
                  const Color(0xFFFF6B6B),
                );
              } else {
                _showDeleteDialog(
                  title: 'Supprimer tout',
                  content:
                      'Supprimer toutes les réclamations ? Action irréversible.',
                  onConfirm: () {
                    setState(() {
                      _allReclamations.clear();
                      _applyFilters();
                    });
                    _showSnackbar(
                      'Toutes les réclamations supprimées',
                      const Color(0xFFFF6B6B),
                    );
                  },
                );
              }
            },
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
          ),
        ),
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

  void _showAddReclamationDialog() {
    _showSnackbar(
      'Nouvelle réclamation - Fonctionnalité à implémenter',
      const Color(0xFFB794F4),
    );
  }
}

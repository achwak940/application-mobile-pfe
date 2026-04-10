import 'package:flutter/material.dart';
import '../../services/enquete_service.dart';

class Enquete extends StatefulWidget {
  final int id;

  const Enquete({super.key, required this.id});

  @override
  State<Enquete> createState() => _EnqueteState();
}

class _EnqueteState extends State<Enquete> with TickerProviderStateMixin {
  final ApiService api = ApiService();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Map<String, dynamic>? enquete;
  bool isLoading = true;
  bool isSubmitting = false;
  Map<int, dynamic> answers = {};

  // Animations
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  final Map<int, TextEditingController> _textControllers = {};
  final Map<int, FocusNode> _focusNodes = {};

  int _answeredCount = 0;

  @override
  void initState() {
    super.initState();
    loadEnquete();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> loadEnquete() async {
    try {
      final data = await api.getEnqueteById(widget.id);
      setState(() {
        enquete = data;
        isLoading = false;
      });

      final questions = data['questions'];
      for (var q in questions) {
        if (q['type'] == 'text') {
          _textControllers[q['id']] = TextEditingController();
          _focusNodes[q['id']] = FocusNode();
        }
      }
    } catch (e) {
      debugPrint("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  void _updateProgress() {
    final questions = enquete!['questions'];
    int count = 0;
    for (var q in questions) {
      if (answers.containsKey(q['id'])) {
        count++;
      } else if (q['type'] == 'text' &&
          _textControllers[q['id']]?.text.isNotEmpty == true) {
        count++;
      }
    }
    setState(() {
      _answeredCount = count;
    });
  }

  Future<void> _submitAdventure() async {
    final questions = enquete!['questions'];
    bool allAnswered = true;
    List<String> unansweredQuestions = [];

    for (var q in questions) {
      if (!answers.containsKey(q['id']) && q['type'] != 'text') {
        allAnswered = false;
        unansweredQuestions.add(q['texte']);
      } else if (q['type'] == 'text') {
        final textValue = _textControllers[q['id']]?.text.trim();
        if (textValue == null || textValue.isEmpty) {
          allAnswered = false;
          unansweredQuestions.add(q['texte']);
        } else {
          answers[q['id']] = textValue;
        }
      }
    }

    if (!allAnswered) {
      _showIncompleteDialog(unansweredQuestions);
      return;
    }

    setState(() => isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isSubmitting = false);

    _showCompletionDialog();
  }

  void _showIncompleteDialog(List<String> unanswered) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.deepPurple.shade300,
            ),
            const SizedBox(width: 8),
            const Text('Questionnaires incomplets'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Veuillez répondre aux questions suivantes :'),
            const SizedBox(height: 12),
            ...unanswered
                .take(3)
                .map(
                  (q) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: Colors.deepPurple.shade300,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(q)),
                      ],
                    ),
                  ),
                ),
            if (unanswered.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... et ${unanswered.length - 3} autre(s)',
                  style: TextStyle(color: Colors.deepPurple.shade300),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.white,
                  Colors.deepPurple.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: 60,
                    color: Colors.deepPurple.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mission accomplie !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Merci, aventurier ! Vos réponses ont été enregistrées avec succès.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Continuer l\'aventure'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    if (enquete == null) {
      return _buildErrorScreen();
    }

    final questions = enquete!['questions'];
    final totalPages = questions.length + 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
          if (page > 0 && page <= questions.length) {
            _updateProgress();
          }
        },
        children: [
          _buildIntroPage(),
          ...questions.map((q) => _buildQuestionPage(q)),
          _buildConclusionPage(),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8F4FF),
            Colors.deepPurple.shade50,
            const Color(0xFFF3E8FF),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade200,
                          Colors.deepPurple.shade400,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Préparation de votre aventure...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.deepPurple.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF8F4FF), Colors.deepPurple.shade50],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: Colors.deepPurple.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              'Oups ! Le chemin est bloqué...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Impossible de charger cette aventure',
              style: TextStyle(color: Colors.deepPurple.shade300, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => loadEnquete(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8F4FF),
            Colors.white,
            const Color(0xFFF3E8FF),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade100,
                              Colors.deepPurple.shade200,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.shade100,
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 70,
                          color: Colors.deepPurple.shade600,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  enquete!['titre'],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade50,
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 40,
                        color: Colors.deepPurple.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        enquete!['description'] ??
                            'Une aventure extraordinaire vous attend !',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatChip(
                        Icons.flag,
                        '${enquete!['questions'].length} défis',
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.timer, '~5 min'),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.emoji_events, 'Récompense'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade400,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 10,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Commencer l\'aventure',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.deepPurple.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.deepPurple.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(Map<String, dynamic> question) {
    final progress = _answeredCount / (enquete!['questions'].length);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFF8F4FF), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 16,
                            color: Colors.deepPurple.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Défi ${_currentPage}/${enquete!['questions'].length}',
                            style: TextStyle(
                              color: Colors.deepPurple.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(_answeredCount * 100 / enquete!['questions'].length).toInt()}%',
                        style: TextStyle(
                          color: Colors.deepPurple.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.deepPurple.shade50,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade50,
                                    Colors.white,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.shade100,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getQuestionIcon(question['type']),
                                    size: 28,
                                    color: Colors.deepPurple.shade400,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      question['texte'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.shade50,
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: _buildAnswerWidget(question),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade50,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentPage > 1)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Retour'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(color: Colors.deepPurple.shade200),
                        ),
                      ),
                    ),
                  if (_currentPage > 1) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _updateProgress();
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == enquete!['questions'].length
                                ? 'Terminer'
                                : 'Suivant',
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == enquete!['questions'].length
                                ? Icons.flag
                                : Icons.arrow_forward,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getQuestionIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.edit_note;
      case 'radio':
        return Icons.radio_button_checked;
      case 'scale':
        return Icons.show_chart;
      case 'rating':
        return Icons.star_rate;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildAnswerWidget(Map<String, dynamic> q) {
    switch (q['type']) {
      case 'text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre réponse :',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textControllers[q['id']],
              focusNode: _focusNodes[q['id']],
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Écrivez votre réponse ici...',
                hintStyle: TextStyle(color: Colors.deepPurple.shade200),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.deepPurple.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.deepPurple.shade400,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F4FF),
              ),
              onChanged: (value) => _updateProgress(),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_textControllers[q['id']]?.text.length ?? 0)} caractères',
              style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade300),
            ),
          ],
        );

      case 'radio':
      case 'unique':
        return Column(
          children: (q['options'] as List).map<Widget>((opt) {
            bool isSelected = answers[q['id']] == opt['id'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  answers[q['id']] = opt['id'];
                  _updateProgress();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Colors.deepPurple.shade100,
                            Colors.deepPurple.shade50,
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected
                        ? Colors.deepPurple.shade400
                        : Colors.deepPurple.shade100,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? Colors.deepPurple.shade600
                          : Colors.deepPurple.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt['texte'],
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.deepPurple.shade800
                              : Colors.black87,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Colors.deepPurple.shade400,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case 'scale':
        int steps = q['scaleConfig']['steps'];
        double currentValue = (answers[q['id']] ?? 0).toDouble();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      size: 16,
                      color: Colors.deepPurple.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      q['scaleConfig']['minLabel'],
                      style: TextStyle(color: Colors.deepPurple.shade400),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      q['scaleConfig']['maxLabel'],
                      style: TextStyle(color: Colors.deepPurple.shade400),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.sentiment_satisfied,
                      size: 16,
                      color: Colors.deepPurple.shade400,
                    ),
                  ],
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.deepPurple.shade400,
                inactiveTrackColor: Colors.deepPurple.shade100,
                thumbColor: Colors.deepPurple.shade600,
                overlayColor: Colors.deepPurple.shade100,
              ),
              child: Slider(
                min: 0,
                max: (steps - 1).toDouble(),
                divisions: steps - 1,
                value: currentValue,
                onChanged: (value) {
                  setState(() {
                    answers[q['id']] = value;
                    _updateProgress();
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(steps, (index) {
                bool isSelected = currentValue.round() == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.deepPurple.shade400
                        : Colors.deepPurple.shade50,
                    border: Border.all(
                      color: isSelected
                          ? Colors.deepPurple.shade600
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.deepPurple.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );

      case 'rating':
        int maxStars = q['ratingConfig']['maxStars'];
        int currentRating = answers[q['id']] ?? 0;

        return Column(
          children: [
            const Text(
              'Votre évaluation :',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(maxStars, (index) {
                int star = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      answers[q['id']] = star;
                      _updateProgress();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      currentRating >= star ? Icons.star : Icons.star_border,
                      color: currentRating >= star
                          ? Colors.amber.shade600
                          : Colors.deepPurple.shade200,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            if (currentRating > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _getRatingMessage(currentRating, maxStars),
                  style: TextStyle(
                    color: Colors.deepPurple.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  String _getRatingMessage(int rating, int maxStars) {
    if (rating == maxStars) return 'Exceptionnel ! Un sans-faute !';
    if (rating >= maxStars - 1) return 'Magnifique aventure !';
    if (rating >= maxStars - 2) return 'Très bien, continuez comme ça !';
    return 'Chaque aventure est une opportunité de progresser !';
  }

  Widget _buildConclusionPage() {
    final score = (_answeredCount * 100 / enquete!['questions'].length).toInt();
    String message;
    IconData icon;
    Color iconColor;

    if (score == 100) {
      message = 'PARFAIT ! Vous êtes un véritable héros !';
      icon = Icons.emoji_events;
      iconColor = Colors.amber;
    } else if (score >= 80) {
      message = 'Excellent aventurier ! Presque parfait !';
      icon = Icons.rocket_launch;
      iconColor = Colors.deepPurple.shade400;
    } else if (score >= 60) {
      message = 'Bon voyage ! Continuez à explorer !';
      icon = Icons.explore;
      iconColor = Colors.deepPurple.shade300;
    } else {
      message = 'Chaque aventure est une nouvelle opportunité !';
      icon = Icons.auto_awesome;
      iconColor = Colors.deepPurple.shade200;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8F4FF),
            Colors.white,
            const Color(0xFFF3E8FF),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade100,
                              Colors.deepPurple.shade300,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 80, color: iconColor),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade50,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Score : $score%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Défi relevés : $_answeredCount / ${enquete!['questions'].length}',
                        style: TextStyle(color: Colors.deepPurple.shade400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _submitAdventure,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    isSubmitting ? 'Envoi en cours...' : 'Terminer l\'aventure',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

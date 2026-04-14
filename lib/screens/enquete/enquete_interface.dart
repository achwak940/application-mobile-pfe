import 'dart:async';
import 'package:appmobile/services/enquete_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class EnqueteScreen extends StatefulWidget {
  final int id;

  const EnqueteScreen({super.key, required this.id});

  @override
  State<EnqueteScreen> createState() => _EnqueteScreenState();
}

class _EnqueteScreenState extends State<EnqueteScreen>
    with TickerProviderStateMixin {
  final SurveyService service = SurveyService();
  late PageController _pageController;
  int _currentPage = 0;

  Map<String, dynamic>? enquete;
  bool isLoading = true;
  bool isSubmitting = false;
  Map<int, dynamic> answers = {};

  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  final Map<int, TextEditingController> _textControllers = {};
  final Map<int, FocusNode> _focusNodes = {};

  // Debounce timers for each question
  final Map<int, Timer?> _debounceTimers = {};

  // Track if generation is pending for each question
  final Map<int, bool> _pendingGeneration = {};

  int _answeredCount = 0;
  bool isAiGenerating = false;

  // Track questions that have already triggered generation
  final Map<int, bool> _hasTriggeredGeneration = {};

  // Store emotion and intent for each question
  final Map<int, Map<String, String>> _questionMetadata = {};

  // Prevent multiple navigations
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

    // Dispose all timers
    for (var timer in _debounceTimers.values) {
      timer?.cancel();
    }

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
      final data = await service.getEnqueteById(widget.id);
      setState(() {
        enquete = data;
        isLoading = false;
      });

      final questions = data['questions'] as List;
      for (var q in questions) {
        if (q['type'] == 'text') {
          final questionId = q['id'] as int;
          _textControllers[questionId] = TextEditingController();
          _focusNodes[questionId] = FocusNode();
          _pendingGeneration[questionId] = false;

          // Add listener with debounce
          _textControllers[questionId]!.addListener(() {
            _onAnswerChangedWithDebounce(questionId);
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  // Debounced answer change handler
  void _onAnswerChangedWithDebounce(int questionId) {
    final controller = _textControllers[questionId];
    if (controller == null) return;

    final answer = controller.text.trim();

    // Cancel existing timer for this question
    if (_debounceTimers[questionId] != null) {
      _debounceTimers[questionId]!.cancel();
      _debounceTimers[questionId] = null;
    }

    // Only proceed if we have enough characters and haven't triggered yet
    if (answer.isNotEmpty &&
        answer.length >= 3 &&
        _hasTriggeredGeneration[questionId] != true) {
      // Mark that generation is pending
      _pendingGeneration[questionId] = true;

      // Set a new timer for 1.5 seconds
      _debounceTimers[questionId] = Timer(
        const Duration(milliseconds: 1500),
        () {
          if (_pendingGeneration[questionId] == true &&
              _hasTriggeredGeneration[questionId] != true) {
            debugPrint(
              "✍️ User finished typing for question $questionId: '$answer'",
            );
            _hasTriggeredGeneration[questionId] = true;
            _pendingGeneration[questionId] = false;
            _generateNextQuestionAutomatically();
          }
          _debounceTimers[questionId] = null;
        },
      );
    } else {
      _pendingGeneration[questionId] = false;
    }

    _updateProgress();
  }

  // Manual trigger from Next button
  void _onNextButtonPressed() {
    if (_currentPage > 0 &&
        _currentPage <= (enquete?['questions'] as List).length) {
      final currentQuestionId =
          (enquete!['questions'] as List)[_currentPage - 1]['id'] as int;

      // Check if this question hasn't triggered generation yet
      if (_hasTriggeredGeneration[currentQuestionId] != true) {
        final controller = _textControllers[currentQuestionId];
        if (controller != null && controller.text.trim().length >= 3) {
          // Cancel any pending debounce
          if (_debounceTimers[currentQuestionId] != null) {
            _debounceTimers[currentQuestionId]!.cancel();
            _debounceTimers[currentQuestionId] = null;
          }

          // Trigger generation immediately
          _hasTriggeredGeneration[currentQuestionId] = true;
          _generateNextQuestionAutomatically();
        }
      }
    }

    // Navigate to next page
    _navigateToNextPage();
  }

  // Safe navigation method
  void _navigateToNextPage() {
    if (_isNavigating) return;

    final questions = enquete!['questions'] as List;
    if (_currentPage < questions.length) {
      _isNavigating = true;
      _pageController
          .nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          )
          .then((_) {
            _isNavigating = false;
          })
          .catchError((_) {
            _isNavigating = false;
          });
    } else if (_currentPage == questions.length) {
      _isNavigating = true;
      _pageController
          .nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          )
          .then((_) {
            _isNavigating = false;
          })
          .catchError((_) {
            _isNavigating = false;
          });
    }
  }

  // Generate next question with emotion analysis
  Future<void> _generateNextQuestionAutomatically() async {
    // Prevent multiple simultaneous generations
    if (isAiGenerating) {
      debugPrint("⏳ Already generating, skipping...");
      return;
    }

    if (enquete == null) {
      debugPrint("❌ Enquete is null");
      return;
    }

    debugPrint("🤖 Auto-generating next question...");
    setState(() => isAiGenerating = true);

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Analyse de votre réponse...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      // Build conversation history
      String history = _buildConversationHistory();

      // Get last answer
      final currentQuestionId =
          (enquete!['questions'] as List)[_currentPage - 1]['id'] as int;
      final lastAnswer = _textControllers[currentQuestionId]?.text.trim() ?? "";
      final currentQuestion =
          (enquete!['questions'] as List)[_currentPage - 1]['texte'];

      final theme = enquete!['titre'];

      // Call AI service with emotion analysis - returns Map
      final Map<String, dynamic> aiResponse = await service
          .generateAdaptiveQuestion(
            theme: theme,
            history: history,
            lastAnswer: lastAnswer,
          );

      // Extract values from Map - CORRECTION ICI
      final String generatedQuestion = aiResponse['question'] ?? '';
      final String emotion = aiResponse['emotion'] ?? 'neutral';
      final String intent = aiResponse['intent'] ?? 'explore';

      debugPrint("✅ Generated question: $generatedQuestion");
      debugPrint("📊 Detected emotion: $emotion");
      debugPrint("🎯 Intent: $intent");

      if (generatedQuestion.isNotEmpty && mounted) {
        // Store metadata for the new question
        final newId = DateTime.now().millisecondsSinceEpoch;
        _questionMetadata[newId] = {
          'emotion': emotion,
          'intent': intent,
          'previousQuestion': currentQuestion,
          'previousAnswer': lastAnswer,
        };

        await _addQuestionToSurvey(generatedQuestion, emotion, intent);
      }
    } catch (e) {
      debugPrint("❌ Auto-generation error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de génération: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isAiGenerating = false);
    }
  }

  // Build conversation history
  String _buildConversationHistory() {
    String history = "";
    final questions = enquete!['questions'] as List;

    for (var i = 0; i < _currentPage - 1; i++) {
      final q = questions[i];
      final qId = q['id'] as int;
      final answer = answers[qId] ?? _textControllers[qId]?.text.trim();

      if (answer != null && answer.isNotEmpty) {
        history += "Q: ${q['texte']}\nA: $answer\n\n";
      }
    }

    return history;
  }

  void _updateProgress() {
    if (enquete == null) return;

    final questions = enquete!['questions'] as List;
    int count = 0;
    for (var q in questions) {
      final qId = q['id'] as int;
      if (answers.containsKey(qId)) {
        count++;
      } else if (q['type'] == 'text' &&
          _textControllers[qId]?.text.isNotEmpty == true) {
        count++;
      }
    }
    setState(() {
      _answeredCount = count;
    });
  }

  // Add question to survey with metadata
  Future<void> _addQuestionToSurvey(
    String question,
    String emotion,
    String intent,
  ) async {
    if (enquete == null) return;

    final newId = DateTime.now().millisecondsSinceEpoch;

    final newQuestion = {
      'id': newId,
      'texte': question,
      'type': 'text',
      'isAiGenerated': true,
      'emotion': emotion,
      'intent': intent,
    };

    final oldQuestions = List<Map<String, dynamic>>.from(enquete!['questions']);
    final targetPageIndex = oldQuestions.length + 1; // +1 for intro page

    // Update state with new question
    setState(() {
      final updatedQuestions = [...oldQuestions, newQuestion];
      enquete = {...enquete!, 'questions': updatedQuestions};
      _textControllers[newId] = TextEditingController();
      _focusNodes[newId] = FocusNode();
      _pendingGeneration[newId] = false;

      // Initialize tracking for new question
      _hasTriggeredGeneration[newId] = false;

      _currentPage = targetPageIndex;

      // Add listener for the new question
      _textControllers[newId]!.addListener(() {
        _onAnswerChangedWithDebounce(newId);
      });
    });

    // Navigate to the new question after a short delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted && _pageController.hasClients) {
      await _pageController.animateToPage(
        targetPageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // Manual generation (optional)
  Future<void> generateQuestionWithAI() async {
    if (enquete == null) {
      _showErrorDialog("L'enquête n'est pas chargée");
      return;
    }

    if (isAiGenerating) {
      return;
    }

    setState(() => isAiGenerating = true);

    try {
      final theme = enquete!['titre'];
      final history = _buildConversationHistory();
      final lastAnswer =
          "Manually requested - generate a new question about $theme";

      final Map<String, dynamic> aiResponse = await service
          .generateAdaptiveQuestion(
            theme: theme,
            history: history,
            lastAnswer: lastAnswer,
          );

      final String generatedQuestion = aiResponse['question'] ?? '';
      final String emotion = aiResponse['emotion'] ?? 'neutral';
      final String intent = aiResponse['intent'] ?? 'explore';

      if (generatedQuestion.isNotEmpty && mounted) {
        await _addQuestionToSurvey(generatedQuestion, emotion, intent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✨ Nouvelle question générée ! Émotion: $emotion',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorDialog("La réponse IA est vide");
      }
    } catch (e) {
      debugPrint("❌ IA ERROR: $e");
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => isAiGenerating = false);
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Erreur de génération'),
        content: Text('Impossible de générer la question: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAdventure() async {
    if (enquete == null) return;

    final questions = enquete!['questions'] as List;
    bool allAnswered = true;
    List<String> unansweredQuestions = [];
    Map<int, dynamic> finalAnswers = {...answers};

    for (var q in questions) {
      final qId = q['id'] as int;
      if (q['type'] == 'text') {
        final textValue = _textControllers[qId]?.text.trim();
        if (textValue == null || textValue.isEmpty) {
          allAnswered = false;
          unansweredQuestions.add(q['texte']);
        } else {
          finalAnswers[qId] = textValue;
        }
      } else if (!answers.containsKey(qId)) {
        allAnswered = false;
        unansweredQuestions.add(q['texte']);
      }
    }

    if (!allAnswered) {
      _showIncompleteDialog(unansweredQuestions);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await service.submitEnqueteResponses(
        enqueteId: widget.id,
        answers: finalAnswers,
      );
      if (!mounted) return;
      setState(() => isSubmitting = false);
      _showCompletionDialog();
    } catch (e) {
      setState(() => isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi : $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
            const Text('Questions incomplètes'),
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
    if (enquete == null) return;

    final questions = enquete!['questions'] as List;
    final score = questions.isEmpty
        ? 0
        : (_answeredCount * 100 / questions.length).toInt();

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
                    score == 100 ? Icons.emoji_events : Icons.celebration,
                    size: 60,
                    color: Colors.deepPurple.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  score == 100 ? 'Parfait !' : 'Mission accomplie !',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  score == 100
                      ? 'Score parfait ! Vous êtes un véritable expert !'
                      : 'Merci, aventurier ! Vos réponses ont été enregistrées avec succès.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/profile',
                      (route) => false,
                    );
                  },
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

  // BUILD METHODS
  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingScreen();
    if (enquete == null) return _buildErrorScreen();

    final questions = enquete!['questions'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: PageView.builder(
        controller: _pageController,
        itemCount: questions.length + 2,
        onPageChanged: (int page) {
          setState(() => _currentPage = page);
          if (page > 0 && page <= questions.length) {
            _updateProgress();
          }
        },
        itemBuilder: (context, index) {
          if (index == 0) return _buildIntroPage();
          if (index == questions.length + 1) return _buildConclusionPage();
          return _buildQuestionPage(questions[index - 1]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isAiGenerating ? null : generateQuestionWithAI,
        child: isAiGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome),
        tooltip: 'Générer une question',
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
              builder: (context, child) => Transform.scale(
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
              ),
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
              onPressed: () {
                setState(() => isLoading = true);
                loadEnquete();
              },
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
    final questions = enquete!['questions'] as List;

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
                  builder: (context, child) => Transform.translate(
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
                  ),
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
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.deepPurple.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '✨ Questions intelligentes qui s\'adaptent à vos réponses !',
                          style: TextStyle(color: Colors.deepPurple.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatChip(Icons.flag, '${questions.length} défis'),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.timer, '~5 min'),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.emoji_events, 'Récompense'),
                  ],
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: ElevatedButton(
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                      ),
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
                  ),
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
    final questions = enquete!['questions'] as List;
    final progress = questions.isEmpty
        ? 0.0
        : _answeredCount / questions.length;
    final isAiGenerated = question['isAiGenerated'] == true;
    final questionId = question['id'] as int;
    final emotion = question['emotion'];
    final intent = question['intent'];

    final hasTriggered = _hasTriggeredGeneration[questionId] == true;

    // Get icon based on emotion
    IconData emotionIcon = Icons.chat_bubble_outline;
    Color emotionColor = Colors.deepPurple.shade400;

    if (emotion == 'positive') {
      emotionIcon = Icons.sentiment_very_satisfied;
      emotionColor = Colors.green;
    } else if (emotion == 'negative') {
      emotionIcon = Icons.sentiment_very_dissatisfied;
      emotionColor = Colors.red;
    } else if (emotion == 'confused') {
      emotionIcon = Icons.psychology;
      emotionColor = Colors.orange;
    }

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
            // Progress bar
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
                            'Défi $_currentPage/${questions.length}',
                            style: TextStyle(
                              color: Colors.deepPurple.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${questions.isEmpty ? 0 : (_answeredCount * 100 / questions.length).toInt()}%',
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

            // Question + Answer
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, double value, child) =>
                          Transform.translate(
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
                                      isAiGenerated
                                          ? Icons.auto_awesome
                                          : _getQuestionIcon(question['type']),
                                      size: 28,
                                      color: Colors.deepPurple.shade400,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            question['texte'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple,
                                              height: 1.3,
                                            ),
                                          ),
                                          if (emotion != null && isAiGenerated)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: emotionColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      emotionIcon,
                                                      size: 14,
                                                      color: emotionColor,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _getIntentText(intent),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: emotionColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isAiGenerated)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'IA',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, double value, child) =>
                          Transform.translate(
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
                          ),
                    ),

                    // Loading indicator while AI is generating
                    if (isAiGenerating && !hasTriggered)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurple.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurple.shade400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Analyse de votre réponse et génération...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepPurple.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Success indicator
                    if (hasTriggered && !isAiGenerating)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Réponse analysée - Nouvelle question générée',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
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

            // Navigation buttons
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
                  if (_currentPage > 1) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isNavigating
                            ? null
                            : () {
                                if (_currentPage > 1) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic,
                                  );
                                }
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
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isNavigating || isAiGenerating)
                          ? null
                          : _onNextButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: isAiGenerating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Analyse...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == questions.length
                                      ? 'Terminer'
                                      : 'Suivant',
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage == questions.length
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

  String _getIntentText(String? intent) {
    switch (intent) {
      case 'satisfaction':
        return '😊 Satisfaction';
      case 'problem':
        return '⚠️ Problème';
      case 'clarification':
        return '❓ Clarification';
      case 'suggestion':
        return '💡 Suggestion';
      default:
        return '🔍 Exploration';
    }
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
    final qId = q['id'] as int;

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
              controller: _textControllers[qId],
              focusNode: _focusNodes[qId],
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience...',
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
              onChanged: (_) => _updateProgress(),
            ),
            const SizedBox(height: 8),
            Text(
              '${_textControllers[qId]?.text.length ?? 0} caractères',
              style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade300),
            ),
          ],
        );

      case 'radio':
      case 'unique':
        final options = q['options'] as List;
        return Column(
          children: options.map<Widget>((opt) {
            bool isSelected = answers[qId] == opt['id'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  answers[qId] = opt['id'];
                  _updateProgress();
                });
                // Use debounce for radio buttons too
                if (_hasTriggeredGeneration[qId] != true) {
                  // Cancel existing timer
                  if (_debounceTimers[qId] != null) {
                    _debounceTimers[qId]!.cancel();
                  }
                  _debounceTimers[qId] = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      if (_hasTriggeredGeneration[qId] != true) {
                        _hasTriggeredGeneration[qId] = true;
                        _generateNextQuestionAutomatically();
                      }
                      _debounceTimers[qId] = null;
                    },
                  );
                }
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

      default:
        return const SizedBox();
    }
  }

  Widget _buildConclusionPage() {
    if (enquete == null) return const SizedBox();

    final questions = enquete!['questions'] as List;
    final score = questions.isEmpty
        ? 0
        : (_answeredCount * 100 / questions.length).toInt();

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
                  builder: (context, double value, child) => Transform.scale(
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
                  ),
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
                        'Défis relevés : $_answeredCount / ${questions.length}',
                        style: TextStyle(color: Colors.deepPurple.shade400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _submitAdventure,
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
                    backgroundColor: Colors.deepPurple,
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

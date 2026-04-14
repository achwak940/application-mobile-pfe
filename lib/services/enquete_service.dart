import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// ============================================
/// SERVICE COMPLET AVEC TOUTES LES FONCTIONNALITÉS
/// ============================================
class SurveyService {
  static const String baseUrl = 'http://localhost:3000';

  /// ============================================
  /// GET ENQUETE
  /// ============================================
  Future<Map<String, dynamic>> getEnqueteById(int id) async {
    final url = Uri.parse('$baseUrl/enquete/detailes/$id');

    debugPrint("📡 GET ENQUETE => $url");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));

      debugPrint("📊 STATUS => ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return data['data'];
    } catch (e) {
      debugPrint("❌ getEnquete error => $e");
      throw Exception('Erreur getEnquete: $e');
    }
  }

  /// ============================================
  /// SUBMIT ANSWERS
  /// ============================================
  Future<void> submitEnqueteResponses({
    required int enqueteId,
    required Map<int, dynamic> answers,
  }) async {
    final url = Uri.parse('$baseUrl/enquete/submit/$enqueteId');

    final formatted = answers.entries.map((e) {
      return {"questionId": e.key, "response": e.value};
    }).toList();

    debugPrint("📤 SUBMIT => $url");
    debugPrint("📦 DATA => ${jsonEncode(formatted)}");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"enqueteId": enqueteId, "answers": formatted}),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint("📊 SUBMIT STATUS => ${response.statusCode}");
      debugPrint("📦 RESPONSE => ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.body);
      }

      debugPrint("✅ SUBMIT SUCCESS");
    } catch (e) {
      debugPrint("❌ submit error => $e");
      throw Exception('Submit error: $e');
    }
  }

  /// ============================================
  /// GENERATE QUESTION WITH CUSTOM PROMPT
  /// ============================================
  Future<String> generateQuestionWithPrompt(String prompt) async {
    final url = Uri.parse('$baseUrl/ai-questions/generate');

    debugPrint("🤖 AI CUSTOM PROMPT REQUEST");
    debugPrint("📝 PROMPT LENGTH: ${prompt.length} characters");

    String promptPreview = prompt.length > 300
        ? prompt.substring(0, 300)
        : prompt;
    debugPrint("📝 PROMPT PREVIEW: $promptPreview...");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"question": prompt}),
          )
          .timeout(const Duration(seconds: 45));

      debugPrint("📊 AI STATUS => ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('AI error: ${response.body}');
      }

      final data = jsonDecode(response.body);

      debugPrint("📦 RAW RESPONSE DATA: $data");

      // Try to extract the question from different possible response formats
      String result = '';

      // Check if data is a String
      if (data is String) {
        result = data;
      }
      // Check if data is a number
      else if (data is num) {
        debugPrint("⚠️ API returned a number: $data - using fallback");
        result = "Pouvez-vous nous en dire plus sur votre expérience ?";
      }
      // Check if data has result field
      else if (data['result'] != null) {
        if (data['result'] is String) {
          result = data['result'];
        } else if (data['result'] is num) {
          result = "Pouvez-vous nous en dire plus sur votre expérience ?";
        } else {
          result = data['result'].toString();
        }
      }
      // Check if data has question field
      else if (data['question'] != null) {
        if (data['question'] is String) {
          result = data['question'];
        } else if (data['question'] is num) {
          result = "Pouvez-vous nous en dire plus sur votre expérience ?";
        } else {
          result = data['question'].toString();
        }
      }
      // Check if data has response field
      else if (data['response'] != null) {
        if (data['response'] is String) {
          result = data['response'];
        } else {
          result = data['response'].toString();
        }
      }
      // Check if data has text field
      else if (data['text'] != null) {
        if (data['text'] is String) {
          result = data['text'];
        } else {
          result = data['text'].toString();
        }
      }
      // If nothing found, convert entire response to string
      else {
        result = response.body;
      }

      // Final validation - if result is a number or empty, use fallback
      if (result.isEmpty ||
          int.tryParse(result) != null ||
          double.tryParse(result) != null) {
        debugPrint("⚠️ Invalid result detected: '$result' - using fallback");
        result = "Que pensez-vous de cette expérience ?";
      }

      debugPrint("====================================");
      debugPrint("✅ EXTRACTED RESULT:");
      debugPrint(result);
      debugPrint("====================================");

      return result;
    } catch (e) {
      debugPrint("❌ AI error => $e");
      return "Pouvez-vous nous parler un peu plus de votre expérience ?";
    }
  }

  /// ============================================
  /// GENERATE ADAPTIVE QUESTION WITH EMOTION ANALYSIS
  /// ============================================
  Future<Map<String, dynamic>> generateAdaptiveQuestion({
    required String theme,
    required String history,
    required String lastAnswer,
  }) async {
    try {
      final prompt = _buildEmotionAwarePrompt(theme, history, lastAnswer);

      final String result = await generateQuestionWithPrompt(prompt);

      debugPrint("📥 RAW RESULT FOR PARSING: $result");

      // Détecter l'émotion localement d'abord
      final String detectedEmotion = _detectEmotion(lastAnswer);
      final String detectedIntent = _determineIntent(
        detectedEmotion,
        lastAnswer,
      );

      // Si le résultat est vide ou un nombre, retourner une question par défaut
      if (result.isEmpty ||
          int.tryParse(result) != null ||
          double.tryParse(result) != null) {
        return {
          'question': _getFallbackQuestion(detectedEmotion, theme),
          'emotion': detectedEmotion,
          'intent': detectedIntent,
        };
      }

      // Essayer de parser comme JSON
      try {
        // Nettoyer la réponse
        String cleanResult = result.trim();

        // Si la réponse commence par une lettre (texte simple), ce n'est pas du JSON
        if (cleanResult.isNotEmpty &&
            !cleanResult.startsWith('{') &&
            !cleanResult.startsWith('[')) {
          // C'est une question en texte brut
          return {
            'question': cleanResult,
            'emotion': detectedEmotion,
            'intent': detectedIntent,
          };
        }

        // Remove markdown code blocks if present
        if (cleanResult.startsWith('```json') ||
            cleanResult.startsWith('```')) {
          cleanResult = cleanResult.replaceAll(RegExp(r'^```json?\n?'), '');
          cleanResult = cleanResult.replaceAll(RegExp(r'\n?```$'), '');
          cleanResult = cleanResult.trim();
        }

        // Try to find JSON object in the string
        int startIndex = cleanResult.indexOf('{');
        int endIndex = cleanResult.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          cleanResult = cleanResult.substring(startIndex, endIndex + 1);
        }

        debugPrint("📥 CLEANED JSON: $cleanResult");

        final Map<String, dynamic> jsonResponse = json.decode(cleanResult);

        final String question = jsonResponse['question']?.toString() ?? '';
        final String emotion =
            jsonResponse['emotion']?.toString() ?? detectedEmotion;
        final String intent =
            jsonResponse['intent']?.toString() ?? detectedIntent;

        // Valider la question
        final String validQuestion = _validateQuestion(
          question,
          emotion,
          theme,
        );

        return {
          'question': validQuestion,
          'emotion': emotion,
          'intent': intent,
        };
      } catch (e) {
        debugPrint("Failed to parse as JSON: $e - treating as plain text");
        // Si ce n'est pas du JSON valide, utiliser le texte brut comme question
        return {
          'question': result,
          'emotion': detectedEmotion,
          'intent': detectedIntent,
        };
      }
    } catch (e) {
      debugPrint("❌ generateAdaptiveQuestion error: $e");
      return {
        'question': "Pouvez-vous nous en dire plus sur votre expérience ?",
        'emotion': 'neutral',
        'intent': 'explore',
      };
    }
  }

  String _validateQuestion(String question, String emotion, String theme) {
    if (question.isEmpty || question.length < 5) {
      return _getFallbackQuestion(emotion, theme);
    }
    if (int.tryParse(question) != null || double.tryParse(question) != null) {
      return _getFallbackQuestion(emotion, theme);
    }
    return question;
  }

  String _getFallbackQuestion(String emotion, String theme) {
    switch (emotion) {
      case 'positive':
        return "Qu'est-ce qui vous a le plus plu dans cette expérience ?";
      case 'negative':
        return "Qu'est-ce qui pourrait être amélioré selon vous ?";
      case 'confused':
        return "Pouvez-vous préciser votre pensée ?";
      default:
        return "Que pensez-vous de cette expérience sur le thème « $theme » ?";
    }
  }

  String _buildEmotionAwarePrompt(
    String theme,
    String history,
    String lastAnswer,
  ) {
    return """
You are an expert UX researcher conducting a survey.

### CONTEXT:
Survey Theme: $theme
Conversation History: $history
Last Answer: "$lastAnswer"

### TASK:
Generate ONE short follow-up question (max 15 words) that:
1. Responds to the user's answer naturally
2. Goes deeper into their response
3. Is human-like and conversational

### RULES:
- DO NOT repeat previous questions
- Keep it short and natural

### OUTPUT FORMAT:
Return ONLY the question as plain text, no JSON, no quotes, no markdown.

Example outputs:
- "What did you like most about it?"
- "How could we improve this for you?"
- "Can you tell me more about that?"
""";
  }

  String _detectEmotion(String text) {
    final lowerText = text.toLowerCase();

    final positiveWords = [
      "good",
      "great",
      "excellent",
      "happy",
      "satisfied",
      "love",
      "like",
      "amazing",
      "wonderful",
      "fantastic",
      "perfect",
      "awesome",
      "super",
      "bien",
      "bon",
      "génial",
      "satisfait",
      "parfait",
      "cool",
      "nice",
    ];

    final negativeWords = [
      "bad",
      "poor",
      "dissatisfied",
      "unhappy",
      "terrible",
      "hate",
      "dislike",
      "awful",
      "worst",
      "horrible",
      "mauvais",
      "mécontent",
      "déçu",
      "horrible",
      "frustrated",
      "angry",
      "disappointed",
    ];

    if (positiveWords.any((word) => lowerText.contains(word))) {
      return "positive";
    } else if (negativeWords.any((word) => lowerText.contains(word))) {
      return "negative";
    } else if (text.length < 10) {
      return "confused";
    }

    // Check for numerical ratings
    final ratingMatch = RegExp(r'\b([1-9]|10)\b').firstMatch(lowerText);
    if (ratingMatch != null) {
      final rating = int.parse(ratingMatch.group(1)!);
      if (rating <= 3) return "negative";
      if (rating <= 6) return "neutral";
      return "positive";
    }

    return "neutral";
  }

  String _determineIntent(String emotion, String answer) {
    switch (emotion) {
      case "positive":
        return "satisfaction";
      case "negative":
        return "problem";
      case "confused":
        return "clarification";
      default:
        return "explore";
    }
  }

  /// ============================================
  /// AI GENERATE (LEGACY - keeps compatibility)
  /// ============================================
  Future<String> generateQuestion(String prompt) async {
    return await generateQuestionWithPrompt(prompt);
  }

  /// ============================================
  /// GENERATE QUESTION BASED ON PREVIOUS ANSWER
  /// ============================================
  Future<String> generateNextQuestion({
    required String surveyTheme,
    required String previousQuestion,
    required String previousAnswer,
    required int questionNumber,
  }) async {
    final prompt =
        '''
Génère une question pour un sondage sur: "$surveyTheme".
Question précédente: "$previousQuestion"
Réponse: "$previousAnswer"
Question #$questionNumber

Génère UNIQUEMENT la question (max 20 mots).
''';

    return await generateQuestion(prompt);
  }

  /// ============================================
  /// STREAM AI (REAL TIME)
  /// ============================================
  Stream<Map<String, dynamic>> generateQuestionStream(String prompt) async* {
    final encodedPrompt = Uri.encodeComponent(prompt);
    final url = Uri.parse('$baseUrl/ai-questions/stream/$encodedPrompt');

    debugPrint("🚀 STREAM START => $url");

    final client = http.Client();

    try {
      final request = http.Request('GET', url);
      final response = await client.send(request);

      debugPrint("📊 STREAM STATUS => ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception('Stream failed with status ${response.statusCode}');
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;

          final jsonStr = line.replaceFirst('data: ', '').trim();

          if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

          try {
            final data = jsonDecode(jsonStr);
            yield {
              'id': data['id']?.toString() ?? '',
              'status': data['status']?.toString() ?? 'pending',
              'prompt': data['prompt']?.toString() ?? '',
              'result': data['result']?.toString(),
              'error': data['error']?.toString(),
              'timestamp':
                  data['timestamp']?.toString() ??
                  DateTime.now().toIso8601String(),
            };
          } catch (e) {
            debugPrint("❌ parse error => $e");
          }
        }
      }
    } catch (e) {
      debugPrint("❌ STREAM ERROR => $e");
      throw Exception('Stream error: $e');
    } finally {
      client.close();
    }
  }
}

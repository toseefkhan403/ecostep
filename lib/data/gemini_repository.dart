import 'dart:convert';
import 'package:ecostep/domain/action.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_repository.g.dart';

class GeminiRepository {
  GeminiRepository() {
    final apiKey = dotenv.env['gemini_api_key'] ??
        const String.fromEnvironment('gemini_api_key');
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  late final GenerativeModel model;

  Future<List<Action>> generateActions() async {
    debugPrint('generating actions with AI');
    const prompt =
        r'''Give one actionable sustainable task per day for a person for 7 days which is good for the environment, wildlife, nature, humanity, etc. Some examples include: feeding a stray animal, keeping a water bowl for birds, recycling a plastic bottle, etc. Give the difficulty as well based on the effort required to complete that task as easy, moderate, hard. These actions should be verifiable by analyzing an image provided by the user. Return the output in json using the following structure: {[ "action" : "$action", "description" : "$description", "difficulty" : "$difficulty", "impact" : "$impact", "impactIfNotDone" : "$impactIfNotDone", "verifiableImage" : "$verifiableImage",]}''';

    final output = await model.generateContent([Content.text(prompt)]);
    final jsonResponse = jsonDecode(output.text!) as List<dynamic>;
    return jsonResponse
        .map((e) => Action.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> verifyImage(
    Uint8List imageBytes,
    String verifiableImage,
  ) async {
    final prompt = TextPart(
      '''Give a score out of 100 for this image on how much it matches this description: $verifiableImage. Return the output in json using the following structure: { "verifiedScore" : "verifiedScore", "imageAnalysis" : "imageAnalysis"}''',
    );

    final imagePart = DataPart('image/jpeg', imageBytes);

    final output = await model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    return jsonDecode(output.text!) as Map<String, dynamic>;
  }
}

@riverpod
GeminiRepository geminiRepository(GeminiRepositoryRef ref) =>
    GeminiRepository();

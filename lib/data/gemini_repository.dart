import 'dart:convert';
import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/action.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_repository.g.dart';

class GeminiRepository {
  GeminiRepository(this.ref) {
    final apiKey = dotenv.env['gemini_api_key'] ??
        const String.fromEnvironment('gemini_api_key');
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 2,
      ),
    );
    _chat = model.startChat();
  }

  late final GenerativeModel model;
  late final ChatSession _chat;
  final GeminiRepositoryRef ref;

  Future<List<Action>> generateActions() async {
    debugPrint('generating actions with AI');
    var pPrompt = '';
    final pString =
        ref.watch(firestoreUserProvider).value?.personalizationString;
    if (pString != null) {
      pPrompt = 'Personalization info of the user is: $pString';
    }
    debugPrint(pString);

    final prompt =
        '''Generate one actionable sustainable task per day for a user for 7 days which is good for the environment, wildlife, nature, humanity, etc. Give different tasks from the ones you provided before. Some examples include: feeding a stray animal, keeping a water bowl for birds, recycling a plastic bottle, etc. Give the difficulty as well based on the effort required to complete that task as easy, moderate, hard. Progressively increase the difficulty of the tasks. These tasks should be verifiable by analyzing an image provided by the user. The tasks should be personalized. $pPrompt. Return the output in json using the following structure: {[ "action" : "action", "description" : "description", "difficulty" : "difficulty", "impact" : "impact", "impactIfNotDone" : "impactIfNotDone", "verifiableImage" : "verifiableImage"]}''';

    final output = await _chat.sendMessage(Content.text(prompt));
    final jsonResponse = jsonDecode(output.text!) as List<dynamic>;
    return jsonResponse
        .map((e) => Action.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> generatePrice(
    String itemTitle,
    String itemDescription,
    String usedForMonths,
    Uint8List imageBytes,
  ) async {
    const promptTemplate =
        r'''Give a price estimation in rupees for a used item, whose description is as follows: $itemTitle, $itemDescription, which has been used for $usedForMonths. Also, consider the attached image of the item for a more accurate estimation. Return the output in JSON using the following structure: { "itemPrice" : "$itemPrice"}, itemPrice must be an integer.''';

    final prompt = promptTemplate
        .replaceAll(r'$itemTitle', itemTitle)
        .replaceAll(r'$itemDescription', itemDescription)
        .replaceAll(r'$usedForMonths', usedForMonths);

    if (kDebugMode) {
      print(prompt);
    }

    final imagePart = DataPart('image/jpeg', imageBytes);

    final output = await model.generateContent([
      Content.multi([
        TextPart(prompt),
        imagePart,
      ]),
    ]);
    final jsonResponse = jsonDecode(output.text!) as Map<String, dynamic>;
    final itemPrice = jsonResponse['itemPrice'];

    return itemPrice.toString();
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
    GeminiRepository(ref);

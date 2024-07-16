import 'dart:convert';
import 'dart:typed_data';
import 'package:ecostep/domain/action.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  late final GenerativeModel model;
  final String apiKey = dotenv.env['gemini_api_key']!;

  ApiService() {
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<List<Action>> generateActions() async {
    const prompt = '''
    Give one actionable task per day for a person for 7 days which is good for the environment, wildlife, nature, humanity, etc. Some examples include: feeding a stray animal, keeping a water bowl for birds, recycling a plastic bottle, etc. Give the difficulty as well based on the effort required to complete that task as easy, moderate, hard. Progressively increase the difficulty of the tasks. These actions should be verifiable by analyzing an image provided by the user. Return the output in json using the following structure: {[ "action" : "\$action", "description" : "\$description", "difficulty" : "\$difficulty", "impact" : "\$impact", "impactIfNotDone" : "\$impactIfNotDone", "verifiable_image" : "\$verifiable_image",]}
    ''';

    final output = await model.generateContent([Content.text(prompt)]);
    final List<dynamic> jsonResponse =
        jsonDecode(output.text!) as List<dynamic>;
    return jsonResponse
        .map((e) => Action.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> verifyImage(Uint8List imageBytes) async {
    final prompt = TextPart('''
    Give a percentage score for this image on how much it matches this description: Image showing the user participating in a volunteer activity for an environmental organization (planting trees, cleaning a beach, etc.). Return the output in json using the following structure: { "verifiedScore" : "\$verifiedScore"}
    ''');

    final imagePart = DataPart('image/jpeg', imageBytes);

    final output = await model.generateContent([
      Content.multi([prompt, imagePart])
    ]);

    final jsonResponse = jsonDecode(output.text!) as Map<String, dynamic>;
    return int.parse(jsonResponse['verifiedScore'] as String);
  }
}

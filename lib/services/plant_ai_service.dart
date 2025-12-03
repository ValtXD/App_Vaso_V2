import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantAIService {
  final String apiKey = "AIzaSyC9wwWTMjsZQgj7g3-1Raww6uHsjumpjIU";

  // modelo mais novo do AI Studio
  final String model = "gemini-3-pro-preview";

  Future<String> ask(String question) async {
    final String endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey";

    final resp = await http.post(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                "Responda apenas sobre plantas, suas caractéristicas de cuidados, de luz e aguá e caso pergunte sobre o aplicativo PlantCare, explique oque é o aplicativo. Pergunta: $question"
              }
            ]
          }
        ]
      }),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      throw Exception("Erro na API Gemini: ${resp.body}");
    }
  }
}

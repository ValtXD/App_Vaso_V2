import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/chat_message.dart';
import '../services/plant_ai_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final PlantAIService _aiService = PlantAIService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chat_history');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() {
        _messages.addAll(list.map((e) => ChatMessage.fromJson(e)));
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _messages.map((m) => m.toJson()).toList();
    await prefs.setString('chat_history', jsonEncode(payload));
  }

  Future<void> _sendMessage(String question) async {
    if (question.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        question: question,
        answer: "⏳ Processando...",
        timestamp: DateTime.now(),
      ));
    });

    try {
      final answer = await _aiService.ask(question);
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          question: question,
          answer: answer,
          timestamp: DateTime.now(),
        ));
      });
      _saveHistory();
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          question: question,
          answer: "❌ Erro ao consultar IA: $e",
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<void> _pickImageAndIdentify() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.6));
    final inputImage = InputImage.fromFile(File(image.path));
    final labels = await labeler.processImage(inputImage);

    if (labels.isNotEmpty) {
      final plantName = labels.first.label;
      _sendMessage("Quais cuidados para a planta $plantName?");
    } else {
      _sendMessage("Não consegui identificar a planta na imagem.");
    }

    await labeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat IA - PlantCare"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _pickImageAndIdentify,
            tooltip: "Identificar planta via foto",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("❓ Pergunta:",
                            style: Theme.of(context).textTheme.labelMedium),
                        Text(msg.question),
                        const SizedBox(height: 8),
                        Text("💡 Resposta:",
                            style: Theme.of(context).textTheme.labelMedium),
                        Text(msg.answer),
                        const SizedBox(height: 8),
                        Text(
                          msg.timestamp.toLocal().toString(),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Digite sua pergunta sobre plantas...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage(_controller.text.trim());
                    _controller.clear();
                  },
                  child: const Text("Enviar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

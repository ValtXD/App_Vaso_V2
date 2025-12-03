class ChatMessage {
  final String question;
  final String answer;
  final DateTime timestamp;

  ChatMessage({
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    question: json['question'],
    answer: json['answer'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

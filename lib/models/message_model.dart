class Message {
  String content;
  String role; // 'user' or 'assistant'
  final bool isTyping; // Add this line

  Message({required this.content, required this.role, this.isTyping = false});
}

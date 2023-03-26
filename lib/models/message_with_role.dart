class MessageWithRole {
  final String role;
  final String content;

  MessageWithRole({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

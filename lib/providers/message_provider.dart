import 'package:flutter/foundation.dart';

import '../models/message.dart';
import '../services/api_service.dart';


class MessageProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    addMessage(Message(isUser: true, text: text));
    try {
      final response = await _apiService.getAnswer(_messages, text);
      addMessage(Message(isUser: false, text: response));
    } catch (e) {
      addMessage(Message(isUser: false, text: "请求失败，请重试。"));
    }
  }
}

import 'package:ai_chat/proxy/proxy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../providers/message_provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 聊天'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProxyScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RawKeyboardListener(
        autofocus: false,
        onKey: (event) {
          if (event.runtimeType == RawKeyDownEvent) {
            if (event.physicalKey == PhysicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.enter) {}
          }
        },
        focusNode: FocusNode(),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Consumer<MessageProvider>(
                    builder: (context, messages, child) {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.messages.length,
                        itemBuilder: (context, index) {
                          final message = messages.messages[index];
                          return _buildMessageBubble(context, message);
                        },
                      );
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            ),
            if (_isLoading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      bottom: 70,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SpinKitWanderingCubes(
                color: Colors.white,
                size: 20.0,
              ),
              SizedBox(width: 16.0),
              Text(
                '正在加载...',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0.0, -1.0),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (value) {
                if (!_isLoading) {
                  _sendMessage();
                }
              },
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration.collapsed(
                hintText: '请输入问题...',
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendMessage,
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _scrollToBottom();
      _controller.clear();
      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);
      await context.read<MessageProvider>().sendMessage(text);
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Widget _buildMessageBubble(BuildContext context, Message message) {
    final isUser = message.isUser;
    final borderRadius = BorderRadius.circular(5.0);
    const padding = EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          isUser ? 40.0 : 8.0, 8.0, isUser ? 8.0 : 40.0, 8.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                const CircleAvatar(
                  radius: 16.0,
                  backgroundImage: AssetImage('assets/service.png'),
                ),
              const SizedBox(width: 5),
              Flexible(
                child: Material(
                  color: isUser
                      ? Theme.of(context).primaryColor
                      : Colors.grey[200],
                  borderRadius: isUser
                      ? borderRadius.subtract(BorderRadius.only(
                          bottomRight: borderRadius.bottomRight))
                      : borderRadius.subtract(BorderRadius.only(
                          bottomLeft: borderRadius.bottomLeft)),
                  child: InkWell(
                    borderRadius: borderRadius,
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      Fluttertoast.showToast(
                        msg: '复制成功',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        backgroundColor: Colors.black.withOpacity(0.7),
                        textColor: Colors.white,
                      );
                    },
                    child: Padding(
                      padding: padding,
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 5),
              if (isUser)
                const CircleAvatar(
                  radius: 16.0,
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }
}

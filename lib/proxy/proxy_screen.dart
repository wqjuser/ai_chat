import 'package:ai_chat/services/api_service.dart';
import 'package:flutter/material.dart';

class ProxyScreen extends StatefulWidget {
  const ProxyScreen({super.key});

  @override
  _ProxyScreenState createState() => _ProxyScreenState();
}

class _ProxyScreenState extends State<ProxyScreen> {
  final _addressController = TextEditingController();
  final _portController = TextEditingController();

  void _setProxy() {
    final address = _addressController.text;
    final port = _portController.text;
    if (address.isEmpty || port.isEmpty) {
      return;
    }
    ApiService().setProxy(address, port);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('代理设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '地址',
                hintText: '请输入代理地址，例如 0.0.0.0',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: '端口',
                hintText: '请输入代理端口，例如 1234',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _setProxy,
              child: const Text('设置代理'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ApiService().clearProxy();
                Navigator.of(context).pop();
              },
              child: const Text('清除代理'),
            ),
          ],
        ),
      ),
    );
  }
}

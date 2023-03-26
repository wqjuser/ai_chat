import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/message.dart';
import '../models/message_with_role.dart';

class ApiService {
  static const String _apiKey =
      "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";
  static const String _apiUrl = "https://api.openai.com/v1/chat/completions";
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.headers["Content-Type"] = "application/json";
    _dio.options.headers["Authorization"] = "Bearer $_apiKey";
    _dio.interceptors
        .add(LogInterceptor(responseBody: true, requestBody: true));
    _dio.interceptors.add(DioInterceptor(_dio));
  }

  Future<String> getAnswer(List<Message> messages, String question) async {
    List<MessageWithRole> conversation = [];

    for (Message message in messages) {
      conversation.add(MessageWithRole(
        role: message.isUser ? 'user' : 'assistant',
        content: message.text,
      ));
    }
    // conversation.add(MessageWithRole(role: 'user', content: question));

    try {
      final response = await _dio.post(
        _apiUrl,
        data: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': conversation.map((message) => message.toJson()).toList(),
        }),
      );
      return response.data['choices'][0]['message']['content']
          .toString()
          .trim();
    } on DioError catch (e) {
      throw Exception("请求失败: ${e.message}");
    }
  }

  void setProxy(String address, String port) {
    if (kDebugMode) {
      Fluttertoast.showToast(
        msg: '代理设置了吗',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
      );
    }
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (uri) {
        String myProxy = '';
        myProxy = "PROXY $address:$port";
        if (kDebugMode) {
          print("代理地址是-->$myProxy");
        }
        return myProxy;
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  void clearProxy() {
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = null;
  }
}

class DioInterceptor extends Interceptor {
  late Dio _dio;

  DioInterceptor(Dio dio) {
    _dio = dio;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      //这一段是解决安卓https抓包的问题
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return Platform.isAndroid;
      };
      client.findProxy = (uri) {
        if (kDebugMode) {
          print('dio的代理Proxy是->>>>>>>>: $uri');
        }
        String myProxy = '';
        myProxy = "PROXY $uri";
        return myProxy;
      };
      return null;
    };
    super.onRequest(options, handler);
  }
}

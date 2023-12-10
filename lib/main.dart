import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatGPTDemo(),
    );
  }
}

class ChatGPTDemo extends StatefulWidget {
  @override
  _ChatGPTDemoState createState() => _ChatGPTDemoState();
}

class _ChatGPTDemoState extends State<ChatGPTDemo> {
  final TextEditingController _controller = TextEditingController();
  List<String> chatHistory = [];

  Future<void> sendMessage(String message) async {
    setState(() {
      chatHistory.add('User: $message');
    });

    await Future.delayed(Duration(seconds: 2));

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: jsonEncode({
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant !'},
          {'role': 'user', 'content': message}
        ],
        'model': 'gpt-3.5-turbo',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String chatGPTResponse = data['choices'][0]['message']['content'];

      setState(() {
        chatHistory.add('ChatGPT: $chatGPTResponse');
      });
    } else {
      print('API Error: ${response.statusCode}');
      print('API Response: ${response.body}');
      throw Exception('Failed to communicate with ChatGPT API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chatHistory[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text;
                    if (message.isNotEmpty) {
                      sendMessage(message);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

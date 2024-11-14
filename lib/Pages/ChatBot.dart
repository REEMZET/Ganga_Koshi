import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final Dio _dio = Dio();
  bool _isConversationStarted = false;
  bool _useDhenu = true; // Flag to choose between Dhenu and Gemini

  Future<void> _startConversation(String language) async {
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"language": language});

    // Use the appropriate endpoint based on the selected option
    String endpoint = _useDhenu ? 'http://51.20.3.105/start-dhenu' : 'http://51.20.3.105/start';

    try {
      var response = await _dio.post(
        endpoint,
        options: Options(headers: headers),
        data: data,
      );
      if (response.statusCode == 200) {
        setState(() {
          _isConversationStarted = true;
          _messages.add({'bot': 'Conversation started in $language.'});
        });
      } else {
        print('Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Future<void> _sendMessage(String input) async {
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"input": input});

    String endpoint = _useDhenu ? 'http://51.20.3.105/chat-dhenu' : 'http://51.20.3.105/chat';

    try {
      print('Sending request to: $endpoint');
      print('Request data: $data');

      var response = await _dio.post(
        endpoint,
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.data);
        setState(() {
          _messages.add({'user': input});
          _messages.add({'bot': responseData['response']});
        });
      } else {
        print('Error: ${response.statusCode} - ${response.statusMessage}');
        print('Response Data: ${response.data}');
        setState(() {
          _messages.add({'bot': 'Error: ${response.statusCode}, try again later.'});
        });
      }
    } on DioError catch (e) {
      print('Dio Error: ${e.response?.data}');
      print('Request Error: ${e.requestOptions}');
      setState(() {
        _messages.add({'bot': 'Server error occurred, please try again later.'});
      });
    } catch (e) {
      print('Exception caught: $e');
      setState(() {
        _messages.add({'bot': 'Unexpected error occurred, please try again later.'});
      });
    }
  }

  Future<void> _endConversation() async {
    await _sendMessage("end");
    setState(() {
      _isConversationStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: () {
              _endConversation();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(
                    message.keys.contains('user') ? 'You' : 'Bot',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: message.keys.contains('user') ? Colors.blue : Colors.green),
                  ),
                  subtitle: Text(message.values.first),
                );
              },
            ),
          ),
          if (!_isConversationStarted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _startConversation("hindi"); // Start conversation in Hindi (default)
                },
                child: Text('Start Conversation'),
              ),
            ),
          if (_isConversationStarted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask something...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _sendMessage(_controller.text);
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

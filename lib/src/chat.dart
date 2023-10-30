import 'dart:convert';

import 'package:azure_chat/src/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

enum MessageType {
  user,
  assistant,
}

class ChatMessage {
  String content;
  MessageType messageType;

  Map<String, String> toJson() {
    return {"role": messageType.name, "content": content};
  }

  ChatMessage({required this.content, required this.messageType});
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _textInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _chatMessages = [
    // ChatMessage(
    //     content: "Hello I am GPT", messageType: MessageType.languageModel),
    ChatMessage(content: "Hello GPT, how are you", messageType: MessageType.user),
    ChatMessage(content: '''
  In Python, you can determine the size (i.e., the number of elements) of an array, list, or any iterable using the built-in **len()** function. Here's how to do it:

  ```python
  my_array = [1, 2, 3, 4, 5, 6, 7]
  size = len(my_array)
  print("The size of the array is:", size)
  ```

  In this example, we define an array called `my_array`, and then we use the `len()` function to obtain the size of the array and print it.
        ''', messageType: MessageType.assistant),
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textInputController.dispose();
    super.dispose();
  }

  void _onNewMessageSubmit(String message) {
    setState(() {
      _chatMessages.add(ChatMessage(content: message, messageType: MessageType.user));
    });
    _textInputController.clear();
    _queryAssistantResponse();
  }

  void _scrollToEnd() {
    SchedulerBinding.instance.addPostFrameCallback((_) => _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn));
  }

  void _onSendPress() {
    // ignore if no text
    if (_textInputController.text.isEmpty) return;

    setState(() {
      _chatMessages.add(ChatMessage(content: _textInputController.text, messageType: MessageType.user));
      _isLoading = true;
    });

    _scrollToEnd();

    _textInputController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    _queryAssistantResponse();
  }

  void _queryAssistantResponse() async {
    final response = await http.post(
      Uri.parse(AZURE_OPENAI_ENDPOINT),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'api-key': AZURE_OPENAI_KEY,
      },
      body: jsonEncode({"messages": _chatMessages}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final choices = body["choices"] as List<dynamic>;
      final message = choices[0]["message"]["content"] as String;
      setState(() {
        _chatMessages.add(ChatMessage(content: message, messageType: MessageType.assistant));
        _isLoading = false;
      });

      _scrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(bottom: 10, left: 8.0, right: 8.0),
      color: theme.colorScheme.background,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(0),
                itemCount: _chatMessages.length,
                itemBuilder: (BuildContext context, int index) {
                  final isClientMessage = _chatMessages[index].messageType == MessageType.user;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                    child: Align(
                        alignment: isClientMessage ? Alignment.topRight : Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isClientMessage ? theme.colorScheme.primaryContainer : theme.colorScheme.secondaryContainer,
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: MarkdownBody(
                            styleSheet: MarkdownStyleSheet.fromTheme(theme.copyWith(cardTheme: const CardTheme(color: Color(0xFF13181c)))),
                            data: _chatMessages[index].content,
                          ),
                        )),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: TextField(
                      onTap: () => Future.delayed(const Duration(milliseconds: 500), _scrollToEnd),
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder.none,
                          hintText: 'Send a message'),
                      controller: _textInputController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      minLines: 1,
                      onSubmitted: _onNewMessageSubmit,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                  height: 0,
                ),
                SizedBox(
                  width: 45,
                  height: 45,
                  child: _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primaryContainer,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _onSendPress,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(0),
                            foregroundColor: theme.colorScheme.primaryContainer,
                            backgroundColor: theme.colorScheme.primaryContainer,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

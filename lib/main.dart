import 'package:azure_chat/src/chat.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primaryContainer: Color(0xFF005e49), // green
          secondaryContainer: Color(0xFF222d35), // light gray
          background: Color(0xFF08141c), // almost black
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Azure OpenAI Chat Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFF212c34),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
          title: Text(title),
        ),
        body: const Center(
          child: Chat(),
        ),
      ),
    );
  }
}

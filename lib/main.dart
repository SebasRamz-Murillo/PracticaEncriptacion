import 'package:flutter/material.dart';
import 'package:practica_crypt/view/chat.dart';

void main() {
  runApp(ChatApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Encriptacion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatApp(),
    );
  }
}

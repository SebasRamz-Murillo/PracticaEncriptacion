import 'package:flutter/material.dart';
import 'package:practica_crypt/util/util.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  void _handleSubmitted(String text) {
    _textController.clear();
    final claveSecreta = "MiClaveSecreta";

    String encriptado = mensajeEncriptado(text, claveSecreta);
    String desencriptado = mensajeDesencriptado(encriptado, claveSecreta);

    ChatMessage message = ChatMessage(
      text: encriptado,
      hash: desencriptado,
      isSentByMe: true,
    );
    ChatMessage message2 = ChatMessage(
      text: encriptado,
      hash: desencriptado,
      isSentByMe: false,
    );

    setState(() {
      _messages.insert(0, message);
      _messages.insert(0, message2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat encriptado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text('Iniciar sesion'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Usuario',
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Contraseña',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Iniciar sesion'),
                          ),
                        ],
                      ));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Enviar un mensaje'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage(
      {required this.text, required this.hash, required this.isSentByMe});

  final String text;
  final String hash;
  String hora = "";
  DateTime now = DateTime.now();

  final bool isSentByMe;

  @override
  Widget build(BuildContext context) {
    hora = "${now.hour}:${now.minute}";
    String encriptado;
    String desencriptado;
    return Column(
      mainAxisAlignment:
          isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment:
                isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  child: isSentByMe
                      ? const Text('A')
                      : const Text('B'), // Puedes personalizar el avatar aquí
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          isSentByMe ? 'Tú' : 'Otro Usuario',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(hora)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: Text(text,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 8)),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: Text(hash),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

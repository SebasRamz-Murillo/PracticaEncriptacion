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
  final TextEditingController _ctrlSala = TextEditingController();
  final TextEditingController _ctrlContra = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool autorizado = false;
  bool autorizando = false;

  void _handleSubmitted(String text) {
    _textController.clear();
    final claveSecreta = "MiClaveSecreta";

    String encriptado = mensajeEncriptado(text, claveSecreta);
    String desencriptado = mensajeDesencriptado(encriptado, claveSecreta);

    ChatMessage message = ChatMessage(
      text: encriptado,
      hash: desencriptado,
      isSentByMe: true,
      autorizado: autorizado,
    );
    ChatMessage message2 = ChatMessage(
      text: encriptado,
      hash: desencriptado,
      isSentByMe: false,
      autorizado: autorizado,
    );

    setState(() {
      _messages.insert(0, message);
      _messages.insert(0, message2);
    });
  }

  void _handleAuth(String sala, String contra, String hashReal) {
    String contraHash;
    String provicionalHash;
    provicionalHash = encriptar(hashReal);
    contraHash = encriptar(contra);
    setState(() {
      if (provicionalHash == contraHash) {
        autorizado = true;
      } else {
        autorizado = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat encriptado'),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                autorizado = false;
                _messages.forEach((element) {
                  element.autorizado = false;
                });
                autorizando = false;
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.verified_user),
              onPressed: () {
                setState(() {
                  autorizando = true;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Iniciar sesion'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _ctrlSala,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Sala',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _ctrlContra,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Contraseña',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _ctrlContra.clear();
                                _ctrlSala.clear();
                                setState(() {
                                  autorizando = false;
                                });

                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                _handleAuth(
                                    "1", _ctrlContra.text, _ctrlContra.text);
                                if (autorizado) {
                                  _messages.forEach((element) {
                                    element.autorizado = true;
                                  });
                                }
                                _ctrlContra.clear();
                                _ctrlSala.clear();

                                setState(() {
                                  autorizando = false;
                                });

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
        body: !autorizando
            ? Column(
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
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor),
                    child: _buildTextComposer(),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Autorizando...'),
                  ],
                ),
              ));
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
      {required this.text,
      required this.hash,
      required this.isSentByMe,
      this.autorizado = false});

  final String text;
  final String hash;
  String hora = "";
  DateTime now = DateTime.now();
  bool autorizado;

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
                    Container(
                      width: 200.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isSentByMe ? 'Tú' : 'Otro Usuario',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(hora)
                        ],
                      ),
                    ),
                    autorizado
                        ? Column(
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
                        : Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            child: Text(text),
                          ),
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

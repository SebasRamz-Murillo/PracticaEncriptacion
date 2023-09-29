import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:practica_crypt/model/sala.dart';
import 'package:practica_crypt/util/constantes.dart';
import 'package:practica_crypt/util/util.dart';
import 'package:practica_crypt/util/ws.dart';
import 'package:practica_crypt/view/singup.dart';

class ChatApp extends StatefulBuilder {
  ChatApp({Key? key, required Widget Function(BuildContext) builder})
      : super(
          builder: (BuildContext context, StateSetter setState) {
            return builder(context);
          },
          key: key,
        );
}

class ChatScreen extends StatefulWidget {
  final String nombre;
  final String password;

  const ChatScreen({Key? key, required this.nombre, required this.password})
      : super(key: key);

  @override
  State createState() => ChatScreenState(nombre, password);
}

class ChatScreenState extends State<ChatScreen> {
  final String nombre;
  final String password;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _ctrlSala = TextEditingController();
  final TextEditingController _ctrlContra = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  late Sala salaActual;
  bool autorizado = false;
  bool autorizando = false;
  SOCKET socket = SOCKET();
  String claveSala = "";
  String claveSalaAutorizada = "";

  ChatScreenState(this.nombre, this.password);

  void initState() {
    super.initState();
    salaActual = Sala(nombre, password);
    socket.connectToServerChat(nombre, (p0) {
      _handleRecibir(p0);
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.trim().isEmpty) {
      return;
    }
    String encriptado = mensajeEncriptado(text, claveSala);
    String desencriptado = mensajeDesencriptado(encriptado, claveSala);
    ChatMessage message = ChatMessage(
      text: encriptado,
      hash: desencriptado,
      isSentByMe: false,
      autorizado: autorizado,
    );
    Sala mensaje = Sala(encriptado, nombre);
    socket.mensaje(mensaje.toJson().toString(), (p0) {
      print(p0);
    });

    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleRecibir(String textCifrado) {
    _textController.clear();
    const claveSecreta = "MiClaveSecreta";
    if (textCifrado.trim().isEmpty) {
      return;
    }
    //String encriptado = mensajeEncriptado(text, claveSala);
    String desencriptado = "";
    if (autorizado) {
      desencriptado = mensajeDesencriptado(textCifrado, claveSala);
    }
    ChatMessage message = ChatMessage(
      text: textCifrado,
      hash: desencriptado,
      isSentByMe: false,
      autorizado: autorizado,
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAuth(String sala, String contra, String hashReal) {
    String contraHash;
    contraHash = encriptar(contra);
    setState(() {
      if (password == contraHash) {
        autorizado = true;
        salaActual.contraAutorizada = contra;
      } else {
        autorizado = false;
      }
    });
  }
/* 
  void _crearSala(String idSala, String contra) {
    setState(() {
      claveSala = encriptar(contra);
      claveSalaAutorizada = contra;
      autorizado = true;
    });
    final salaContra = {'Sala': idSala, 'Contra': claveSala};
    final String jsonString = jsonEncode(salaContra);

    socket.abrirSala(jsonString);
  } */

  @override
  Widget build(BuildContext context) {
    socket.connectToServer();

    return Scaffold(
        appBar: AppBar(
          title: Text('Chat encriptado ${nombre}',
              style: TextStyle(fontSize: 20, color: kPrimaryColor)),
          backgroundColor: kBackgroundColor,
          actions: [
            autorizado
                ? IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      setState(() {
                        autorizando = true;
                      });
                      autorizado = false;
                      salaActual.contraAutorizada = "";
                      _messages.forEach((element) {
                        element.autorizado = false;
                      });
                      //delay de tiempo
                      Future.delayed(const Duration(milliseconds: 10), () {
                        setState(() {
                          autorizando = false;
                        });
                      });
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.verified_user, color: kPrimaryColor),
                    onPressed: () {
                      setState(() {
                        autorizando = true;
                      });
                      showDialog(
                          barrierDismissible: false,
                          barrierColor: Colors.black,
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                backgroundColor: kBackgroundColor,
                                title: const Text('Iniciar sesion',
                                    style: TextStyle(color: kPrimaryColor)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Ingrese la contraseña de la sala",
                                      style: TextStyle(color: kPrimaryColor),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      style:
                                          const TextStyle(color: kPrimaryColor),
                                      controller: _ctrlContra,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Contraseña',
                                        labelStyle:
                                            TextStyle(color: kPrimaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              kPrimaryColor),
                                    ),
                                    onPressed: () {
                                      _ctrlContra.clear();
                                      _ctrlSala.clear();
                                      setState(() {
                                        autorizando = false;
                                      });

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancelar',
                                        style: TextStyle(color: kPrimaryColor)),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              kPrimaryColor),
                                    ),
                                    onPressed: () {
                                      _handleAuth(nombre, _ctrlContra.text,
                                          _ctrlContra.text);
                                      if (autorizado) {
                                        _messages.forEach((element) {
                                          element.autorizado = true;
                                          element.hash = mensajeDesencriptado(
                                              element.text, claveSala);
                                        });
                                      }
                                      _ctrlContra.clear();
                                      _ctrlSala.clear();

                                      setState(() {
                                        autorizando = false;
                                      });

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Iniciar sesion',
                                      style: TextStyle(color: kPrimaryColor),
                                    ),
                                  ),
                                ],
                              ));
                    },
                  ),
          ],
        ),
        body: !autorizando
            ? Container(
                color: kBackgroundColor,
                child: Column(
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
                ),
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
      data: const IconThemeData(color: kPrimaryColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                style: const TextStyle(color: kPrimaryColor),
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Enviar un mensaje'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                color: kPrimaryColor,
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
  String hash;
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
      crossAxisAlignment:
          !isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment:
          !isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment:
                !isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              isSentByMe
                  ? Container(
                      margin: const EdgeInsets.only(right: 16.0),
                      child: const CircleAvatar(child: Text('B')),
                    )
                  : Container(),
              isSentByMe
                  ? Container(
                      width: 10,
                    )
                  : Container(),
              Expanded(
                child: Column(
                  crossAxisAlignment: isSentByMe
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 200.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            !isSentByMe ? 'Tú' : 'Otro Usuario',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          Text(hora,
                              style: const TextStyle(color: kPrimaryColor))
                        ],
                      ),
                    ),
                    autorizado
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  hash,
                                  style: const TextStyle(color: kPrimaryColor),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            child: Text(text,
                                style: const TextStyle(color: kPrimaryColor)),
                          ),
                  ],
                ),
              ),
              !isSentByMe
                  ? Container(
                      width: 10,
                    )
                  : Container(),
              !isSentByMe
                  ? Container(
                      margin: const EdgeInsets.only(right: 16.0),
                      child: const CircleAvatar(child: Text('A')),
                    )
                  : Container(),
            ],
          ),
        )
      ],
    );
  }
}

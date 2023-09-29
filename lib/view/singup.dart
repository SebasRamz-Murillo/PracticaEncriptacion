import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:practica_crypt/main.dart';
import 'package:practica_crypt/model/sala.dart';
import 'package:practica_crypt/model/stream.dart';
import 'package:practica_crypt/util/constantes.dart';
import 'package:practica_crypt/util/util.dart';
import 'package:practica_crypt/view/chat.dart';
import 'package:practica_crypt/util/ws.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  List<Sala> salas = [];
  StreamSocket streamSocket = StreamSocket();
  SOCKET socket = SOCKET();

  //controller para contraseña y sala
  TextEditingController _controllerSala = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    socket.connectToServerSalas((p0) {
      List<Sala> dataSalas = [];
      for (var sala in p0) {
        print("Sala: $sala");
        if (sala != null) {
          dataSalas.add(Sala.fromJson(sala));
          print("Sala: ${Sala.fromJson(sala)}");
        } else {
          print("asaas");
        }
      }

      cargarSalas(dataSalas);
    });
  }

  void cargarSalas(List<Sala> salasRecibidas) {
    setState(() {
      salas = salasRecibidas;
    });
  }

  @override
  void dispose() {
    super.dispose();

    streamSocket.dispose(); // Asegúrate de cerrar el StreamController
  }

  @override
  Widget build(BuildContext context) {
    var socketProvider = context.watch<SocketProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: const MediaQueryData(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kBackgroundColor,
            elevation: 0,
          ),
          backgroundColor: kBackgroundColor,
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Lista de Salas activas",
                      style: TextStyle(color: kPrimaryColor, fontSize: 30),
                    ),
                    // Lista de salas
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      width: 300,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (Sala sala in salas)
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        nombre: sala.nombre,
                                        password: sala.password),
                                  ),
                                );
                              },
                              title: Text(
                                sala.nombre,
                                style: const TextStyle(color: kPrimaryColor),
                              ),
                              /* subtitle: Text(
                                sala.password,
                                style: const TextStyle(color: kPrimaryColor),
                              ), */
                            )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Agrega una sala",
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 20),
                          ),
                          TextButton.icon(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  kPrimaryColor),
                            ),
                            onPressed: () {
                              Sala salaNueva = Sala(_controllerSala.text,
                                  encriptar(_controllerPassword.text));
                              socket.abrirSala(salaNueva.toJson().toString());
                              _controllerSala.clear();
                              _controllerPassword.clear();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      nombre: salaNueva.nombre,
                                      password: salaNueva.password),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: kPrimaryColor),
                            label: const Text(
                              'Agregar',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.person_sharp,
                                color: kPrimaryColor,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controllerSala,
                                cursorColor: kPrimaryColor,
                                style: const TextStyle(color: kPrimaryColor),
                                decoration: const InputDecoration(
                                  hintText: 'Nombre de la sala',
                                  hintStyle: TextStyle(color: kPrimaryColor),
                                  labelStyle: TextStyle(
                                      color: kPrimaryColor, fontSize: 20),
                                  counterStyle: TextStyle(
                                      color: kPrimaryColor, fontSize: 20),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kPrimaryColor),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kPrimaryColor),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.lock,
                              color: kPrimaryColor,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controllerPassword,
                              cursorColor: kPrimaryColor,
                              style: const TextStyle(color: kPrimaryColor),
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: kPrimaryColor),
                                labelStyle: TextStyle(
                                    color: kPrimaryColor, fontSize: 20),
                                counterStyle: TextStyle(
                                    color: kPrimaryColor, fontSize: 20),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kPrimaryColor),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kPrimaryColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SOCKET {
  final socket = IO.io("http://localhost:3333", <String, dynamic>{
    //final socket = IO.io("http://192.168.255.42:3333", <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true, // Puedes configurar esto según tus necesidades
  });
  void connectToServer() {
    socket.connect(); // Conecta al servidor
    socket.on('connect', (_) {
      print('Conectado al servidor');
    });
    socket.on('message', (data) {
      print('Mensaje del servidor: $data');
    });
  }

  void connectToServerSalas(Function(dynamic) ack) {
    socket.connect(); // Conecta al servidor
    socket.on('connect', (_) {
      print('Conectado al servidor');
    });
    socket.on('get:salas', (data) {
      print("Si llega a salas");
      ack(data);
    });
  }

  void connectToServerChat(String sala, Function(dynamic) ack) {
    socket.connect(); // Conecta al servidor
    socket.on('connect', (_) {
      print('Conectado al servidor');
    });
    socket.on('get:messages', (data) {
      print("Si llega mensajes");
      ack(data);
    });
    //socket.emit('send:sala', sala);
  }

  disconnect() {
    socket.disconnect();
  }

  mensaje(String mensaje, Function(dynamic) ack) {
    socket.emitWithAck('send:message', mensaje, ack: (data) {
      ack(data);
    });
  }

  recibir(String mensaje, Function(dynamic) ack) {
    socket.on('get:messages', (data) {
      ack(data);
    });
  }

  abrirSala(String sala) {
    socket.emit('send:sala', sala);
  }

  recibirSalas(Function(dynamic) ack) {
    socket.on('get:salas', (data) {
      ack(data);
    });
  }

  socketTest() {
    socket.emitWithAck('send:message', "TESTasa", ack: (data) {
      print('ack $data');
      if (data != null) {
        print('from server $data');
      } else {
        print("Null");
      }
    });
  }
}

import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart' as asymmetric;

String encriptar(String contra) {
  final claveBytes = utf8.encode(contra);
  final hashBytes =
      sha256.convert(claveBytes).bytes; // Generar el hash utilizando SHA-256
  final hash = base64.encode(hashBytes);
  return hash;
}

bool verificarContra(String contra, String hashAlmacenado) {
  final hashIngresado = encriptar(contra);
  return hashIngresado == hashAlmacenado;
}

String mensajeEncriptado(String text, String key) {
  if (key.length < 32) {
    key = key.padRight(32, "0");
  }
  if (text.length > 32) {
    key = key.substring(0, 32);
  }

  final keya = Key.fromUtf8(key);
  final iv = IV
      .fromLength(16); // GENERA EL IV DE 16 BYTES A PARTIR DEL HASH DEL SHA256
  final encrypter = Encrypter(AES(keya));

  final encrypted = encrypter.encrypt(text, iv: iv);
  return encrypted.base64;
}

String mensajeDesencriptado(String encryptedText, String key) {
  if (key.length < 32) {
    key = key.padRight(32, "0");
  }
  final keya = Key.fromUtf8(key);

  final iv = IV.fromLength(1);
  final encrypter = Encrypter(AES(keya));

  final decrypted =
      encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
  return decrypted;
}

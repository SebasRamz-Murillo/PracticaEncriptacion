import 'package:flutter/material.dart';
import 'package:practica_crypt/model/sala.dart';
import 'package:practica_crypt/util/util.dart';

const kBackgroundColor = Color(0xff202020);

const kPrimaryColor = Color(0xff03c03c);

final List<Sala> salasPredefinidas = [
  Sala("Sala 1", encriptar("1234")),
  Sala("Sala 2", encriptar("CONTRA")),
  Sala("Sala 3", encriptar("ADMIN")),
  Sala("Sala 4", encriptar("1234")),
  Sala("Sala 5", encriptar("CONTRA")),
];

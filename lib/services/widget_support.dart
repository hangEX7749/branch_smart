import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle headlineTextFieldStyle() {
    return const TextStyle(
      fontSize: 30.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static TextStyle simpleTextFieldStyle() {
    return const TextStyle(
      fontSize: 18.0,
      color: Colors.black,
    );
  }

  static TextStyle whiteTextFieldStyle() {
    return const TextStyle(
      fontSize: 18.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

    static TextStyle boldWhiteTextFieldStyle() {
    return const TextStyle(
      fontSize: 24.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle boldTextFieldStyle() {
    return const TextStyle(
      fontSize: 20.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle priceTextFieldStyle() {
    return const TextStyle(
      fontSize: 24.0,
      color: Colors.black38,
      fontWeight: FontWeight.bold,
    );
  }
  
  static TextStyle signUpTextFieldStyle() {
    return const TextStyle(
      fontSize: 20.0,
      color: Color.fromARGB(174,0,0,0),
      fontWeight: FontWeight.bold,
    );
  }

}
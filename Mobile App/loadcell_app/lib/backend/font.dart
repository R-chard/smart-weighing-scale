import "package:flutter/material.dart";

class Font extends TextStyle{
  static style(double fontSize, Color color){
    return TextStyle(
      fontFamily: "Monserrat",
      fontSize: fontSize,
      color: color,
    );
  }

}
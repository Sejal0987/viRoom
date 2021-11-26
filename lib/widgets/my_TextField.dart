import 'package:flutter/material.dart';
import 'package:microsoft_app/constant.dart';

class MyTextField extends StatelessWidget {
  MyTextField(
      {this.labelText, this.onChanged, this.hintText, this.obscureText});
  final Function onChanged;
  final String hintText, labelText;
  final bool obscureText;
  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 0.020 * MediaQuery.of(context).size.height,
      ),
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: kInputField.copyWith(
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black54),
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 0.022 * MediaQuery.of(context).size.height,
          fontWeight: FontWeight.w700,
          color: Colors.cyan,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

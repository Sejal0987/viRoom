import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color color;
  RoundButton({this.text, this.onPressed, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.0),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Material(
          color: color,
          elevation: 7.0,
          child: MaterialButton(
            onPressed: onPressed,
            height: 42.0,
            minWidth: 100.0,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MyListTile extends StatelessWidget {
  MyListTile(
      {this.onChanged,
      this.groupValue,
      this.value,
      this.color,
      this.title,
      this.fontSize});
  final Color color;
  final Function onChanged;
  final String title;
  final dynamic value, groupValue;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AutoSizeText(
        title,
        maxLines: 1,
        minFontSize: 5,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
        ),
        textAlign: TextAlign.end,
      ),
      trailing: Radio(
        //   activeColor: Colors.cyan.shade900,
        value: value,
        activeColor: Colors.cyanAccent,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }
}

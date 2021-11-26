import 'package:flutter/material.dart';

class DrawerInkWell extends StatelessWidget {
  final Icon icons;
  final String title, sub;
  final Function onTap;
  DrawerInkWell({this.title, this.onTap, this.icons, this.sub});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icons,
      title: Text(title.toUpperCase()),
      subtitle: sub != '' ? Text(sub) : null,
    );
  }
}

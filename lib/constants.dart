import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/addSongScreen.dart';

const kTextColor = Color(0xFF535353);
const kTextLightColor = Color(0xFFACACAC);
const kGreyDot = Color(0xFFB0B0B0);
const kGreyMenu = Color(0xFFEEEEEE);

const kDefaultPaddin = 20.0;

buildAppBar(navContext) {
  return AppBar(title: Text('My Music'), actions: <Widget>[
    // overflow menu
    PopupMenuButton<Object>(
      onSelected: (value) {
        if(value == 1) {
          Navigator.push(navContext, MaterialPageRoute(builder: (context) => AddSongScreen()));
        }
      },
      itemBuilder: (BuildContext context) {
        var list = List<PopupMenuEntry<Object>>();
        list.add(PopupMenuItem<Object>(
          value: 1,
          child:
          Row(
              children: <Widget> [
                Icon(Icons.add, color: kTextColor,),
                Text('Add Song', style: TextStyle(color: kTextColor),)
              ],
          ),
        ));
        return list;
      },
    ),
  ]);
}
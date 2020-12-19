import 'package:flutter/material.dart';

const kTextColor = Color(0xFF535353);
const kTextLightColor = Color(0xFFACACAC);
const kGreyDot = Color(0xFFB0B0B0);
const kGreyMenu = Color(0xFFEEEEEE);

const kDefaultPaddin = 20.0;

const appName = "MyMusic";

showLoading() {
  return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            )
          ]));
}

buildAppBar(navContext) {
  return AppBar(title: Text(appName), actions: <Widget>[
    // overflow menu
    PopupMenuButton<Object>(
      onSelected: (value) {
        if(value == 1) {
          // Navigator.push(navContext, MaterialPageRoute(builder: (context) => AddSongScreen()));
        }
      },
      itemBuilder: (BuildContext context) {
        var list = List<PopupMenuEntry<Object>>();
        list.add(PopupMenuItem<Object>(
          value: 1,
          child: Text('Add New'),
        ));
        return list;
      },
    ),
  ]);
}
import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/addSongScreen.dart';

const kTextColor = Color(0xFF535353);
const kTextLightColor = Color(0xFFACACAC);
const kGreyDot = Color(0xFFB0B0B0);
const kGreyMenu = Color(0xFFEEEEEE);

const kDefaultPaddin = 20.0;

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
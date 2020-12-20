import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class ArtistItem extends StatelessWidget {
  final String name;
  final String artistImg;

  ArtistItem(this.name, this.artistImg);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Image(
          width: 40,
          image: NetworkImage(this.artistImg),
          fit: BoxFit.contain,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            name,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],

    );
  }
}
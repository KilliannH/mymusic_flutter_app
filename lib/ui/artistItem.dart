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
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: NetworkImage(this.artistImg),
                fit: BoxFit.fill
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            name,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],

    );
  }
}
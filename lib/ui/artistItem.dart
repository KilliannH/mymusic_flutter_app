import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../models/Artist.dart';

class ArtistItem extends StatelessWidget {
  final Artist artist;

  ArtistItem(this.artist);

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
                image: NetworkImage(this.artist.imageUrl),
                fit: BoxFit.fill
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            this.artist.name,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],

    );
  }
}
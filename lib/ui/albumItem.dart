import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../models/Album.dart';
import '../models/Artist.dart';

class AlbumItem extends StatelessWidget {
  final Album album;

  AlbumItem(this.album);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Image(
          image: NetworkImage(this.album.imageUrl),
          fit: BoxFit.contain,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            album.title,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
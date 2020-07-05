import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class SongItem extends StatelessWidget {
  final String songTitle;
  final String songArtist;
  final String songAlbumImg;

  SongItem(this.songTitle, this.songArtist, this.songAlbumImg);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Image(
          image: NetworkImage(this.songAlbumImg),
          fit: BoxFit.contain,
        ),
        Container(
          margin: new EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                songTitle,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                songArtist,
              ),
            ],
          ),
        ),
      ],

    );
  }
}
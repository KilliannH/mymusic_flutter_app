import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../constants.dart';
import '../models/Album.dart';
import '../models/Artist.dart';

class SongItem extends StatelessWidget {
  final String songTitle;
  final List<Artist> songArtists;
  final Album songAlbum;

  SongItem(this.songTitle, this.songArtists, this.songAlbum);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: this.songAlbum != null ? <Widget>[
        Image(
          image: NetworkImage(this.songAlbum.imageUrl),
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
                concatArtists(this.songArtists),
              ),
            ],
          ),
        ),
      ] : <Widget>[
      Container(
      width: 70.0,
      height: 70.0,
      color: Colors.black12,
      child: Icon(Icons.music_note,)),
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
                concatArtists(this.songArtists),
              ),
            ],
          ),
        ),
      ],

    );
  }
}
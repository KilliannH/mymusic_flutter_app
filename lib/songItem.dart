import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mymusicflutterapp/models/Album.dart';
import 'package:mymusicflutterapp/models/Artist.dart';

class SongItem extends StatelessWidget {
  final String songTitle;
  final List<Artist> songArtists;
  final Album songAlbum;

  SongItem(this.songTitle, this.songArtists, this.songAlbum);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
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
                _concatArtists(this.songArtists),
              ),
            ],
          ),
        ),
      ],

    );
  }

  _concatArtists(List<Artist> artists) {
    var text = "";
    var index = 0;
    artists.forEach((artist) {
      if (index < artists.length -1) {
        text += artist.name + ", ";
      } else {
        text += artist.name;
      }
      index++;
    });
    return text;
  }
}
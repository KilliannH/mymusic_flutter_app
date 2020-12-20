import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class PlaylistItem extends StatelessWidget {
  final String name;
  final int numberOfSongs;
  final List<String> fourFirstAlbumImages;

  PlaylistItem(this.name, this.numberOfSongs, this.fourFirstAlbumImages);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        Image(
        image: NetworkImage(this.fourFirstAlbumImages[0]),
        fit: BoxFit.contain,
        ),
        Container(
          margin: new EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(fontSize: 18),
              ),
              Text('$numberOfSongs songs'),
            ],
          ),
        ),
      ],

    );
  }
}
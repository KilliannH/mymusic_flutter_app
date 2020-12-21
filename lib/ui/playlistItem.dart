import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class PlaylistItem extends StatelessWidget {
  final String name;
  final int nbSongs;
  final List<String> firstFourAlbumImages;

  PlaylistItem(this.name, this.nbSongs, this.firstFourAlbumImages);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        _buildImageWidget(),
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
              Text('$nbSongs songs'),
            ],
          ),
        ),
      ],
    );
  }

  _buildImageWidget() {
    return Container(
        width: 80.0,
        height: 80.0,
        decoration: new BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle
        )
    );
  }
}
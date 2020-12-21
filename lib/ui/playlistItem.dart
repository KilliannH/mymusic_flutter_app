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
    if(this.firstFourAlbumImages.length == 0) {
      return Container(
        width: 70.0,
        height: 70.0,
        color: Colors.black12,
        child: Icon(Icons.music_note,)
      );
    } else if(this.firstFourAlbumImages.length == 1) {
      return Container(
          width: 70.0,
          height: 70.0,
          color: Colors.black12,
          child: Image(
              image: NetworkImage(this.firstFourAlbumImages[0]),
          ),
      );
    } else if(this.firstFourAlbumImages.length == 2) {
      return Container(
        width: 70.0,
        height: 70.0,
        child: Row(
          children: [
            Container(
              color: Colors.red,
              width: 35,
              height: 70,
              child: Image(
                image: NetworkImage(this.firstFourAlbumImages[0]),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: Colors.green,
              width: 35,
              height: 70,
              child: Image(
                image: NetworkImage(this.firstFourAlbumImages[1]),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      );
    } else if(this.firstFourAlbumImages.length == 3) {
      return Container(
        width: 70.0,
        height: 70.0,
        child: Row(
          children: [
            Container(
              color: Colors.red,
              width: 35,
              height: 70,
              child: Image(
                image: NetworkImage(this.firstFourAlbumImages[0]),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: Colors.green,
              width: 35,
              height: 70,
              child: Image(
                image: NetworkImage(this.firstFourAlbumImages[1]),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      );
    }
  }
}


import 'package:flutter/material.dart';
import '../../models/Artist.dart';

class RelatedArtists extends StatefulWidget {
  final List<Artist> artists;

  RelatedArtists({Key key, this.artists}): super(key: key);

  @override
  _SongRelatedArtistsState createState() => _SongRelatedArtistsState();
}

class _SongRelatedArtistsState extends State<RelatedArtists> {
  @override
  Widget build(BuildContext context) {
    return _buildArtistList(this.widget.artists, context);
  }

  _buildArtistList(artists, context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: artists.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              width: 62,
              height: 62,
              child: _buildArtistRelItem(artists[index]),
            ),
            onTap: () {
              setState(() {
                artists[index].selected = !artists[index].selected;
              });
            });
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  _buildArtistRelItem(artist) {
    return Row(
      children: artist.selected
          ? <Widget>[
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: NetworkImage(artist.imageUrl), fit: BoxFit.fill),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            artist.name,
            style: TextStyle(fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Icon(
            Icons.check,
            color: Colors.pink,
          ),
        ),
      ]
          : <Widget>[
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: NetworkImage(artist.imageUrl), fit: BoxFit.fill),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            artist.name,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}

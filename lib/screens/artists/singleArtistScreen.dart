import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/models/Song.dart';
import 'package:mymusicflutterapp/services/dataService.dart';
import '../../constants.dart';
import '../../models/Artist.dart';

// When we are on this screen we want Songs from it, i mean songs from an Artist
// but in Song format not in related song. Bcs on related one, we don't have artists data directly
class SingleArtistScreen extends StatefulWidget {

  final Artist artist;

  @override
  State<StatefulWidget> createState() {
    return _SingleArtistScreenState();
  }

  SingleArtistScreen(this.artist);
}

class _SingleArtistScreenState extends State<SingleArtistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: buildDrawer(context),
          ),
        ),
        body: FutureBuilder<dynamic>(
          future: DataService.getSongsByArtistIds([widget.artist.id]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              List songs = snapshot.data;
              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: songs.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    child: Container(
                      height: 70,
                      child: Text(
                        songs[index].title,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    onTap: () => {},
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              );
            } else if (snapshot.hasError) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).errorColor,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ]));
            } else {
              return showLoading();
            }
          },
        )
    );
  }
}

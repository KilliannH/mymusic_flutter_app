import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/Artist.dart';

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
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Welcome to ' + appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.music_note),
                title: Text('Songs'),
              ),
              ListTile(
                leading: Icon(Icons.library_music),
                title: Text('Albums'),
              ),
              ListTile(
                leading: Icon(Icons.people_alt_rounded),
                title: Text('Artists'),
                onTap: () => {},
              ),
            ],
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: widget.artist.songs.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
                child: Container(
                  height: 70,
                  child: Text(
                    widget.artist.songs[index].title,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                onTap: () => {},
            );
          },
          separatorBuilder: (BuildContext context,
              int index) => const Divider(),
        )
    );
  }

}
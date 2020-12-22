import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/managers/pathManager.dart';
import 'package:mymusicflutterapp/screens/playlists/playlistsScreen.dart';
import 'main.dart';
import 'models/Artist.dart';
import 'screens/artists/artistsScreen.dart';

const kTextColor = Color(0xFF535353);
const kTextLightColor = Color(0xFFACACAC);
const kGreyDot = Color(0xFFB0B0B0);
const kGreyMenu = Color(0xFFEEEEEE);

const kDefaultPaddin = 20.0;

const appName = "My Music";

concatArtists(List<Artist> artists) {
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
  if(text == "") {
    text = "Unknown";
  }
  return text;
}

showLoading() {
  return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            )
          ]));
}

buildAppBar(navContext) {
  return AppBar(title: Text(appName));
}

buildDrawer(context, currPath) {
  return [
    DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.lightBlue,
      ),
      child: Text(
        appName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    ),
    ListTile(
      leading: Icon(Icons.music_note),
      title: Text('Songs'),
      onTap: () => PathManager.getCurrPath() == 'Songs' ? Navigator.pop(context) : Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp())),
    ),
    ListTile(
      leading: Icon(Icons.library_music),
      title: Text('Playlists'),
      onTap: () => PathManager.getCurrPath() == 'Playlists' ? Navigator.pop(context) : Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistsScreen())),
    ),
    ListTile(
      leading: Icon(Icons.image),
      title: Text('Albums'),
    ),
    ListTile(
      leading: Icon(Icons.people_alt_rounded),
      title: Text('Artists'),
      onTap: () => PathManager.getCurrPath() == 'Artists' ? Navigator.pop(context) : Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistsScreen())),
    )
  ];
}
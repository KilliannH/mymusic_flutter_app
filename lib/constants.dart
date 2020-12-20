import 'package:flutter/material.dart';
import 'main.dart';
import 'screens/artists/artistsScreen.dart';

const kTextColor = Color(0xFF535353);
const kTextLightColor = Color(0xFFACACAC);
const kGreyDot = Color(0xFFB0B0B0);
const kGreyMenu = Color(0xFFEEEEEE);

const kDefaultPaddin = 20.0;

const appName = "My Music";

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
  return AppBar(title: Text(appName), actions: <Widget>[
    // overflow menu
    PopupMenuButton<Object>(
      onSelected: (value) {
        if(value == 1) {
          // Navigator.push(navContext, MaterialPageRoute(builder: (context) => AddSongScreen()));
        }
      },
      itemBuilder: (BuildContext context) {
        var list = List<PopupMenuEntry<Object>>();
        list.add(PopupMenuItem<Object>(
          value: 1,
          child: Text('Add New'),
        ));
        return list;
      },
    ),
  ]);
}

buildDrawer(context, currPath) {
  return [
    DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
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
      onTap: () => currPath == 'Songs' ? null : Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp())),
    ),
    ListTile(
      leading: Icon(Icons.library_music),
      title: Text('Albums'),
    ),
    ListTile(
      leading: Icon(Icons.people_alt_rounded),
      title: Text('Artists'),
      onTap: () => currPath == 'Artists' ? null : Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistsScreen())),
    )
  ];
}
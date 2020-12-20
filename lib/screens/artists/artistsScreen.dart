import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymusicflutterapp/screens/artists/singleArtistScreen.dart';
import 'package:mymusicflutterapp/services/dataService.dart';
import 'package:mymusicflutterapp/ui/artistItem.dart';
import 'package:securedplayerflutterplugin/securedplayerflutterplugin.dart';
import '../../constants.dart';
import '../../models/Artist.dart';
import '../../models/Song.dart';

class ArtistsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ArtistsScreenState();
  }

  ArtistsScreen();
}

class _ArtistsScreenState extends State<ArtistsScreen> {

  final limit = { 'start': 0, 'end': 40 };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: buildDrawer(context)
          ),
        ),
        body: FutureBuilder<dynamic>(
        future: DataService.getArtists(limit),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (snapshot.hasData) {
      List artists = snapshot.data;
      return _buildArtistList(artists, context);
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
    ),
    );
  }

  _buildArtistList(artists, context) {
    return ListView.separated(
        padding: const EdgeInsets.all(8),
    itemCount: artists.length,
    itemBuilder: (BuildContext context, int index) {
    return InkWell(
    child: Container(
    child: ArtistItem(artists[index].name, artists[index].imageUrl),
    ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SingleArtistScreen(artists[index])))
    );
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
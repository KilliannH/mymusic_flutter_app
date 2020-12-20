import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../managers/pathManager.dart';
import '../../services/dataService.dart';
import '../../ui/artistItem.dart';
import '../../constants.dart';

class PlaylistsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PlaylistsScreenState();
  }

  PlaylistsScreen();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final limit = {'start': 0, 'end': 40};

  @override
  void initState() {
    PathManager.setCurrPath('Playlists');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: Drawer(
        child:
            ListView(padding: EdgeInsets.zero, children: buildDrawer(context, 'Artists')),
      ),
      body: FutureBuilder<dynamic>(
        future: DataService.getArtists(limit),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            List artists = snapshot.data;
            return Center();//_buildArtistList(artists, context);
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

  /*_buildArtistList(artists, context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: artists.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              child: ArtistItem(artists[index].name, artists[index].imageUrl),
            ),
            onTap: () => /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SingleArtistScreen(artists[index]))));*/
        {},
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }*/
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/models/Song.dart';
import 'package:mymusicflutterapp/ui/playlistItem.dart';
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
  final limit = {'start': 0, 'end': 20};

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
        future: DataService.getPlaylists(limit),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            List playlists = snapshot.data;
            return _buildPlaylists(playlists, context);
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

  _buildPlaylists(playlists, context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: playlists.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              height: 70,
              child: PlaylistItem(playlists[index].name, playlists[index].songs.length, _getFirstFourSongsImg(playlists[index].songs)),
            ),
            onTap: () => null
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  List<String> _getFirstFourSongsImg(List<Song> songs) {
    List<String> imageUrls = new List<String>();
    for(int i = 0; i < (songs.length > 4 ? 4 : songs.length); i++) {
      imageUrls.add(songs[i].album.imageUrl);
    }
    return imageUrls;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/screens/add/addAlbumScreen.dart';
import '../../managers/pathManager.dart';
import 'singleAlbumScreen.dart';
import '../../services/dataService.dart';

import '../../constants.dart';

class AlbumsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AlbumsScreenState();
  }

  AlbumsScreen();
}

class _AlbumsScreenState extends State<AlbumsScreen> {

  bool _loadingState = false;

  Future<List<dynamic>> _getAllArtistsAndSongs() async {
    List responses;
    try {
      responses = await Future.wait(
          [DataService.getAllArtists(), DataService.getAllSongs()]);
    } catch (e) {
      return Future.error(e);
    }
    return responses;
  }

  @override
  void initState() {
    PathManager.setCurrPath('Albums');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: Drawer(
        child:
            ListView(padding: EdgeInsets.zero, children: buildDrawer(context)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _loadingState = true;
          });
          var responses = await this._getAllArtistsAndSongs();
          setState(() {
            _loadingState = false;
          });
          return Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddAlbumScreen(artists: responses[0], songs: responses[1],)));
        },
        child: Icon(Icons.add),
      ),
      body: _loadingState ? showLoading() : FutureBuilder<dynamic>(
        future: DataService.getAllAlbums(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            List albums = snapshot.data;
            return _buildAlbumList(albums, context);
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

  _buildAlbumList(albums, context) {
    return CustomScrollView(
      primary: false,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: albums.map<Widget>((album) {
                return InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: 500,
                    height: 500,
                    child: Image(
                      image: NetworkImage(album.imageUrl),
                    ),
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SingleAlbumScreen(album))),
                );
              }).toList(),
          ),
        ),
      ],
    );
  }
}

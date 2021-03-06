import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/screens/add/addArtistScreen.dart';
import '../../managers/pathManager.dart';
import 'singleArtistScreen.dart';
import '../../services/dataService.dart';
import '../../ui/artistItem.dart';
import '../../constants.dart';

class ArtistsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ArtistsScreenState();
  }

  ArtistsScreen();
}

class _ArtistsScreenState extends State<ArtistsScreen> {

  bool _loadingState = false;

  Future<List<dynamic>> _getAllAlbumsAndSongs() async {
    List responses;
    try {
      responses = await Future.wait(
          [DataService.getAllAlbums(), DataService.getAllSongs()]);
    } catch (e) {
      return Future.error(e);
    }
    return responses;
  }

  @override
  void initState() {
    PathManager.setCurrPath('Artists');
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
          var responses = await this._getAllAlbumsAndSongs();
          setState(() {
            _loadingState = false;
          });
          return Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddArtistScreen(albums: responses[0], songs: responses[1],)));
        },
        child: Icon(Icons.add),
      ),
      body: _loadingState ? showLoading() : FutureBuilder<dynamic>(
        future: DataService.getAllArtists(),
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
              child: ArtistItem(artists[index]),
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SingleArtistScreen(artists[index]))));
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

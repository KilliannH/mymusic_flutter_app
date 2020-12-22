import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/screens/add/addSongScreen.dart';
import 'managers/pathManager.dart';
import 'services/dataService.dart';
import 'screens/playerScreen.dart';
import 'ui/songItem.dart';

import 'constants.dart';
import 'models/Song.dart';
// By convention : first import block for all packages, second import for our own files.

void main() {
  runApp(MyApp());
}

// @Required : in a constructor w. name based arguments ({String name, int age = 31});
// required set the argument as required. Here if we don't specify an age, the default value is 31.
// we can avoid extra function body for the constructor ex :

/*
class Person
  String name,
  int age;
  Person({this.name, this.age = 30}); // named based constructor w. Dart assignation shortcut.
 */

// Dart knows that for every instantiated objects, it will pass the name & age property directly from the constructor
// new keyword for instances is not required.
//MyApp() is an instance of MyApp class, we need the parentheses so Dart will not consider it as an argument type.

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final List<String> appRoutes = const ['Albums', 'Artists', 'Add'];
  final limit = { 'start': 0, 'end': 30 };
  bool loadingState = false;

  @override
  void initState() {
    PathManager.setCurrPath('Songs');
    super.initState();
  }

  Future<List<dynamic>> _getAllAlbumsAndArtists() async {
    List responses;
    try {
      responses = await Future.wait(
          [DataService.getAllArtists(), DataService.getAllAlbums()]);
    } catch (e) {
      return Future.error(e);
    }
    return responses;
  }

  @override
  Widget build(BuildContext context) {
    // build method always responsible to return a new Widget.

    return MaterialApp(
        theme: ThemeData(
          // Define the default brightness and colors.
            brightness: Brightness.light,
            primaryColor: Colors.blue,
            accentColor: Colors.amber,
            errorColor: Colors.red,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white,
            backgroundColor: Colors.amber
          )
        ),
      home: Builder(
        builder: (navContext) => Scaffold(
          appBar: buildAppBar(navContext),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: buildDrawer(navContext, 'Songs')
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              setState(() {
                loadingState = true;
              });
              var responses = await this._getAllAlbumsAndArtists();
              return Navigator.push(navContext,
                  MaterialPageRoute(builder: (context) => AddSongScreen(artists: responses[0], albums: responses[1],)));
            },
            child: Icon(Icons.add),
          ),
          body: FutureBuilder<dynamic>(
            future: DataService.getSongs(limit),
            // a previously-obtained Future<dynamic> or null
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if(!loadingState) {
                if (snapshot.hasData) {
                  List<Song> songs = snapshot.data;
                  return _buildSongList(songs, context);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.error_outline,
                              color: Theme
                                  .of(context)
                                  .errorColor,
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
              } else {
                return showLoading();
              }
            },
          ),
        ),
      ),
    );
  }

  _buildSongList(songs, context) {

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              height: 70,
              child: SongItem(songs[index].title, songs[index].artists,
                  songs[index].album),
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(songs[index], songs)))
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
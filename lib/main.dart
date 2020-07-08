import 'package:flutter/material.dart';
import 'package:mymusicflutterapp/services/dataService.dart';
import 'package:mymusicflutterapp/songItem.dart';
import 'package:mymusicflutterapp/playerScreen.dart';

import 'addSongScreen.dart';
import 'constants.dart';
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

  @override
  Widget build(BuildContext context) {
    // build method always responsible to return a new Widget.

    return MaterialApp(
        theme: ThemeData(
          // Define the default brightness and colors.
            brightness: Brightness.light,
            primaryColor: Color(0xFF6002EE),
            accentColor: Color(0xFF90EE02),
        ),
      home: Builder(
        builder: (navContext) => Scaffold(
          appBar: this._buildAppBar(navContext),
          body: FutureBuilder<dynamic>(
            future: DataService.getSongs(),
            // a previously-obtained Future<dynamic> or null
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                List songs = snapshot.data;
                return _buildSongList(songs, context);
              } else if (snapshot.hasError) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          )
                        ]));
              } else {
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
            },
          ),
        ),
      ),
    );
  }

  _buildAppBar(navContext) {
    return AppBar(title: Text('My Music'), actions: <Widget>[
      // overflow menu
      PopupMenuButton<Object>(
        onSelected: (value) {
          if(value == 1) {
          Navigator.push(navContext, MaterialPageRoute(builder: (context) => AddSongScreen()));
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

  _buildSongList(songs, context) {

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              height: 70,
              child: SongItem(songs[index].title, songs[index].artist,
                  songs[index].albumImg),
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(songs[index], songs)))
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
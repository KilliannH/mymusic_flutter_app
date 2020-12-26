import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/Song.dart';
import '../../services/dataService.dart';
import '../../constants.dart';
import '../../models/Artist.dart';
import '../playerScreen.dart';

// When we are on this screen we want Songs from it, i mean songs from an Artist
// but in Song format not in related song. Bcs on related one, we don't have artists data directly
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
        body: FutureBuilder<dynamic>(
          future: DataService.getAllSongsByArtistIds([widget.artist.id]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              List<Song> songs = snapshot.data;
              return Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(widget.artist.imageUrl),
                            fit: BoxFit.fill
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.artist.name,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Divider(),
                    ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: songs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                songs[index].title,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(songs[index], songs))),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    ),
                  ],
                ),
              );
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
        )
    );
  }
}

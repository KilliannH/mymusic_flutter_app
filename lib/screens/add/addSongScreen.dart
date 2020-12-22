import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mymusicflutterapp/main.dart';
import 'package:mymusicflutterapp/models/Artist.dart';
import '../../ui/albumItem.dart';
import '../../models/Album.dart';
import '../../models/Song.dart';
import '../../services/dataService.dart';
import '../../constants.dart';

class AddSongScreen extends StatefulWidget {
  AddSongScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddSongScreenState();
  }
}

class _AddSongScreenState extends State<AddSongScreen> {
  var _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), null, null];
  final limit = {'start': 0, 'end': 30};

  bool _loadingState = false;
  // todo -- remove this: dev path
  int _index = 2;
  int numberOfSteps = 5;
  List<Widget> formList;

  Song newSong = new Song();
  String ytUrl;

  _getDots() {
    final List<Widget> widgets = [];
    for (int i = 0; i < numberOfSteps; i++) {
      widgets.add(ColorDot(color: Colors.blue, isSelected: _index == i));
    }
    return widgets.toList();
  }

  _toggleNextStep(GlobalKey<FormState> formKey) {
    if (formKey != null && formKey.currentState.validate()) {
      _index++;
    } else if (_index >= 2) {
      _index++;
    }
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
    return Scaffold(
        appBar: buildAppBar(context),
        body: FutureBuilder<dynamic>(
            // a previously-obtained Future<dynamic> or null
            // we want to obtain all artists here as we don't want the artistRel widget to refresh his artists data
            // when we toggle selected.
            future: _getAllAlbumsAndArtists(),
            builder:
                (BuildContext navContext, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                var artists = snapshot.data[0];
                var albums = snapshot.data[1];
                formList = [
                  _buildFirstForm(),
                  _buildSecondForm(navContext),

                  // here we want to update _index wich is in the parent widget (this)
                  // there is no need to recall the widget like _AddSongScreenState() bcs it will not reffer to this.
                  SongRelatedAlbum(this, albums),
                  SongRelatedArtists(this, artists),
                  Center(),
                ];
                return Column(
                    children: [_buildStepperDots(), formList[_index]]);
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
            }));
  }

  _buildFirstForm() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              initialValue: newSong.title != null ? newSong.title : null,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a title';
                } else {
                  newSong.title = value.trim();
                  return null;
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              initialValue: newSong.filename != null ? newSong.filename : null,
              decoration: const InputDecoration(
                hintText: 'Filename',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a filename';
                } else {
                  newSong.filename = value.trim();
                  return null;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildSecondForm(BuildContext _context) {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              initialValue: ytUrl != null ? ytUrl : null,
              decoration: const InputDecoration(
                hintText: 'Youtube Url',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter the youtube url';
                } else {
                  ytUrl = value.trim();
                  return null;
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    // no need to check the _formKey[0] bcs it has been checked when clicking on NEXT button
                    onPressed: () {
                      if (_formKeys[1].currentState.validate()) {
                        setState(() {
                          _loadingState = true;
                        });
                        /*DataService.postSong(newSong).then((response) {
                                if (response.statusCode == 200) { */
                        _showContinueDialog(_context);
                        //}
                        //}); /* successfully added song...  after a spinner*///);
                      }
                    },
                    child: Text('Submit'.toUpperCase()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showContinueDialog(navContext) async {
    return showDialog<void>(
      context: navContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Song added successfully'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to continue with relationships?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.push(navContext,
                    MaterialPageRoute(builder: (context) => MyApp()));
              },
            ),
            RaisedButton(
              child: Text('OK'),
              color: Colors.deepPurple,
              onPressed: () {
                _index++;
                setState(() {
                  _loadingState = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _buildStepperDots() {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: _index == 1 || _index == 3
                ? () => setState(() {
                      _index--;
                    })
                : null,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.keyboard_arrow_left,
                  color: _index == 1 || _index == 3 ? kTextColor : Colors.grey,
                ),
                Text(
                  'Back'.toUpperCase(),
                  style: TextStyle(
                      color: _index == 1 || _index == 3
                          ? kTextColor
                          : Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: _getDots(),
          ),
          FlatButton(
            onPressed: _index < _formKeys.length - 1
                ? () => setState(() {
                      _toggleNextStep(_formKeys[_index]);
                    })
                : null,
            child: Row(
              children: <Widget>[
                Text(
                  'Next'.toUpperCase(),
                  style: TextStyle(
                      color: _index < _formKeys.length - 1
                          ? kTextColor
                          : Colors.grey),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color:
                      _index < _formKeys.length - 1 ? kTextColor : Colors.grey,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  const ColorDot({
    Key key,
    this.color,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: kDefaultPaddin / 4,
        right: kDefaultPaddin / 2,
      ),
      padding: EdgeInsets.all(2.5),
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: isSelected ? color : kGreyDot, shape: BoxShape.circle),
      ),
    );
  }
}

class SongRelatedAlbum extends StatefulWidget {
  final _AddSongScreenState parent;
  final List<Album> albums;
  final limit = {'start': 0, 'end': 30};

  SongRelatedAlbum(this.parent, this.albums);

  @override
  _SongRelatedAlbumState createState() => _SongRelatedAlbumState();
}

class _SongRelatedAlbumState extends State<SongRelatedAlbum> {
  @override
  Widget build(BuildContext context) {
    return _buildAlbumList(this.widget.albums, context);
  }

  _buildAlbumList(albums, context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: albums.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              height: 40,
              child: _buildAlbumRelItem(albums[index]),
            ),
            onTap: () {
              /*this.widget.parent.setState(() {
              this.widget.parent.newSong.album = albums[index];
            });*/
              setState(() {
                albums.forEach((album) {
                  if (album.selected && album.id != albums[index].id) {
                    album.selected = false;
                  }
                });
                albums[index].selected = !albums[index].selected;
              });
            });
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  _buildAlbumRelItem(album) {
    return Row(
        children: album.selected
            ? <Widget>[
                Image(
                  image: NetworkImage(album.imageUrl),
                  fit: BoxFit.contain,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    album.title,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Icon(
                    Icons.check,
                    color: Colors.pink,
                  ),
                ),
              ]
            : <Widget>[
                Image(
                  image: NetworkImage(album.imageUrl),
                  fit: BoxFit.contain,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    album.title,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ]
    );
  }
}

class SongRelatedArtists extends StatefulWidget {
  final _AddSongScreenState parent;
  final List<Artist> artists;

  SongRelatedArtists(this.parent, this.artists);

  @override
  _SongRelatedArtistsState createState() => _SongRelatedArtistsState();
}

class _SongRelatedArtistsState extends State<SongRelatedArtists> {
  @override
  Widget build(BuildContext context) {
    return _buildArtistList(this.widget.artists, context);
  }

  _buildArtistList(artists, context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: artists.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              width: 62,
              height: 62,
              child: _buildArtistRelItem(artists[index]),
            ),
            onTap: () {
              /*this.widget.parent.setState(() {
                if(this.widget.parent.newSong.artists == null) {
                  this.widget.parent.newSong.artists = new List<Artist>();
                }
                this.widget.parent.newSong.artists.add(artists[index]);
              });*/
              setState(() {
                artists[index].selected = !artists[index].selected;
              });
            });
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  _buildArtistRelItem(artist) {
    return Row(
      children: artist.selected
          ? <Widget>[
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(artist.imageUrl), fit: BoxFit.fill),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  artist.name,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Icon(
                  Icons.check,
                  color: Colors.pink,
                ),
              ),
            ]
          : <Widget>[
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(artist.imageUrl), fit: BoxFit.fill),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  artist.name,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mymusicflutterapp/main.dart';
import 'package:mymusicflutterapp/models/Artist.dart';

import '../../models/Album.dart';
import '../../models/Song.dart';
import '../../services/dataService.dart';
import '../../constants.dart';

class AddAlbumScreen extends StatefulWidget {

  final List<Artist> artists;
  final List<Song> songs;
  AddAlbumScreen({Key key, this.artists, this.songs}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddAlbumScreenState();
  }
}

class _AddAlbumScreenState extends State<AddAlbumScreen> {

  final _textEditingTitleController = TextEditingController();
  final _textEditingImageUrlController = TextEditingController();

  BuildContext _context;

  bool _loadingState = false;
  int _index = 0;
  int numberOfSteps = 4;
  List<Widget> formList;

  String albumJsonStr = "";

  Album newAlbum = new Album();

  _getDots() {
    final List<Widget> widgets = [];
    for (int i = 0; i < numberOfSteps; i++) {
      widgets.add(ColorDot(color: Colors.blue, isSelected: _index == i));
    }
    return widgets.toList();
  }


  _onFirstFormSubmit() {
    bool _submitReady = true;
    if(_textEditingTitleController.value.text != null && _textEditingTitleController.value.text != "") {
      newAlbum.title = _textEditingTitleController.value.text;
    } else {
      _submitReady = false;
      Scaffold
          .of(_context)
          .showSnackBar(SnackBar(content: Text('Error: title must be completed')));
    }

    if(_textEditingImageUrlController.value.text != null && _textEditingImageUrlController.value.text != "") {
      newAlbum.imageUrl = _textEditingImageUrlController.value.text;
    } else {
      _submitReady = false;
      Scaffold
          .of(_context)
          .showSnackBar(SnackBar(content: Text('Error: image url must be completed')));
    }
    return _submitReady;
  }

  _toggleNextStep() {
    if (_index >= 1) {
      if(_index == 3) {
        setState(() {
          albumJsonStr = newAlbum.toJson();
        });
      }
      _index++;
    }
  }

  @override
  void initState() {
    formList = [
      _buildFirstForm(),

      // here we want to update _index witch is in the parent widget (this)
      // there is no need to recall the widget like _AddSongScreenState() bcs it will not reffer to this.
      AlbumRelatedArtists(key: UniqueKey(), parent: this, artists: this.widget.artists),
      AlbumRelatedSongs(key: UniqueKey(), parent: this, songs: widget.songs),
      _buildValidateStep(),
    ];
    _loadingState = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Builder(
            builder: (BuildContext navContext) {
              _context = navContext;
              return _loadingState ? showLoading() : Column(
                  children: [_buildStepperDots(), formList[_index]]);
            }
        )
    );
  }

  _buildFirstForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              controller: _textEditingTitleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              controller: _textEditingImageUrlController,
              decoration: const InputDecoration(
                hintText: 'Image Url',
              ),
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
                      if (_onFirstFormSubmit()) {
                        setState(() {
                          _loadingState = true;
                        });
                        DataService.newAlbum(newAlbum).then((response) {
                          print(response.statusCode.toString() + " " + response.body.toString());
                          if (response.statusCode == 200) {
                            var albumJson = jsonDecode(response.body);
                            setState(() {
                              newAlbum = Album.fromJson(albumJson);
                              _showContinueDialog();
                            });
                            print(newAlbum.toString());
                          }
                        }); /* successfully added artist...  after a spinner*///);
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

  Future<void> _showContinueDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Album added successfully!'),
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
                setState(() {
                  _loadingState = false;
                });
                Navigator.push(context,
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
            onPressed: _index == 3 || _index == 4
                ? () => setState(() {
              _index--;
            })
                : null,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.keyboard_arrow_left,
                  color: _index == 3 ||_index == 4 ? kTextColor : Colors.grey,
                ),
                Text(
                  'Back'.toUpperCase(),
                  style: TextStyle(
                      color: _index == 3 || _index == 4
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
            onPressed: _index > 0 && _index < formList.length - 1
                ? () => setState(() {
              _toggleNextStep();
            })
                : null,
            child: Row(
              children: <Widget>[
                Text(
                  'Next'.toUpperCase(),
                  style: TextStyle(
                      color: _index > 0 && _index < formList.length - 1
                          ? kTextColor
                          : Colors.grey),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color:
                  _index > 0 && _index < formList.length - 1 ? kTextColor : Colors.grey,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildValidateStep() {
    return Column(
      children: [
        Padding(padding: EdgeInsets.all(16), child: Text(albumJsonStr, style: TextStyle(fontSize: 12),)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RaisedButton(
              onPressed: () async {
                setState(() {
                  _loadingState = true;
                });
                List<Future> futures;
                if(newAlbum.artists != null) {
                  newAlbum.artists.forEach((artist) {
                    futures.add(
                        DataService.newAlbumArtist(newAlbum.id, artist.id));
                  });
                }

                if(newAlbum.songs != null) {
                  newAlbum.songs.forEach((song) {
                    futures.add(DataService.newAlbumSong(newAlbum.id, song.id));
                  });
                }
                try {
                  await Future.wait(futures);
                } catch (e) {
                  return Future.error(e);
                }
                Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: Text('Relations added successfully!')));
                return MaterialPageRoute(builder: (context) => MyApp());
              }, child: Text('Submit'.toUpperCase())),
        ),
      ],
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

class AlbumRelatedArtists extends StatefulWidget {
  final _AddAlbumScreenState parent;
  final List<Artist> artists;

  AlbumRelatedArtists({Key key, this.parent, this.artists}): super(key: key);

  @override
  _AlbumRelatedArtistsState createState() => _AlbumRelatedArtistsState();
}

class _AlbumRelatedArtistsState extends State<AlbumRelatedArtists> {
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
              setState(() {
                artists[index].selected = !artists[index].selected;
              });
              this.widget.parent.setState(() {
                if(this.widget.parent.newAlbum.artists == null) {
                  this.widget.parent.newAlbum.artists = new List<Artist>();
                }
                if(artists[index].selected) {
                  if (this.widget.parent.newAlbum.artists.indexOf(
                      artists[index]) == -1) {
                    this.widget.parent.newAlbum.artists.add(artists[index]);
                  }
                } else {
                  if (this.widget.parent.newAlbum.artists.indexOf(
                      artists[index]) != -1) {
                    this.widget.parent.newAlbum.artists.remove(artists[index]);
                  }
                }
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

class AlbumRelatedSongs extends StatefulWidget {
  final _AddAlbumScreenState parent;
  final List<Song> songs;

  AlbumRelatedSongs({Key key, this.parent, this.songs}): super(key: key);

  @override
  _AlbumRelatedSongsState createState() => _AlbumRelatedSongsState();
}

class _AlbumRelatedSongsState extends State<AlbumRelatedSongs> {
  @override
  Widget build(BuildContext context) {
    return _buildSongList(this.widget.songs, context);
  }

  _buildSongList(songs, context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              width: 62,
              height: 62,
              child: _buildSongRelItem(songs[index]),
            ),
            onTap: () {
              setState(() {
                songs[index].selected = !songs[index].selected;
              });
              this.widget.parent.setState(() {
                if(this.widget.parent.newAlbum.songs == null) {
                  this.widget.parent.newAlbum.songs = new List<Song>();
                }
                if(songs[index].selected) {
                  if (this.widget.parent.newAlbum.songs.indexOf(
                      songs[index]) == -1) {
                    this.widget.parent.newAlbum.songs.add(songs[index]);
                  }
                } else {
                  if (this.widget.parent.newAlbum.songs.indexOf(
                      songs[index]) != -1) {
                    this.widget.parent.newAlbum.songs.remove(songs[index]);
                  }
                }
              });
            });
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  _buildSongRelItem(song) {
    return Row(
        children: song.selected
            ? <Widget>[
          song.album != null ? Image(
            image: NetworkImage(song.album.imageUrl),
            fit: BoxFit.contain,
          ):
          Container(
            width: 70.0,
            height: 70.0,
            color: Colors.black12,
            child: Icon(Icons.music_note,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              song.title,
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
    song.album != null ? Image(
    image: NetworkImage(song.album.imageUrl),
    fit: BoxFit.contain,
    ):
    Container(
    width: 70.0,
    height: 70.0,
    color: Colors.black12,
    child: Icon(Icons.music_note,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              song.title,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ]
    );
  }
}

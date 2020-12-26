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

class AddSongScreen extends StatefulWidget {

  final List<Album> albums;
  final List<Artist> artists;
  AddSongScreen({Key key, this.albums, this.artists}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddSongScreenState();
  }
}

class _AddSongScreenState extends State<AddSongScreen> {

  final _textEditingTitleController = TextEditingController();
  final _textEditingFilenameController = TextEditingController();
  final _textEditingYoutubeIdController = TextEditingController();

  BuildContext _context;

  bool _loadingState = false;
  int _index = 0;
  int numberOfSteps = 5;
  List<Widget> formList;

  String songJsonStr = "";

  Song newSong = new Song();
  String youtubeId;

  _getDots() {
    final List<Widget> widgets = [];
    for (int i = 0; i < numberOfSteps; i++) {
      widgets.add(ColorDot(color: Colors.blue, isSelected: _index == i));
    }
    return widgets.toList();
  }

  _toggleNextStep() {

    if(_index == 0) {
      // check values
      if(_textEditingTitleController.value.text != null && _textEditingTitleController.value.text != "") {
        newSong.title = _textEditingTitleController.value.text;
      } else {
        return Scaffold
            .of(_context)
            .showSnackBar(SnackBar(content: Text('Error: title must be completed')));
      }

      if(_textEditingFilenameController.value.text != null && _textEditingFilenameController.value.text != "") {
        newSong.filename = _textEditingFilenameController.value.text;
      } else {
        return Scaffold
            .of(_context)
            .showSnackBar(SnackBar(content: Text('Error: filename must be completed')));
      }
      if(youtubeId != null) {
        _textEditingYoutubeIdController.value = TextEditingValue(text: youtubeId);
      }
      _index++;
    } else if (_index >= 2) {
      if(_index == 4) {
        setState(() {
          songJsonStr = newSong.toJson();
        });
      }
      _index++;
    }
  }

  @override
  void initState() {
    formList = [
      _buildFirstForm(),
      _buildSecondForm(),

      // here we want to update _index witch is in the parent widget (this)
      // there is no need to recall the widget like _AddSongScreenState() bcs it will not reffer to this.
      SongRelatedAlbum(key: UniqueKey(), parent: this, albums: this.widget.albums),
      SongRelatedArtists(key: UniqueKey(), parent: this, artists: widget.artists),
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
              controller: _textEditingFilenameController,
              decoration: const InputDecoration(
                hintText: 'Filename',
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildSecondForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              controller: _textEditingYoutubeIdController,
              decoration: const InputDecoration(
                hintText: 'Youtube Id',
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
                      if (_textEditingYoutubeIdController.value.text != null && _textEditingYoutubeIdController.value.text != "") {
                        setState(() {
                          youtubeId = _textEditingYoutubeIdController.value.text;
                          _loadingState = true;
                        });
                        DataService.newSong(newSong).then((response) {
                          print(response.statusCode.toString() + " " + response.body.toString());
                                if (response.statusCode == 200) {
                                  var songJson = jsonDecode(response.body);
                                  setState(() {
                                    newSong = Song.fromJson(songJson);
                                  });
                                  print(newSong.toString());
                                  print(youtubeId);
                                  DataService.downloadSong(newSong, youtubeId).then((response) {
                                    print(response.statusCode.toString() + " " + response.body.toString());
                                    if (response.statusCode == 200) {
                                      _showContinueDialog();
                                    }
                                  });
                                }
                        }); /* successfully added song...  after a spinner*///);
                      } else {
                        return Scaffold
                            .of(_context)
                            .showSnackBar(SnackBar(content: Text('Error: youtubeId must be completed.')));
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
          title: Text('Song added successfully!'),
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
            onPressed: _index == 1 || _index == 3 || _index == 4
                ? () => setState(() {
                  if(_index == 1) {
                    if(newSong.title != null) {
                      setState(() {
                        _textEditingTitleController.value = TextEditingValue(text: newSong.title);
                      });
                    }
                    if(newSong.filename != null) {
                      _textEditingFilenameController.value = TextEditingValue(text: newSong.filename);
                    }
                  }
                  _index--;
                })
                : null,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.keyboard_arrow_left,
                  color: _index == 1 || _index == 3 ||_index == 4 ? kTextColor : Colors.grey,
                ),
                Text(
                  'Back'.toUpperCase(),
                  style: TextStyle(
                      color: _index == 1 || _index == 3 || _index == 4
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
            onPressed: _index < formList.length - 1
                ? () => setState(() {
                      _toggleNextStep();
                    })
                : null,
            child: Row(
              children: <Widget>[
                Text(
                  'Next'.toUpperCase(),
                  style: TextStyle(
                      color: _index < formList.length - 1
                          ? kTextColor
                          : Colors.grey),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color:
                      _index < formList.length - 1 ? kTextColor : Colors.grey,
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
        Padding(padding: EdgeInsets.all(16), child: Text(songJsonStr, style: TextStyle(fontSize: 12),)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RaisedButton(
              onPressed: () async {
          setState(() {
            _loadingState = true;
          });
          await DataService.newSongAlbum(newSong.id, newSong.album.id);
          List<Future> futures;
          newSong.artists.forEach((artist) {
            futures.add(DataService.newSongArtist(newSong.id, artist.id));
          });
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

class SongRelatedAlbum extends StatefulWidget {
  final _AddSongScreenState parent;
  final List<Album> albums;
  final limit = {'start': 0, 'end': 30};

  SongRelatedAlbum({Key key, this.parent, this.albums}): super(key: key);

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
              height: 62,
              child: _buildAlbumRelItem(albums[index]),
            ),
            onTap: () {
              setState(() {
                albums.forEach((album) {
                  if (album.selected && album.id != albums[index].id) {
                    album.selected = false;
                  }
                });
                albums[index].selected = !albums[index].selected;
              });
              this.widget.parent.setState(() {
                this.widget.parent.newSong.album = albums[index];
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

  SongRelatedArtists({Key key, this.parent, this.artists}): super(key: key);

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
              setState(() {
                artists[index].selected = !artists[index].selected;
              });
              this.widget.parent.setState(() {
                if(this.widget.parent.newSong.artists == null) {
                  this.widget.parent.newSong.artists = new List<Artist>();
                }
                if(artists[index].selected) {
                  if (this.widget.parent.newSong.artists.indexOf(
                      artists[index]) == -1) {
                    this.widget.parent.newSong.artists.add(artists[index]);
                  }
                } else {
                  if (this.widget.parent.newSong.artists.indexOf(
                      artists[index]) != -1) {
                    this.widget.parent.newSong.artists.remove(artists[index]);
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

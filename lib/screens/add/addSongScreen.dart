import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../models/Album.dart';
import '../../models/Song.dart';
import '../../services/dataService.dart';
import 'package:securedplayerflutterplugin/securedplayerflutterplugin.dart';
import '../../constants.dart';
import '../../models/Song.dart';

class AddSongScreen extends StatefulWidget {
  AddSongScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddSongScreenState();
  }
}

class AddSongScreenState extends State<AddSongScreen> {
  var _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];

  bool _loadingState = false;
  int _index = 2;
  int numberOfSteps = 2;
  List<Widget> formList;

  Song newSong = new Song();
  String ytUrl;

  Future<List<String>> _getAlbumNames() async {
    List<Album> albums = await DataService.getAlbums();
    return albums.map((album) {
      return album.title;
    }).toList();
  }

  _getDots() {
    final List<Widget> widgets = [];
    for (int i = 0; i < numberOfSteps; i++) {
      widgets.add(ColorDot(color: Colors.blue, isSelected: _index == i));
    }
    return widgets.toList();
  }

  _validateForm(GlobalKey<FormState> formKey) {
    if (formKey.currentState.validate()) {
      _index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: FutureBuilder<dynamic>(
            future: _getAlbumNames(),
            // a previously-obtained Future<dynamic> or null
            builder: (BuildContext navContext, AsyncSnapshot<dynamic> snapshot) {
              if(snapshot.hasData) {

                formList = [
                  _buildFirstForm(),
                  _buildSecondForm(navContext),
                  SongRelationships(albumNames: snapshot.data)
                ];
                return _loadingState
                    ? showLoading()
                    : Column(
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
                initialValue:
                    newSong.filename != null ? newSong.filename : null,
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
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    // no need to check the _formKey[0] bcs it has been checked when clicking on NEXT button
                    onPressed: (_formKeys[1].currentState != null &&
                            _formKeys[1].currentState.validate())
                        ? () {
                            setState(() {
                              _loadingState = true;
                            });
                            DataService.postSong(newSong).then((response) {
                              if (response.statusCode == 200) {
                                setState(() {
                                  newSong = Song();
                                  _index = 0;
                                  _loadingState = false;
                                });
                                Scaffold.of(_context).showSnackBar(SnackBar(
                                    content: Text('Song added successfully!')));
                              }
                            } /* successfully added song...  after a spinner*/);
                          }
                        : null,
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

  _buildStepperDots() {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: _index > 0
                ? () => setState(() {
                      _index--;
                    })
                : null,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.keyboard_arrow_left,
                  color: _index > 0 ? kTextColor : Colors.grey,
                ),
                Text(
                  'Back'.toUpperCase(),
                  style:
                      TextStyle(color: _index > 0 ? kTextColor : Colors.grey),
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
                      _validateForm(_formKeys[_index]);
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

class SongRelationships extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _SongRelationshipsState();
  }
  final List<String> albumNames;

  const SongRelationships({
    Key key,
    this.albumNames,
  }) : super(key: key);
}

class _SongRelationshipsState extends State<SongRelationships> {

  String dropdownValue = 'Related Album';
  List<String> items = new List();

  @override
  void initState() {
    items.add(dropdownValue);
    this.widget.albumNames.forEach((item) {
      this.items.add(item);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: items
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
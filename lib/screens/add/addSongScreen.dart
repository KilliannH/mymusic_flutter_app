import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mymusicflutterapp/main.dart';
import '../../ui/albumItem.dart';
import '../../models/Album.dart';
import '../../models/Song.dart';
import '../../services/dataService.dart';
import '../../constants.dart';

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

  _validateForm(GlobalKey<FormState> formKey) {
    if (formKey.currentState.validate()) {
      _index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Builder(
            // a previously-obtained Future<dynamic> or null
            builder: (BuildContext navContext) {

                formList = [
                  _buildFirstForm(),
                  _buildSecondForm(navContext),
                  _buildRelationships()
                ];
                return _loadingState
                    ? showLoading()
                    : Column(children: [_buildStepperDots(), formList[_index]]);
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
              padding: const EdgeInsets.all(16.0),
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      // no need to check the _formKey[0] bcs it has been checked when clicking on NEXT button
                      onPressed: () {
                        if(_formKeys[1].currentState.validate()) {
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
                Navigator.push(navContext, MaterialPageRoute(builder: (context) => MyApp()));
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

  _buildRelationships() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: SongRelatedAlbum(),
        )
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

  @override
  State<StatefulWidget> createState() {
    return _SongRelatedAlbumState();
  }

  const SongRelatedAlbum({
    Key key,
  }) : super(key: key);
}

class _SongRelatedAlbumState extends State<SongRelatedAlbum> {

  final limit = {'start': 0, 'end': 30};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: DataService.getAlbums(limit),
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
      },
    );
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
              child: AlbumItem(albums[index]),
            ),
            onTap: () => {},
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
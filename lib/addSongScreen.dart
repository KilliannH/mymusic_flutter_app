import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:securedplayerflutterplugin/securedplayerflutterplugin.dart';
import 'constants.dart';
import 'models/song.dart';

class AddSongScreen extends StatefulWidget {
  AddSongScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddSongScreenState();
  }
}

class AddSongScreenState extends State<AddSongScreen> {
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

  int _index = 0;
  int numberOfSteps = 3;
  var formList;

  Song newSong = Song();

  _getDotList() {
  final List<Widget> widgets = [];
  for(int i = 0; i < numberOfSteps; i++) {
  widgets.add(ColorDot(color: Colors.blue, isSelected: _index == i));
  }
  return widgets.toList();
  }

  _validateForm(GlobalKey<FormState> formKey) {
    if(formKey.currentState.validate()) {
      _index ++;
    }
    print(newSong.title);
  }

  @override
  Widget build(BuildContext context) {
    formList = [_buildFirstForm(), _buildSecondForm(), _buildThirdForm()];
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: <Widget>[
            _buildStepperDots(),
            Padding(
              padding: EdgeInsets.all(kDefaultPaddin),
              child: formList[_index],
            ),
          ]
        )
      );
  }

  _buildFirstForm() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            initialValue: newSong.title != null ? newSong.title : null,
            decoration: const InputDecoration(
              hintText: 'Title',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the title';
              } else {
                newSong.title = value;
                return null;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextFormField(
              initialValue: newSong.artist != null ? newSong.artist : null,
              decoration: const InputDecoration(
                hintText: 'Artist',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter the artist';
                } else {
                  newSong.artist = value;
                  return null;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildSecondForm() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            initialValue: newSong.album != null ? newSong.album : null,
            decoration: const InputDecoration(
              hintText: 'Album',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the album';
              } else {
                newSong.album = value;
                return null;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextFormField(
              initialValue: newSong.albumImg != null ? newSong.albumImg : null,
              decoration: const InputDecoration(
                hintText: 'Album Image Url',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an url';
                } else {
                  newSong.albumImg = value;
                  return null;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildThirdForm() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            initialValue: newSong.youtubeUrl != null ? newSong.youtubeUrl : null,
            decoration: const InputDecoration(
              hintText: 'Youtube Url',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the Youtube Url';
              } else {
                newSong.youtubeUrl = value;
                return null;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextFormField(
              initialValue: newSong.filename != null ? newSong.filename : null,
              decoration: const InputDecoration(
                hintText: 'Filename',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter the filename';
                } else {
                  newSong.filename = value;
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
                    onPressed: () {
                      // handle empty textInputs validation
                      if(_formKeys[2].currentState.validate()) {
                        print(newSong.toJson());
                        Scaffold
                            .of(context)
                            .showSnackBar(SnackBar(content: Text('Processing Data')));
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

  _buildStepperDots() {
    return Container(
        color: kGreyMenu,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                if(_index > 0) {
                  setState(() {
                    _index--;
                  });
                }
              },
              child: Row(
                children: <Widget> [
                  Icon(Icons.keyboard_arrow_left, color: kTextColor,),
                  Text('Back'.toUpperCase(), style: TextStyle(color: kTextColor))
                ],
              ),
            ),
            Row(
              children: _getDotList(),
            ),
            FlatButton(
              onPressed: () {
                if(_index <  formList.length -1) {
                  setState(() {
                    _validateForm(_formKeys[_index]);
                  });
                }
              },
              child: Row(
                children: <Widget> [
                  Text('Next'.toUpperCase(), style: TextStyle(color: kTextColor),),
                  Icon(Icons.keyboard_arrow_right, color: kTextColor,)
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
         color: isSelected ? color : kGreyDot,
         shape: BoxShape.circle
       ),
     ),
   );
  }
}
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
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  int _index = 0;
  int numberOfSteps = 3;
  var formList;

  _getDotList() {
  final List<Widget> widgets = [];
  for(int i = 0; i < numberOfSteps; i++) {
  widgets.add(ColorDot(color: Colors.blue, isSelected: _index == i));
  }
  return widgets.toList();
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
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Title',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the title';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Artist',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter the artist';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildSecondForm() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Album',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the album';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Image Url',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an url';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildThirdForm() {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Youtube Url',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the Youtube Url';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Filename',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter the filename';
                }
                return null;
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
                    onPressed: () {},
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
                    _index ++;
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
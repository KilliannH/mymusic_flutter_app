import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:mymusicflutterapp/models/Artist.dart';
import 'package:mymusicflutterapp/screens/artists/artistsScreen.dart';

import '../../models/Album.dart';
import '../../models/Song.dart';
import '../../services/dataService.dart';
import '../../constants.dart';

class AddArtistScreen extends StatefulWidget {

  final List<Album> albums;
  final List<Song> songs;
  AddArtistScreen({Key key, this.albums, this.songs}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddArtistScreenState();
  }
}

class _AddArtistScreenState extends State<AddArtistScreen> {

  final _textEditingNameController = TextEditingController();
  final _textEditingImageUrlController = TextEditingController();

  BuildContext _context;

  bool _loadingState = false;
  List<Widget> formList;

  String artistJsonStr = "";

  Artist newArtist = new Artist();

  _onFormSubmit() {
    bool _submitReady = true;
    if (_textEditingNameController.value.text != null &&
        _textEditingNameController.value.text != "") {
      newArtist.name = _textEditingNameController.value.text;
    } else {
      _submitReady = false;
      Scaffold
          .of(_context)
          .showSnackBar(
          SnackBar(content: Text('Error: name must be completed')));
    }

    if (_textEditingImageUrlController.value.text != null &&
        _textEditingImageUrlController.value.text != "") {
      newArtist.imageUrl = _textEditingImageUrlController.value.text;
    } else {
      _submitReady = false;
      Scaffold
          .of(_context)
          .showSnackBar(
          SnackBar(content: Text('Error: image url must be completed')));
    }
    return _submitReady;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Builder(
            builder: (BuildContext navContext) {
              _context = navContext;
              return _loadingState ? showLoading() : _buildForm();
            }
        )
    );
  }

  _buildForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              controller: _textEditingNameController,
              decoration: const InputDecoration(
                hintText: 'Name',
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
                      if (_onFormSubmit()) {
                        setState(() {
                          _loadingState = true;
                        });
                        DataService.newArtist(newArtist).then((response) {
                          print(response.statusCode.toString() + " " +
                              response.body.toString());
                          if (response.statusCode == 200) {
                            setState(() {
                              _loadingState = false;
                            });
                            Navigator.push(_context,
                                MaterialPageRoute(builder: (context) => ArtistsScreen()));
                            Scaffold
                                .of(_context)
                                .showSnackBar(SnackBar(
                                content: Text('Artist added successfully!')));
                            print(newArtist.toString());
                          }
                        }); /* successfully added artist...  after a spinner*/ //);
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
}
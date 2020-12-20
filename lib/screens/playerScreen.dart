import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securedplayerflutterplugin/securedplayerflutterplugin.dart';
import '../constants.dart';
import '../models/Artist.dart';
import '../models/Song.dart';

class PlayerScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PlayerScreenState();
  }

  final Song selectedSong;
  final List<Song> songList;

  PlayerScreen(this.selectedSong, this.songList);
}

enum PlayerState { destroyed, initialized, stopped, playing, paused }

class _PlayerScreenState extends State<PlayerScreen> {

  Song currentSong;

  Duration _duration;
  Duration _position;

  Map<String, dynamic> httpRequest;

  SecuredPlayerFlutterPlugin _audioPlayer;

  bool _loadingState = true;

  PlayerState _playerState;

  get isPlaying => _playerState == PlayerState.playing;
  get isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  _PlayerScreenState();

  @override
  void initState() {
    currentSong = widget.selectedSong;
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.destroy();
    super.dispose();
  }

  void initAudioPlayer() async {
    _audioPlayer = SecuredPlayerFlutterPlugin();

    _audioPlayer.durationHandler = (d) => setState(() {
      _duration = d;
    });

    _audioPlayer.positionHandler = (p) => setState(() {
      _position = p;
    });

    _audioPlayer.completionHandler = () {
      _onComplete();
    };

    _audioPlayer.initializedHandler = () {
      _onInitialized();
      _playerState = PlayerState.initialized;
    };

    _audioPlayer.destroyedHandler = () {
      // impl what to do after player has been destroyed,
      // create a new one with new song in it after a skipPrev, skipNext..
    };

    _audioPlayer.errorHandler = (msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = new Duration(seconds: 0);
        _position = new Duration(seconds: 0);
      });
    };

    httpRequest = await prepareUrl(currentSong.filename);

    // song plays when player is initialized
    await _audioPlayer.init(url: httpRequest['url'], apiKey: httpRequest['api_key']);
  }

  Future<Map<String, dynamic>> prepareUrl(String filename) async {
    var value = await rootBundle.loadString('assets/config.json');

    final config = jsonDecode(value);

    return {
      'url':
          '${config['protocol']}://${config['api_host']}:${config['api_port']}' +
              '/stream/' +
              filename,
      'api_key': config['api_key']
    };
  }

  Future play() async {
    await _audioPlayer.play();
    setState(() {
      _playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await _audioPlayer.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future togglePause() async {
    if(isPlaying) {
      await _audioPlayer.pause();
      setState(() => _playerState = PlayerState.paused);
    } else {
      await _audioPlayer.play();
      setState(() => _playerState = PlayerState.playing);
    }
  }

  Future stop() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration();
      _playerState = PlayerState.stopped;
    });
  }

  Future skipPrev() async {
    PlayerState _lastPlayerState = _playerState;
    if(_position.inSeconds > 4) {
      pause();
      if(_lastPlayerState == PlayerState.playing) {
        _audioPlayer.seek(Duration());
        return play();
      } else {
        _audioPlayer.seek(Duration());
      }
    } else {
      if (currentSong.order > 1) {
        for (int i = 0; i < widget.songList.length; i++) {
          if (currentSong.id == widget.songList[i].id) {
            _loadingState = true;
            _audioPlayer.destroy();
            return setState(() {
              currentSong = widget.songList[i - 1];
              initAudioPlayer();
            });
          }
        }
        print('go to prev song on playlist.....');
      } else {
        pause();
        _audioPlayer.seek(Duration());
        play();
      }
    }
  }

  void skipNext() {
    for (int i = 0; i < widget.songList.length; i++) {
      if (currentSong.id == widget.songList[i].id) {
        _loadingState = true;
        _audioPlayer.destroy();
        return setState(() {
          currentSong = widget.songList[i + 1];
          initAudioPlayer();
        });
      }
    }
    print('go to next song on playlist......');
  }

  void _handleFavorite() {
    /*
    setState(() {
      this.currentSong.isFavorite = !this.currentSong.isFavorite;
    });
    */
  }

  void _handleRepeat() {}

  Future destroy() async {
    await _audioPlayer.destroy();
    setState(() {
      _playerState = PlayerState.destroyed;
    });
  }

  void _onComplete() {
    stop();
  }

  // for now, play the song as soon as the player is initialized
  void _onInitialized() {
    _loadingState = false;
    play();
  }

  _buildAppBar(navContext) {
    return AppBar(title: Text('My Music'), actions: <Widget>[
      // overflow menu
      PopupMenuButton<Object>(
        onSelected: (value) {
          if(value == 1) {
            // Navigator.push(navContext, MaterialPageRoute(builder: (context) => AddSongScreen()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this._buildAppBar(context),
        body: _loadingState ? showLoading() : Center(
            child: Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 28, bottom: 8),
                  child:Text(currentSong.title, style: TextStyle(fontSize: 24),)
              ),
              Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(_concatArtists(currentSong.artists), style: TextStyle(fontSize: 18),)
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Image(image: NetworkImage(
                    currentSong.album.imageUrl),
                    width: 300,
                    height: 300
                ),
              ),
                Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Stack(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child:  Slider(
                        onChanged: (v) {
                          final position = v * _duration.inMilliseconds;
                          _audioPlayer
                              .seek(Duration(milliseconds: position.round()));
                        },
                        value: (_position != null &&
                            _duration != null &&
                            _position.inMilliseconds > 0 &&
                            _position.inMilliseconds < _duration.inMilliseconds)
                            ? _position.inMilliseconds / _duration.inMilliseconds
                            : 0.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                          _position != null
                              ? _positionText : '',
                          style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            _duration != null ? _durationText : '',
                            style: TextStyle(fontSize: 16.0),
                          )
                        ],
                      ),
                    )
                  ],)
                ),
              Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Spacer(),
                    IconButton(
                        iconSize: 28,
                        icon: Icon(Icons.favorite_border),
                        onPressed: () {
                          _handleFavorite();
                        }
                    ),
                    Spacer(),
                    IconButton(
                        iconSize: 32,
                        icon: Icon(Icons.skip_previous),
                        onPressed: () => skipPrev()
                    ),
                    IconButton(
                        iconSize: 32,
                        icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                        onPressed: () => togglePause()
                    ),
                    IconButton(
                        iconSize: 32,
                        icon: Icon(Icons.skip_next),
                        onPressed: widget.songList.indexOf(currentSong) < widget.songList.length -1 ? () => skipNext() : null
                    ),
                    Spacer(),
                    IconButton(
                        iconSize: 28,
                        icon: Icon(Icons.repeat),
                        onPressed: () {
                          _handleRepeat();
                        }
                    ),
                    Spacer()
                  ],
                ),
              )
            ]),
        ),
    );
  }

  _concatArtists(List<Artist> artists) {
    var text = "";
    var index = 0;
    artists.forEach((artist) {
      if (index < artists.length -1) {
        text += artist.name + ", ";
      } else {
        text += artist.name;
      }
      index++;
    });
    return text;
  }
}

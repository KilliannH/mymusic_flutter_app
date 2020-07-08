import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securedplayerflutterplugin/securedplayerflutterplugin.dart';
import 'constants.dart';
import 'models/song.dart';

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
  Duration _duration;
  Duration _position;

  Map<String, dynamic> httpRequest;

  SecuredPlayerFlutterPlugin _audioPlayer;

  PlayerState _playerState;

  get isPlaying => _playerState == PlayerState.playing;
  get isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  _PlayerScreenState();

  @override
  void initState() {
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

    httpRequest = await prepareUrl(widget.selectedSong.filename);

    // song plays when player is initialized
    await _audioPlayer.init(url: httpRequest['url'], apiKey: httpRequest['apiKey']);
  }

  Future<Map<String, dynamic>> prepareUrl(String filename) async {
    var value = await rootBundle.loadString('assets/config.json');

    final config = jsonDecode(value);

    return {
      'url':
          '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}' +
              '/stream/' +
              filename,
      'apiKey': config['apiKey']
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
    print('go to prev song on playlist.....');
  }

  void skipNext() {
    print('go to next song on playlist......');
  }

  Future destroy() async {
    await _audioPlayer.destroy();
    setState(() {
      _playerState = PlayerState.destroyed;
    });
  }

  void _onComplete() {}

  // for now, play the song as soon as the player is initialized
  void _onInitialized() => play();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
        body: Center(
            child: Column(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Image(
                      image: NetworkImage(widget.selectedSong.albumImg),
                      width: 300,
                      height: 300),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      widget.selectedSong.artist.toUpperCase(),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    )),
              Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Text(
                    widget.selectedSong.title,
                    style: TextStyle(fontSize: 18),
                  )),
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
                padding: EdgeInsets.only(bottom :0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        iconSize: 32,
                        icon: Icon(Icons.skip_previous),
                        onPressed: () {
                          skipPrev();
                        }
                    ),
                    IconButton(
                        iconSize: 32,
                        icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                        onPressed: () {
                          setState(() {
                            togglePause();
                          });
                        }
                    ),
                    IconButton(
                        iconSize: 32,
                        icon: Icon(Icons.skip_next),
                        onPressed: () {
                          skipNext();
                        }
                    )
                  ],
                ),
              )
            ]),
        ),
    );
  }

}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securedplayerflutterplugin/securedplayerflutterplugin.dart';
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
  Duration duration;
  Duration position;

  Map<String, dynamic> httpRequest;

  SecuredPlayerFlutterPlugin audioPlayer;

  PlayerState playerState = PlayerState.destroyed;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.destroy();
    super.dispose();
  }

  void initAudioPlayer() async {
    audioPlayer = SecuredPlayerFlutterPlugin();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == SecuredAudioPlayerState.INITIALIZED) {
            onInitialized();
          } else if (s == SecuredAudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.destroyed;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
    httpRequest = await prepareUrl(widget.selectedSong.filename);

    // song plays when player is initialized
    await audioPlayer.init(url: httpRequest['url'], apiKey: httpRequest['apiKey']);
    playerState = PlayerState.initialized;
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
    await audioPlayer.play();
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future togglePause() async {
    if(isPlaying) {
      await audioPlayer.pause();
      setState(() => playerState = PlayerState.paused);
    } else {
      await audioPlayer.play();
      setState(() => playerState = PlayerState.playing);
    }
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      position = Duration();
      playerState = PlayerState.stopped;
    });
  }

  Future skipPrev() async {
    print('go to prev song on playlist.....');
  }

  void skipNext() {
    print('go to next song on playlist......');
  }

  Future destroy() async {
    await audioPlayer.destroy();
    setState(() {
      playerState = PlayerState.destroyed;
    });
  }

  void onComplete() {}

  // for now, play the song as soon as the player is initialized
  void onInitialized() => play();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this._buildAppBar(context),
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
                      child: Slider(
                          value: position?.inMilliseconds?.toDouble() ?? 0.0,
                          onChanged: null,
                          min: 0.0,
                          max: duration?.inMilliseconds?.toDouble() ?? 0.0
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                          position != null
                              ? positionText : '',
                          style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            duration != null ? durationText : '',
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

  _buildAppBar(navContext) {
    return AppBar(title: Text('My Music'), actions: <Widget> [
      // overflow menu
      PopupMenuButton<Object>(
        onSelected: (value) {},
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
}

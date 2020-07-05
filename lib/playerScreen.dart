import 'dart:async';
import 'dart:convert';

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

enum PlayerState { stopped, playing, paused }

class _PlayerScreenState extends State<PlayerScreen> {
  Duration duration;
  Duration position;

  Map<String, dynamic> httpRequest;

  SecuredPlayerFlutterPlugin audioPlayer;

  PlayerState playerState = PlayerState.stopped;

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
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() async {
    audioPlayer = SecuredPlayerFlutterPlugin();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == SecuredAudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == SecuredAudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
    httpRequest = await prepareUrl(widget.selectedSong.filename);
    play(url: httpRequest['url'], apiKey: httpRequest['apiKey']);
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

  Future play({String url, String apiKey}) async {
    // url & apiKey are optional and will set the audioPlayer if doesn't exist
    await audioPlayer.play(url: url, apiKey: apiKey);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this._buildAppBar(context),
        body: Center(
            child: Column(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 40),
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
                    style: TextStyle(fontSize: 16),
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
                        children: <Widget>[
                          Text(
                          position != null
                              ? positionText : '',
                          style: TextStyle(fontSize: 16.0),
                          ),
                          Spacer(),
                          Text(
                            duration != null ? durationText : '',
                            style: TextStyle(fontSize: 16.0),
                          )
                        ],
                      ),
                    )
                  ],)
                ),
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

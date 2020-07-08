import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:mymusicflutterapp/models/song.dart';

class DataService {

  static Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/config.json');
  }

  static Future<List<Song>> getSongs() async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['apiKey'];

    var response = await client.get(Uri.parse(apiUrl + '/songs'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    var songsJson = jsonDecode(response.body) as List;

    List<Song> songList = songsJson.map((songJson) => Song.fromJson(songJson)).toList();

    return songList;
  }

  static Future<dynamic> postSong(Song song) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['apiKey'];

    var response = await client.post(Uri.parse(apiUrl + '/songs'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        }, body: jsonEncode(<String, String>
        {'title': song.title, 'artist': song.artist, 'album': song.album,
        'album_url': song.albumImg, 'filename': song.filename, 'youtube_url': song.youtubeUrl}));

    return response;
  }

}
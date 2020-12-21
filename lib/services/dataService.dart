import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:mymusicflutterapp/models/Playlist.dart';
import '../models/Album.dart';
import '../models/Artist.dart';
import '../models/Song.dart';

class DataService {

  static Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/config.json');
  }

  static Future<List<Song>> getSongs(Map<String, int> limit) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    int order = 1;

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/songs/limit' + '?start=' + limit['start'].toString() + '&end=' + limit['end'].toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    // in pageable json you get things like total number of songs, etc
    Map pageableJson = jsonDecode(response.body);
    var songsJson = pageableJson['content'] as List;

    // here we make relations only for song side bcs we only need songList in the UI
    // if we ever want an album list or an artist list we would provide relations on those too.
    List<Song> songList = songsJson.map((songJson) {
      Song song = Song.fromJson(songJson);
      Album album = Album.fromJson(songJson['album']);

      // initiate artists list bcs it's not done when a new song instance is created
      song.artists = new List<Artist>();
      songJson['artists'].forEach((artistJson) {
        Artist artist = new Artist.fromJson(artistJson);
        song.artists.add(artist);
      });
      song.album = album;
      song.order = order;
      order++;
      return song;
    }).toList();

    return songList;
  }

  static Future<List<Song>> getSongsByArtistIds(List artistIds) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    // parse the list to "[4]" for example
    Map bodyRequest = {'artistIds': artistIds};

    final String encoded = jsonEncode(bodyRequest);

    var response = await client.post(Uri.parse(apiUrl + '/songs/byArtists'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          "Content-Type": "application/json"
        }, body: encoded);

    var songsJson = jsonDecode(response.body) as List;

    int order = 1;

    // in pageable json you get things like total number of songs, etc
    List<Song> songList = songsJson.map((songJson) {
      Song song = Song.fromJson(songJson);
      Album album = Album.fromJson(songJson['album']);

      // initiate artists list bcs it's not done when a new song instance is created
      song.artists = new List<Artist>();
      songJson['artists'].forEach((artistJson) {
        Artist artist = new Artist.fromJson(artistJson);
        song.artists.add(artist);
      });
      song.album = album;
      song.order = order;
      order++;
      return song;
    }).toList();

    return songList;
  }

  static Future<Song> getSong(int id) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/songs/' + id.toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    // in pageable json you get things like total number of songs, etc
    Song song = Song.fromJson(response);
    return song;
  }

  static Future<List<Playlist>> getPlaylists(Map<String, int> limit) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/playlists/limit' + '?start=' + limit['start'].toString() + '&end=' + limit['end'].toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    Map pageableJson = jsonDecode(response.body);
    var playlistsJson = pageableJson['content'] as List;

    List<Playlist> playlists = playlistsJson.map((playlistJson) {
      Playlist playlist = Playlist.fromJson(playlistJson);
      playlist.songs = new List<Song>();

      playlistJson['songs'].forEach((songJson) {
        Song song = new Song.fromJson(songJson);
        Album album = Album.fromJson(songJson['album']);

        // initiate artists list bcs it's not done when a new song instance is created
        song.artists = new List<Artist>();
        songJson['artists'].forEach((artistJson) {
          Artist artist = new Artist.fromJson(artistJson);
          song.artists.add(artist);
        });
        song.album = album;
        playlist.songs.add(song);
      });

      return playlist;
    }).toList();

    return playlists;
  }

  static Future<List<Artist>> getArtists(Map<String, int> limit) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/artists/limit' + '?start=' + limit['start'].toString() + '&end=' + limit['end'].toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    Map pageableJson = jsonDecode(response.body);
    var artistsJson = pageableJson['content'] as List;

    List<Artist> artists = artistsJson.map((artistJson) {
      Artist artist = Artist.fromJson(artistJson);
      artist.albums = new List<Album>();
      artist.songs = new List<Song>();

      artistJson['songs'].forEach((songJson) {
        Song song = new Song.fromJson(songJson);
        artist.songs.add(song);
      });

      artistJson['albums'].forEach((albumJson) {
        Album album = new Album.fromJson(albumJson);
        artist.albums.add(album);
      });
      return artist;
    }).toList();

    return artists;
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
        {'title': song.title, 'filename': song.filename}));

    return response;
  }

}
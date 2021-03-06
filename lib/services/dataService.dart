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
      Album album;
      if(songJson['album'] != null) {
        album = Album.fromJson(songJson['album']);
      }
      // initiate artists list bcs it's not done when a new song instance is created
      song.artists = new List<Artist>();
      songJson['artists'].forEach((artistJson) {
        Artist artist = new Artist.fromJson(artistJson);
        song.artists.add(artist);
      });
      if(album != null) {
        song.album = album;
      }
      song.order = order;
      order++;
      return song;
    }).toList();

    return songList;
  }

  static Future<List<Song>> getAllSongs() async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    int order = 1;

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/songs/'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    // in pageable json you get things like total number of songs, etc
    var songsJson = jsonDecode(response.body) as List;

    // here we make relations only for song side bcs we only need songList in the UI
    // if we ever want an album list or an artist list we would provide relations on those too.
    List<Song> songList = songsJson.map((songJson) {
      Song song = Song.fromJson(songJson);
      Album album;
      if(songJson['album'] != null) {
        album = Album.fromJson(songJson['album']);
      }
      // initiate artists list bcs it's not done when a new song instance is created
      song.artists = new List<Artist>();
      songJson['artists'].forEach((artistJson) {
        Artist artist = new Artist.fromJson(artistJson);
        song.artists.add(artist);
      });
      if(album != null) {
        song.album = album;
      }
      song.order = order;
      order++;
      return song;
    }).toList();

    return songList;
  }

  static Future<List<Song>> getAllSongsByArtistIds(List artistIds) async {
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

  static Future<List<Song>> getAllSongsByAlbumId(int albumId) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    Map bodyRequest = {'albumId': albumId};

    final String encoded = jsonEncode(bodyRequest);

    var response = await client.post(Uri.parse(apiUrl + '/songs/byAlbum'),
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
    Song song = Song.fromJson(response.body);
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

  static Future<List<Playlist>> getAllPlaylists() async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/playlists/'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    var playlistsJson = jsonDecode(response.body) as List;

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

  static Future<List<Artist>> getAllArtists() async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/artists/'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    var artistsJson = jsonDecode(response.body) as List;

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

  static Future<List<Album>> getAlbums(Map<String, int> limit) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/albums/limit' + '?start=' + limit['start'].toString() + '&end=' + limit['end'].toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    Map pageableJson = jsonDecode(response.body);
    var albumsJson = pageableJson['content'] as List;

    List<Album> albums = albumsJson.map((albumJson) {
      Album album = Album.fromJson(albumJson);
      album.artists = new List<Artist>();
      album.songs = new List<Song>();

      albumJson['songs'].forEach((songJson) {
        Song song = new Song.fromJson(songJson);
        album.songs.add(song);
      });

      albumJson['artists'].forEach((artistJson) {
        Artist artist = new Artist.fromJson(artistJson);
        album.artists.add(artist);
      });
      return album;
    }).toList();

    return albums;
  }

  static Future<List<Album>> getAllAlbums() async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.get(Uri.parse(apiUrl + '/albums/'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });

    var albumsJson = jsonDecode(response.body) as List;

    List<Album> albums = albumsJson.map((albumJson) {
      Album album = Album.fromJson(albumJson);
      album.artists = new List<Artist>();
      album.songs = new List<Song>();

      albumJson['songs'].forEach((songJson) {
        Song song = new Song.fromJson(songJson);
        album.songs.add(song);
      });

      albumJson['artists'].forEach((artistJson) {
        Artist artist = new Artist.fromJson(artistJson);
        album.artists.add(artist);
      });
      return album;
    }).toList();

    return albums;
  }

  static Future<dynamic> newSong(Song song) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.post(Uri.parse(apiUrl + '/songs'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(<String, String>
        {'title': song.title, 'filename': song.filename}));

    return response;
  }

  static Future<dynamic> newArtist(Artist artist) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.post(Uri.parse(apiUrl + '/artists'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(<String, String>
        {'name': artist.name, 'imageUrl': artist.imageUrl}));

    return response;
  }

  static Future<dynamic> newAlbum(Album album) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.post(Uri.parse(apiUrl + '/albums'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(<String, String>
        {'title': album.title, 'imageUrl': album.imageUrl}));

    return response;
  }

  static Future<dynamic> downloadSong(Song song, String youtubeId) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}';
    String apiKey = config['api_key'];

    var response = await client.post(Uri.parse(apiUrl + '/download'),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        }, body: jsonEncode(<String, String>
        {'youtubeId': youtubeId, 'filename': song.filename}));

    return response;
  }

  static Future<dynamic> newSongArtist(int songId, int artistId) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.post(Uri.parse(apiUrl + '/songs/' + songId.toString() + '/artists/' + artistId.toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        }, body: jsonEncode(<String, String>
        {}));

    return response;
  }

  static Future<dynamic> newAlbumArtist(int albumId, int artistId) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.post(Uri.parse(apiUrl + '/albums/' + albumId.toString() + '/artists/' + artistId.toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        }, body: jsonEncode(<String, String>
        {}));

    return response;
  }

  static Future<dynamic> newAlbumSong(int albumId, int songId) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.post(Uri.parse(apiUrl + '/albums/' + albumId.toString() + '/songs/' + songId.toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        }, body: jsonEncode(<String, String>
        {}));

    return response;
  }

  static Future<dynamic> newSongAlbum(int songId, int albumId) async {
    var value = await loadAsset();

    var config = jsonDecode(value);
    var client = http.Client();

    String apiUrl = '${config['protocol']}://${config['api_host']}:${config['api_port']}/${config['api_endpoint']}';
    String apiKey = config['api_key'];

    var response = await client.post(Uri.parse(apiUrl + '/songs/' + songId.toString() + '/albums/' + albumId.toString()),
        headers: {
          HttpHeaders.authorizationHeader: apiKey,
          'Content-Type': 'application/json'
        }, body: jsonEncode(<String, String>
        {}));

    return response;
  }

}
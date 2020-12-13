import 'package:mymusicflutterapp/models/Song.dart';

import 'Artist.dart';

class Album {

  int id;
  String title;
  String imageUrl;
  List<Artist> artists;
  List<Song> songs;

  Album({this.id, this.title, this.imageUrl});

  List<Artist> setArtists(List<Artist> artists) {
    return this.artists = artists;
  }

  List<Song> setSongs(List<Song> songs) {
    return this.songs = songs;
  }

  factory Album.fromJson(dynamic json) {
    return Album(id: json['id'] as int, title: json['title'] as String, imageUrl: json['imageUrl'] as String);
  }

  String toJson() {
    return '{' + '"id":' + '"' + this.id.toString() + '"' + ',' + '"title":' + '"' + this.title + '"' + ',' + '"imageUrl":' + '"' + this.imageUrl + '"' + '}';
  }

  @override
  String toString() {
    return 'Album{id: $id, title: $title, imageUrl: $imageUrl}';
  }
}
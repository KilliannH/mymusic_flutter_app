import '../models/Album.dart';

import 'Artist.dart';

class Song {

  int id;
  String title;
  Album album;
  List<Artist> artists;
  String filename;
  bool selected = false;

  int order;

  Song({this.id, this.title, this.filename});

  factory Song.fromJson(dynamic json) {
    return Song(id: json['id'] as int, title: json['title'] as String,
        filename: json['filename'] as String);
  }

  String toJson() {
    return '{' + '"id":' + '"' + this.id.toString() + '"' + ',' + '"title":' + '"' + this.title + '"' + ',' + '"filename":' + '"' + filename + '"' + '}';
  }

  @override
  String toString() {
    return 'Song{id: $id, title: $title, filename: $filename}';
  }
}
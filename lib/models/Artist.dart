import 'package:mymusicflutterapp/models/Album.dart';
import 'package:mymusicflutterapp/models/Song.dart';

class Artist {

  int id;
  String name;
  String imageUrl;
  List<Song> songs;
  List<Album> albums;

  Artist({this.id, this.name, this.imageUrl});

  List<Song> setSongs(List<Song> songs) {
    return this.songs = songs;
  }

  List<Album> setAlbums(List<Album> albums) {
    return this.albums = albums;
  }

  factory Artist.fromJson(dynamic json) {
    print('' + json['id'].toString() + ' ' + json['name'] + ' ' + json['imageUrl']);
    return Artist(id: json['id'] as int, name: json['name'] as String, imageUrl: json['imageUrl'] as String);
  }

  String toJson() {
    return '{' + '"id":' + '"' + this.id.toString() + '"' + ',' + '"name":' + '"' + this.name + '"' + ',' + '"imageUrl":' + '"' + this.imageUrl + '"' + '}';
  }

  @override
  String toString() {
    return 'Artist{id: $id, name: $name, imageUrl: $imageUrl}';
  }
}
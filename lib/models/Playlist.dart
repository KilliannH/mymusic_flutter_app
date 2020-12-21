import 'Song.dart';

class Playlist {

  int id;
  String name;
  List<Song> songs;

  Playlist({this.id, this.name});

  List<Song> setSongs(List<Song> songs) {
    return this.songs = songs;
  }

  factory Playlist.fromJson(dynamic json) {
    return Playlist(id: json['id'] as int, name: json['name'] as String);
  }

  String toJson() {
    return '{' + '"id":' + '"' + this.id.toString() + '"' + ',' + '"name":' + '"' + this.name + '"' + '}';
  }

  @override
  String toString() {
    return 'Playlist{id: $id, name: $name}';
  }
}
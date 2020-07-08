class Song {

  String id;
  String title;
  String artist;
  String album;
  String albumImg;
  String filename;
  String youtubeUrl;

  Song({this.id, this.title, this.artist, this.album, this.albumImg, this.filename});

  factory Song.fromJson(dynamic json) {
    return Song(id: json['_id'] as String, title: json['title'] as String, artist: json['artist'] as String, album: json['album'] as String, albumImg: json['album_img'] as String, filename: json['filename'] as String);
  }

  String toJson() {
    return "{ \"title\": " + this.title + ", \"artist\": " + "\"" + this.artist + "\"" + ", \"album\": " + "\"" + this.album + "\"" + ", \"album_img\": " + "\"" + this.albumImg + "\""
        + ", \"filename\": " + "\"" + filename + "\"" + ", \"youtube_url\": " + "\"" + this.youtubeUrl + "\"" + "}";
  }
}
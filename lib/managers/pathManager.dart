class PathManager {
  static String _currPath;

  static void setCurrPath(String path) {
    _currPath = path;
  }

  static String getCurrPath() {
    return _currPath;
  }
}
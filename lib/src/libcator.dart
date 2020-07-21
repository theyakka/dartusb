import 'dart:async';
import 'dart:io';

class Libcator {
  Future<Libcator> initialize() async {
    if (Platform.isLinux) {
      var searchPaths = [
        '/lib',
        '/lib64',
        '/usr/lib',
        '/usr/lib64',
        '/usr/local/lib'
      ];
      const ldConfPath = '/etc/ld.so.conf.d';
      var dir = Directory(ldConfPath);
      var exists = await dir.exists();
      if (exists) {
        var listing = await dir.list(recursive: true).toList();
        for (var fse in listing) {
          var contents = await File(fse.absolute.path).readAsString();
          contents.split('\n').forEach((element) {
            var trimmed = element.trim();
            if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
              searchPaths.add(trimmed);
            }
          });
        }
      }
      _searchPaths = searchPaths;
    }
    return this;
  }

  var _libraries = <String>[];

  var _searchPaths = <String>[];
  List<String> get searchPaths => _searchPaths;

  Future<Map<String, String>> locate(List<String> libraries) async {
    var foundPaths = <String, String>{};
    for (var path in _searchPaths) {
      try {
        var dir = Directory(path);
        var listing = dir.list(recursive: true);
        await for (var e in listing) {
          for (var lib in libraries) {
            if (e.absolute.path.endsWith(lib)) {
              foundPaths[lib] = e.absolute.path;
            }
          }
        }
        // ignore: empty_catches
      } catch (e) {}
    }
    return foundPaths;
  }
}

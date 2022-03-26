import 'dart:io';
import 'dart:convert' show utf8, json;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'helpers.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:dartssh2/dartssh2.dart';

class App {
  /// Returns an int of the string
  /// '1.2.3' -> 123
  /// @param versionString: String
  /// @return double
  double versionToDouble(String version) {
    return double.tryParse(version
            .toString()
            .replaceAll('v', '')
            .replaceAll('.', '')
            .replaceAll('+', '.')) ??
        -1;
  }

  /// Returns an url as String when the app is not up-to-date otherwise empty string
  /// @param version: String
  /// @return Future<String>
  Future<String> checkUpdate(String version) async {
    try {
      var response = await Dio().get(updateUrl);
      if (response.data.length > 0) {
        var latest = response.data[0];
        String tagName = latest['tag_name'];

        // TODO: change version to PackageInfo once it works with Windows
        /* PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String version = packageInfo.buildNumber; */
        if (versionToDouble(tagName) > versionToDouble(version)) {
          return latest['assets'][0]['browser_download_url'];
        }
      }
    } catch (e) {
      // ignored
    }
    return '';
  }

  /// Returns the message of the day
  /// @return Future<String>
  Future<String> checkMotd() async {
    try {
      var response = await Dio().get(motdUrl);
      if (response.data.length > 0) {
        var jsonData = json.decode(response.data);
        String motd = jsonData['motd'];
        return motd;
      }
    } catch (e) {
      // ignored
    }
    return '';
  }
}

class Host {
  /// Constructor
  Host(this.alias, this.host, this.port, this.username, this.password);
  String alias;
  String host;
  int port;
  String username;
  String password;
}

class SSHAPI {
  late Host host;
  late SSHClient client;
  String error = '';

  /// Constructor
  //SSHAPI(this.host, this.port, this.username, this.password);

  /// List saved SSH Hosts from SharedPreferences
  /// @return Future<List<String>>
  Future<List<String>> list() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('sshHosts');
    list ??= [];
    return list;
  }

  /// Edit specific SSH Host from
  /// @param alias: String
  /// @return Future<Host>
  Future<Host> edit(String alias, Host h) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('sshHosts');
    list ??= [];

    if (alias == h.alias) {
      // Same alias
      prefs.setString('sshHost_' + alias, h.host);
      prefs.setInt('sshPort_' + alias, h.port);
      prefs.setString('sshUsername_' + alias, h.username);
      // TODO: encrypt password
      prefs.setString('sshPassword_' + alias, h.password);
    } else {
      // Different alias
      list.remove(alias);
      list.add(h.alias);
      prefs.setStringList('sshHosts', list);

      // Remove old alias's
      prefs.remove('sshHost_' + alias);
      prefs.remove('sshPort_' + alias);
      prefs.remove('sshUsername_' + alias);
      prefs.remove('sshPassword_' + alias);

      // Add new alias strings
      prefs.setString('sshHost_' + h.alias, h.host);
      prefs.setInt('sshPort_' + h.alias, h.port);
      prefs.setString('sshUsername_' + h.alias, h.username);
      // TODO: encrypt password
      prefs.setString('sshPassword_' + h.alias, h.password);
    }
    host = h;
    return host;
  }

  /// Get specific SSH Host from SharedPreferences
  /// @param alias: String
  /// @return Future<Host>
  Future<Host> get(String alias) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('sshHosts');
    list ??= [];
    if (list.contains(alias)) {
      String? host = prefs.getString('sshHost_' + alias);
      int? port = prefs.getInt('sshPort_' + alias);
      String? username = prefs.getString('sshUsername_' + alias);
      String? password = prefs.getString('sshPassword_' + alias);
      host ??= '';
      port ??= 22;
      username ??= '';
      password ??= '';
      return Host(alias, host, port, username, password);
    } else {
      return Host(alias, '', 0, '', '');
    }
  }

  /// Add SSH Host to SharedPreferences
  /// @param alias: String
  /// @param host: String
  /// @param port: int
  /// @param username: String
  /// @param password: String
  /// @return Future<void>
  /// @throws Exception
  Future<void> add(Host h) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('sshHosts');
    list ??= [];
    list.add(h.alias);
    prefs.setStringList('sshHosts', list);
    prefs.setString('sshHost_' + h.alias, h.host);
    prefs.setInt('sshPort_' + h.alias, h.port);
    prefs.setString('sshUsername_' + h.alias, h.username);
    // TODO: encrypt password
    prefs.setString('sshPassword_' + h.alias, h.password);
  }

  /// Remove SSH Host from SharedPreferences
  /// @param alias: String
  /// @return Future<void>
  Future<void> remove(String alias) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('sshHosts');
    list ??= [];
    list.remove(alias);
    prefs.setStringList('sshHosts', list);
    prefs.remove('sshHost_' + alias);
    prefs.remove('sshPort_' + alias);
    prefs.remove('sshUsername_' + alias);
    prefs.remove('sshPassword_' + alias);
  }

  // Connect per SSH to host from shared preferences
  /// @param alias: String
  /// @return Future<void>
  /// @throws Exception
  Future<SSHAPI> connectPerAlias(String alias) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? host = prefs.getString('sshHost_' + alias);
    int? port = prefs.getInt('sshPort_' + alias);
    String? username = prefs.getString('sshUsername_' + alias);
    String? password = prefs.getString('sshPassword_' + alias);
    if (host == null || port == null || username == null || password == null) {
      throw Exception('No SSH Host found');
    }
    try {
      final socket = await SSHSocket.connect(host, port);
      client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
    } catch (err) {
      error = err.toString();
    }
    return this;
  }

  /// Connect per SSH
  Future connect(host, port, username, password) async {
    final socket = await SSHSocket.connect(host, port);

    client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );
  }

  /// Send command to SSH
  /// @param cmd: String
  /// @return Future<String>
  Future<String> sendCmd(String cmd) async {
    if (error.isNotEmpty) {
      return error;
    }
    try {
      final result = await client.run(cmd);
      return (utf8.decode(result));
    } catch (e) {
      return e.toString();
    }
  }

  /// Close connection
  /// @return Future<void>
  Future close() {
    client.close();
    return client.done;
  }
}

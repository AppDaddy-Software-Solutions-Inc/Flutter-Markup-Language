import 'package:connectivity_plus/connectivity_plus.dart' as cp;
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';

import 'package:fml/connectivity/connectivity.mobile.dart'
    if (dart.library.io) 'package:fml/connectivity/connectivity.mobile.dart'
    if (dart.library.html) 'package:fml/connectivity/connectivity.web.dart';

class Connectivity {
  late final cp.Connectivity connection;
  late final BooleanObservable connected;

  static final Connectivity _singleton = Connectivity._internal();
  Connectivity._internal();

  factory Connectivity(BooleanObservable connected) {
    _singleton.connected = connected;
    return _singleton;
  }

  Future initialize() async {
    try {
      // create connectivity
      connection = cp.Connectivity();

      // check connectivity
      List<cp.ConnectivityResult> connections =
          await connection.checkConnectivity();

      // check internet access
      if (connections.isNotEmpty && connections.first != cp.ConnectivityResult.none) {
        var isConnected = await Internet.isConnected();
        connected.set(isConnected);
      } else {
        System.toast(Phrases().checkConnection, duration: 3);
      }

      // Add connection listener to determine connection
      connection.onConnectivityChanged.listen((connections) async {
        if (connections.isNotEmpty && connections.first != cp.ConnectivityResult.none)
        {
          Log().info("Connection status changed: $connections");
          var isConnected = await Internet.isConnected();
          connected.set(isConnected);
        }
        else
        {
          connected.set(false);
        }
        Log().info("Connection status changed. Internet is ${(connected.get() == true) ? 'connected' : 'disconnected'}");
      });

      Log().debug('initConnectivity status: $connected');
    } catch (e) {
      connected.set(false);
      Log().debug('Error initializing connectivity');
    }
  }
}

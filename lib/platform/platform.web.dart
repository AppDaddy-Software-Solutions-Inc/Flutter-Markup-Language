// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/event/event.dart';
import 'package:fml/fml.dart';
import 'package:fml/helpers/mime.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/uri.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:universal_html/html.dart';
import 'package:flutter/foundation.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:universal_html/js.dart';
import 'package:fml/event/manager.dart';

bool get isWeb => Platform.isWeb;
bool get isMobile => Platform.isMobile;
bool get isDesktop => Platform.isDesktop;

class Platform {

  // platform
  static String get platform => "web";

  static bool get isWeb => kIsWeb;
  static bool get isMobile => false;
  static bool get isDesktop => false;

  // operating system
  static String get operatingSystem {

    final s = window.navigator.userAgent.toLowerCase();
    if (s.contains('iphone') ||
        s.contains('ipad') ||
        s.contains('ipod') ||
        s.contains('watch os')) {
      return 'ios';
    }
    if (s.contains('mac os')) {
      return 'macos';
    }
    if (s.contains('fuchsia')) {
      return 'fuchsia';
    }
    if (s.contains('android')) {
      return 'android';
    }
    if (s.contains('linux') || s.contains('cros') || s.contains('chromebook')) {
      return 'linux';
    }
    if (s.contains('windows')) {
      return 'windows';
    }
    return "?";
  }

  // operating system version
  static String get operatingSystemVersion {

    final s = window.navigator.userAgent;

    // Android?
    {
      final regExp = RegExp('Android ([a-zA-Z0-9.-_]+)');
      final match = regExp.firstMatch(s);
      if (match != null) {
        final version = match.group(1) ?? '';
        return version.replaceAll(";", "");
      }
    }

    // iPhone OS?
        {
      final regExp = RegExp('iPhone OS ([a-zA-Z0-9.-_]+) ([a-zA-Z0-9.-_]+)');
      final match = regExp.firstMatch(s);
      if (match != null) {
        final version = (match.group(2) ?? '').replaceAll('_', '.');
        return version.replaceAll(";", "");
      }
    }

    // Mac OS X?
        {
      final regExp = RegExp('Mac OS X ([a-zA-Z0-9.-_]+)');
      final match = regExp.firstMatch(s);
      if (match != null) {
        final version = (match.group(1) ?? '').replaceAll('_', '.');
        return version.replaceAll(";", "");
      }
    }

    // Chrome OS?
        {
      final regExp = RegExp('CrOS ([a-zA-Z0-9.-_]+) ([a-zA-Z0-9.-_]+)');
      final match = regExp.firstMatch(s);
      if (match != null) {
        final version = match.group(2) ?? '';
        return version.replaceAll(";", "");
      }
    }

    // Windows?
        {
      final regExp = RegExp('Windows NT ([a-zA-Z0-9.-_]+)');
      final match = regExp.firstMatch(s);
      if (match != null) {
        final version = (match.group(1) ?? '');
        return version.replaceAll(";", "");
      }
    }

    return "?";
  }

  // application root path
  static Future<String?> get path async => null;

  static final dynamic iframe = window.document.getElementById('invisible');

  static initialize() async {
    try {
      // set the root path for the specified platform
      URI.rootPath = "";

      // hide the logo
      window.document.getElementById("logo")!.style.visibility = "hidden";
    } catch (e) {
      Log().debug('$e');
    }
  }

  static Future<dynamic> fileSaveAs(List<int> bytes, String filename) async {
    try {
      // make the file name safe
      filename = Mime.toSafeFileName(filename);

      final blob = Blob([bytes]);
      final url = Url.createObjectUrlFromBlob(blob);
      final anchor = document.createElement('a') as AnchorElement;

      anchor.href = url;
      anchor.style.display = 'none';
      anchor.download = filename;
      document.body!.children.add(anchor);

      anchor.click();

      document.body!.children.remove(anchor);
      Url.revokeObjectUrl(url);
    } catch (e) {
      System.toast("Unable to save file");
      Log().error('Error writing file');
      Log().exception(e);
      return null;
    }

    return null;
  }

  static dynamic fileSaveAsFromBlob(Blob blob, String? filename) {
    final url = Url.createObjectUrlFromBlob(blob);
    final anchor = document.createElement('a') as AnchorElement;

    anchor.href = url;
    anchor.style.display = 'none';
    anchor.download = filename;
    document.body!.children.add(anchor);

    anchor.click();

    document.body!.children.remove(anchor);
    Url.revokeObjectUrl(url);
  }

  static void openPrinterDialog() {
    window.print();
  }

  static dynamic getFile(String? filename) => null;
  static String? folderPath(String folder) => null;
  static String? filePath(String? filename) => null;
  static bool folderExists(String folder) => false;
  static bool fileExists(String filename) => false;
  static Future<String?> readFile(String? filepath) async => null;
  static Future<Uint8List?> readFileBytes(String? filepath) async => null;
  static Future<String?> createFolder(String? folder) async => null;
  static Future<bool> writeFile(String? filename, dynamic content) async =>
      true;
  static Future<bool> deleteFile(String filename) async => true;

  // keep the browser history in sync with the application history
  // isNavigatingBackInHistory is used by the setNewRoutePath() routine
  // to avoid double navigation back() calls
  static Future<bool> navigateBackInHistory(int pages) async {
    try {
      String id = "fmlGo2";
      if (document.getElementById(id) == null) {
        var script = document.createElement("script");
        script.id = id;
        script.innerText = "function $id(i) { window.history.go(i); }";
        document.head!.append(script);
      }
      context.callMethod(id, [-1 * pages]);
    } catch (e) {
      return false;
    }
    return true;
  }

  static int getNavigationType() {
    try {
      return window.performance.navigation.type ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static String get title {
    String? title;
    var e = window.document.getElementsByName("description");
    if (e.isNotEmpty && e.first is MetaElement) {
      title = (e.first as MetaElement).content;
    }
    return title ?? FmlEngine.title;
  }

  /// Using the js package we can capture calls from javascript within flutter.
  /// The js2fml(json) function is called from js and held in the `context` map
  /// for use within flutter, passing its json as a map and allowing us in
  /// dart/flutter to access it. This enables fml to be used through an iframe.
  ///
  /// index.html loads the script from local.js file
  /// then listens to the .js postMessages() calls
  ///
  ///   // <!-- VSCode Webview Template File Parsing -->
  ///   window.addEventListener('message', function(event) {
  ///       var data;
  ///       try {
  ///           // <!--console.log(`Received ${event.data} from ${event.origin}`);-->
  ///           data = JSON.parse(event.data);
  ///       } catch(e) {}
  ///       try {
  ///           if (event.origin.startsWith('https://pad.fml.dev') && data && data.data && data.to) {
  ///               window.parent.postMessage({'data': data.data, 'from': event.origin, 'to': data.to});
  ///           }
  ///           else if (!event.origin.startsWith('vscode-webview://')) {
  ///               // <!--console.log('bad origin');-->
  ///               return;
  ///           }
  ///           else {
  ///              js2fml({'data': `${event.data}`, 'from': `${event.origin}`, 'to': 'fml'});
  ///          }
  ///       } catch(err) {
  ///           // <!--console.log(`js2fml error`);-->
  ///       }
  ///   });

  /// Basic implementation to show a template sent from js for vscode extension.
  /// Next step: non-breaking refactor to expand the protocol and enhance fml2js
  static void js2fml() {
    context['js2fml'] = (json) async {
      // The script in index.html sets the data value that we assign to doc:
      // `js2fml({'data': `${event.data}`, 'from': `${event.origin}`, 'to': 'fml'});`
      String doc = json['data'];
      Model? model = System();
      EventManager.of(model)?.broadcastEvent(
          model, Event(EventTypes.openjstemplate, parameters: {'templ8': doc}));
    };
  }

  /// This is a stub for expansion, some kind of protocol should be decided on
  /// within the data field before proceeding further
  static void fml2js({String? version}) {
    version = version ?? '?';
    final data = <String, dynamic>{
      'data': 'FML v$version',
      'from': 'fml',
      'to': 'js'
    };
    const jsonEncoder = JsonEncoder();
    final json = jsonEncoder.convert(data);
    context.callMethod('postMessage', [json, '*']);
  }

  static Color? get backgroundColor {
    var color = document.body?.style.backgroundColor;
    return toColor(color);
  }
}

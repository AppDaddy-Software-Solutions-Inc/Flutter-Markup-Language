import 'dart:async';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/uri.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class PackageModel extends Model {

  final Completer<bool> initialized = Completer<bool>();

  Runtime? _runtime;
  String? _name;
  String? _dart;
  String? _url;
  bool _defer = false;

  dynamic error;
  StackTrace? trace;

  PackageModel(super.parent, super.id);

  static PackageModel fromXml(Model parent, XmlElement xml) {
    var model = PackageModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  static Future<bool> load(XmlElement xml, bool refresh) async {
    var model = PackageModel(null, Xml.get(node: xml, tag: 'id'));
    return await model.tryLoad(xml, refresh);
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // properties
    _name = Xml.get(node: xml, tag: 'name')?.trim();
    _url  = Xml.get(node: xml, tag: 'url');
    _dart = Xml.get(node: xml, tag: 'dart');

    // load the plugin
    _loadPlugin();
  }

  // this function is called by thge template manger for loading
  // packages ahead of template deserialization
  Future<bool> tryLoad(XmlElement xml, bool refresh) async {

    // properties
    _defer = toBool(Xml.get(node: xml, tag: 'name')) ?? false;
    _name = Xml.get(node: xml, tag: 'name')?.trim();
    _url  = Xml.get(node: xml, tag: 'url');
    _dart = Xml.get(node: xml, tag: 'dart');

    // load the plugin
    if (_defer) {
      _loadPlugin();
      return true;
    }
    else {
      return await _loadPlugin();
    }
  }

  Future<bool> _loadPlugin() async {

    bool loaded = true;

    try {

      // cached?
      if (!isNullOrEmpty(_url) && System.plugins.containsKey(_url!)) {
        _runtime = System.plugins[_url!];
      }

      // load the plugin?
      if (_runtime == null) {

        // is url?
        if (!isNullOrEmpty(_url)) {

          // parse the url
          var uri = URI.parse(_url);

          if (uri != null) {

            // get the evc bytes from remote
            final response = await http.get(uri);

            // error?
            if (response.statusCode != 200) throw("error: ${response.statusCode} ${response.reasonPhrase}");

            // set the bytes
            var bytes = response.bodyBytes;

            // load the plugin
            _runtime = Runtime(ByteData.sublistView(bytes));

            // load eval plugin
            _runtime!.addPlugin(flutterEvalPlugin);

            // cache the plugin
            System.plugins[_url!] = _runtime!;
          }
        }

        // dart code
        else if (!isNullOrEmpty(_dart)) {

          //var parts = _package!.replaceFirst("package:", "").split("/");
          //var name = parts.isNotEmpty ? parts.first : "";
          //var file = parts.length > 1 ? parts.last  : "";

          final compiler = Compiler();
          compiler.addPlugin(flutterEvalPlugin);
          final program = compiler.compile({'name' : { 'file' : 'package' }});

          var bytes = program.write();

          // load the plugin
          _runtime = Runtime(ByteData.sublistView(bytes));

          // load eval plugin
          _runtime!.addPlugin(flutterEvalPlugin);
        }
      }
    }

    catch (e, trace) {
      error = "Error loading plugin from $_name \n\n $e";
      this.trace = trace;
      loaded = false;
    }

    // mark complete
    initialized.complete(true);

    return loaded;
  }

  $Value _wrapped(dynamic value) {
    if (value is String) return $String(value);
    if (value is bool) return $bool(value);
    if (value is int) return $int(value);
    if (value is double) return $double(value);
    if (value is Color) return $String(toStr(value) ?? "");
    if (value is! $Value) return const $null();
    return value;
  }

  dynamic _unwrapped(dynamic value) {
    if (value is $Value) {
      value = value.$reified;
    }
    return value;
  }

  $Value? _get(Runtime runtime, $Value? target, List<$Value?> args) {

    var key = args.isNotEmpty ? toStr(args.first) : null;
    dynamic value;

    if (key != null) {
      value = get(key);
    }
    return _wrapped(value);
  }

  dynamic get(String key)
  {
    var b = Binding.fromString(key);
    if (b != null) {
      var o = scope?.getObservable(b);
      return o?.get();
    }
    return null;
  }

  $Value? _set(Runtime runtime, $Value? target, List<$Value?> args) {

    var key   = args.isNotEmpty ? toStr(args.first) : null;
    var value = args.isNotEmpty  && args.length > 1 ? args[1]!.$value : null;

    if (key != null) {
      set(key, value);
    }
    return null;
  }

  void set(String key, dynamic value)
  {
    var b = Binding.fromString(key);
    if (b != null) {
      var o = scope?.getObservable(b);
      o?.set(value);
    }
  }

  Widget _errorBuilder(dynamic exception, StackTrace? stackTrace) {

    var msg = "Oops something went wrong loading plugin";
    msg = "$msg \n\n $exception \n\n $stackTrace";
    var view = Tooltip(message: msg, child: const Icon(Icons.error_outline, color: Colors.red, size: 24));
    return view;
  }

  dynamic call(String method, List<dynamic> arguments)  => _call(method, arguments);

  Future<dynamic> callAsync(String method, List<dynamic> arguments)  async {

    // wait for evc code to load
    await initialized.future;

    return _call(method, arguments);
  }

  dynamic _call(String method, List<dynamic> arguments)  {
    try {

      // format the package name
      var package = _name ?? "";
      if (!package.toLowerCase().trim().startsWith("package:")) {
        package = "package:$package";
      }

      // wrap the arguments to pass to the plugin
      var args = [];
      for (var arg in arguments) {
        args.add(_wrapped(arg));
      }

      // execute the dart code
      var result = _runtime?.executeLib(package, method, args);

      // return the result
      return _unwrapped(result);
    }
    catch(error, trace) {

      if (kDebugMode) print("Error calling $method in package $_name\n\n $error \n\n $trace");
    }
    return null;
  }

  Future<dynamic> widget(Model wrapper, String? className, {List<dynamic>? arguments})  async {

    // wait for evc code to load
    await initialized.future;

    Widget? view;

    try {

      // error during build?
      if (error != null) return _errorBuilder(error,trace);

      // standard interface to all widgets is the id of the model and
      // the getter and setter functions callbacks
      var args =[$String(wrapper.id), $Closure(_get), $Closure(_set)];

      // format the package name
      var package = _name ?? "";
      if (!package.toLowerCase().trim().startsWith("package:")) {
        package = "package:$package";
      }

      // format class name
      className ??= ".";

      // format the
      view = _runtime?.executeLib(package, className, args);
    }
    catch(error, trace) {
      view =_errorBuilder(error,trace);
    }

    return view;
  }

  @override
  Future<dynamic> execute(
      String caller,
      String propertyOrFunction,
      List<dynamic> arguments) async {

    var method = "${caller.split(".").last.trim()}.${propertyOrFunction.trim()}";
    var result = await callAsync(method, arguments);
    return result;
  }
}


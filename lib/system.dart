// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:core';
import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseApp;
import 'package:flutter/foundation.dart';
import 'package:fml/datasources/log/log_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/helper/uri.dart';
import 'package:fml/hive/stash.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/postmaster/postmaster.dart';
import 'package:fml/janitor/janitor.dart';
import 'package:fml/token/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:fml/hive/database.dart';
import 'package:fml/datasources/gps/gps.dart' as GPS;
import 'package:fml/datasources/gps/payload.dart' as GPS;
import 'package:fml/application/application_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'dart:io' as io;

// platform
import 'package:fml/platform/platform.stub.dart'
if (dart.library.io)   'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

// application build version
final String version = '1.0.0+10';

// Active Application
ApplicationModel? get Application => System()._app;

// This url is used to locate config.xml on startup
// Used in SingleApp only and on Web when developing on localhost
// Set this to file://applications/<app> to use the asset applications
Uri defaultDomain = Uri.parse('https://fml.dev');

// SingleApp - App initializes from a single domain endpoint (defined in defaultDomain)
// MultiApp  - (Desktop & Mobile Only) Launches the Store at startup
enum ApplicationTypes{ SingleApp, MultiApp }
final ApplicationTypes appType  = ApplicationTypes.MultiApp;

// platform
String get platform => isWeb ? "web" : isMobile ? "mobile" : "desktop";
bool get isWeb      => kIsWeb;
bool get isMobile   => !isWeb && (io.Platform.isAndroid || io.Platform.isIOS);
bool get isDesktop  => !isWeb && !isMobile;

// This variable is used throughout the code to determine if debug messages
// and their corresponding actions should be performed.
// Putting this inside the System() class is problematic at startup
// when log messages being written while System() is still be initialized.
final bool kDebugMode = !kReleaseMode;

typedef CommitCallback = Future<bool> Function();

class System extends WidgetModel implements IEventManager
{
  static final System _singleton = System.initialize();
  factory System() => _singleton;
  System.initialize() : super(null, "SYSTEM") {initialized = _init();}

  // system scope
  Scope? scope = Scope("SYSTEM");

  // set to true once done
  Future<bool>? initialized;

  // current application
  ApplicationModel? _app;

  // current theme
  late final ThemeModel _theme;
  ThemeModel get theme => _theme;

  late final Connectivity connection;

  // post master service
  final PostMaster postmaster = PostMaster();

  // janitorial service
  final Janitor janitor = Janitor();

  /// holds user observables bound to claims
  Map<String, StringObservable> _user = Map<String, StringObservable>();

  // current domain
  BooleanObservable? _connected;
  bool get connected => _connected?.get() ?? false;

  // root folder path
  static late String rootPath;
  StringObservable? _rootpath;
  String? get rootpath => _rootpath?.get();

  // current domain
  StringObservable? _domain;
  String? get domain => _domain?.get();

  // current scheme
  StringObservable? _scheme;
  String? get scheme => _scheme?.get();

  // current host
  StringObservable? _host;
  String? get host => _host?.get();

  /// Global System Observable
  StringObservable? _platform;
  String? get platform => _platform?.get();

  StringObservable? _useragent;
  String? get useragent => _useragent?.get() ?? Platform.useragent;

  StringObservable? _version;
  String get release => _version?.get() ?? "?";

  IntegerObservable? _screenheight;
  int get screenheight => _screenheight?.get() ?? 0;

  IntegerObservable? _screenwidth;
  int get screenwidth => _screenwidth?.get() ?? 0;

  // UUID
  StringObservable? _uuid;
  String uuid() => Uuid().v1();

  // Dates
  Timer? clock;

  IntegerObservable? _epoch;
  int epoch() => (_epoch != null) ? DateTime.now().millisecondsSinceEpoch : 0;

  IntegerObservable? _year;
  int year() => (_year != null) ? DateTime.now().year : 0;

  IntegerObservable? _month;
  int month() => (_month != null) ? DateTime.now().month: 0;

  IntegerObservable? _day;
  int day() => (_day != null) ? DateTime.now().day : 0;

  IntegerObservable? _hour;
  int hour() => (_hour != null) ? DateTime.now().hour : 0;

  IntegerObservable? _minute;
  int minute() => (_minute != null) ? DateTime.now().minute : 0;

  IntegerObservable? _second;
  int second() => (_second != null) ? DateTime.now().second : 0;

  // GPS
  GPS.Gps gps = GPS.Gps();
  GPS.Payload? currentLocation;

  /// current json web token used to authenticate
  StringObservable? _jwt;
  Jwt? _token;
  set token(Jwt? value)
  {
    _token = value;
    if (_jwt != null) _jwt!.set(_token?.token);
  }
  Jwt? get token => _token;

  // firebase
  FirebaseApp? get firebase => _app?.firebase;
  set firebase(FirebaseApp? v) => _app?.firebase = v;

  Future<bool> _init() async
  {
    Log().info('Initializing FML Engine V$version ...');

    // initialize platform
    await Platform.init();

    // initialize System Globals
    await _initBindables();

    // initialize Hive
    await _initDatabase();

    // initialize connectivity
    await _initConnectivity();

    // create empty applications folder
    await _initFolders();

    // set initial route
    await _initRoute();

    // start the Post Master
    await postmaster.start();

    // start the Janitor
    await janitor.start();

    return true;
  }

  Future _initConnectivity() async
  {
    try
    {
      connection = Connectivity();

      ConnectivityStatus initialConnection = await connection.checkConnectivity();
      if (initialConnection == ConnectivityStatus.none) System.toast(Phrases().checkConnection, duration: 3);

      // Add connection listener
      connection.isConnected.listen((isconnected) => _connected?.set(isconnected));

      // For the initial connectivity test we want to give checkConnection some time
      // but it still needs to run synchronous so we give it a second
      await Future.delayed(Duration(seconds: 1));
      Log().debug('initConnectivity status: $connected');
    }
    catch (e)
    {
      _connected?.set(false);
      Log().debug('Error initializing connectivity');
    }
  }

  Future _initRoute() async
  {
    if (isWeb)
    {
      // set initial route
      String route = PlatformDispatcher.instance.defaultRouteName.trim();
      while (route.startsWith("/")) route = route.replaceFirst("/", "").trim();
      if (route.toLowerCase().endsWith(".xml")) defaultDomain = defaultDomain.replace(fragment: route);

      // replace default
      print (Uri.base.toString());
      var uri = URI.parse(Uri.base.toString());
      if (uri != null && !uri.host.toLowerCase().startsWith("localhost")) defaultDomain = uri;
    }
  }

  Future<bool> _initBindables() async
  {
    // platform root path
    System.rootPath  = await Platform.path ?? "";
    _rootpath = StringObservable(Binding.toKey(id, 'rootpath'), System.rootPath, scope: scope);

    // connected
    _connected = BooleanObservable(Binding.toKey(id, 'connected'), null, scope: scope);

    // active application settings
    _domain = StringObservable(Binding.toKey(id, 'domain'), null, scope: scope);
    _scheme = StringObservable(Binding.toKey(id, 'scheme'), null, scope: scope);
    _host   = StringObservable(Binding.toKey(id, 'host'),   null, scope: scope);

    // create the theme
    _theme = ThemeModel(this, "THEME");

    // json web token
    _jwt = StringObservable(Binding.toKey(id, 'jwt'), null, scope: scope);

    // device settings
    _screenheight = IntegerObservable(Binding.toKey(id, 'screenheight'), WidgetsBinding.instance.window.physicalSize.height, scope: scope);
    _screenwidth  = IntegerObservable(Binding.toKey(id, 'screenwidth'),  WidgetsBinding.instance.window.physicalSize.width, scope: scope);
    _platform     = StringObservable(Binding.toKey(id, 'platform'), platform, scope: scope);
    _useragent    = StringObservable(Binding.toKey(id, 'useragent'), Platform.useragent, scope: scope);
    _version      = StringObservable(Binding.toKey(id, 'version'), version, scope: scope);
    _uuid         = _uuid == null ? StringObservable(Binding.toKey(id, 'uuid'), uuid(), scope: scope, getter: uuid) : null;

    // system dates
    _epoch  = IntegerObservable(Binding.toKey(id, 'epoch'), epoch(), scope: scope, getter: epoch);
    _year   = IntegerObservable(Binding.toKey(id, 'year'), year(), scope: scope, getter: year);
    _month  = IntegerObservable(Binding.toKey(id, 'month'), month(), scope: scope, getter: month);
    _day    = IntegerObservable(Binding.toKey(id, 'day'), day(), scope: scope, getter: day);
    _hour   = IntegerObservable(Binding.toKey(id, 'hour'), hour(), scope: scope, getter: hour);
    _minute = IntegerObservable(Binding.toKey(id, 'minute'), minute(), scope: scope, getter: minute);
    _second = IntegerObservable(Binding.toKey(id, 'second'), second(), scope: scope, getter: second);

    // add system level log model datasource
    if (datasources == null) datasources = [];
    datasources!.add(LogModel(this, "LOG"));

    return true;
  }

  Future<bool> _initDatabase() async
  {
    // create the hive folder
    var folder = join(rootPath,"hive");
    String? hiveFolder = await Platform.createFolder(folder);

    // initialize hive
    await Database().initialize(hiveFolder);

    return true;
  }

  Future<bool> _initFolders() async
  {
    bool ok = true;

    if (isWeb) return ok;
    try
    {
      // create folder
      Platform.createFolder("applications");

      // read asset manifest
      Map<String, dynamic> manifest = json.decode(await rootBundle.loadString('AssetManifest.json'));

      // copy assets
      for (String key in manifest.keys)
      if (key.startsWith("assets/applications"))
      {
        var folder   = key.replaceFirst("assets/", "");
        var filepath = join(rootPath,"applications",folder);
        await Platform.writeFile(filepath, await rootBundle.load(key));
      }
    }
    catch(e)
    {
      print("Error building application assets. Error is $e");
      ok = false;
    }
    return ok;
  }

  // hack to fix focus/unfocus commits
  CommitCallback? commit;
  Future<bool> onCommit() async
  {
    if (commit != null) return await commit!();
    return true;
  }

  static toast(String? msg, {int? duration})
  {
    BuildContext? context = NavigationManager().navigatorKey.currentContext;
    if (context != null)
    {
      var snackbar = SnackBar(
          content: Text(msg ?? ""),
          duration: Duration(seconds: duration ?? 1),
          behavior: SnackBarBehavior.floating,
          elevation: 5);
      var messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(snackbar);
    }
  }

  Future<bool> stashValue(String key, dynamic value) async {
    bool ok = true;
    try
    {
      if (S.isNullOrEmpty(key)) return ok;

      // write to the hive
      await Stash().set(System().host, key, value);

      // set observable
      scope!.setObservable("STASH.$key", value);
    }
    catch (e)
    {
      // stash failure always returns true
      ok = true;
    }
    return ok;
  }

  Future<bool> logon(Jwt? token) async
  {
    // valid token?
    if ((token != null) && (token.valid))
    {
      // set user claims
      token.claims.forEach((key, value)
      {
        if (_user.containsKey(key))
             _user[key]!.set(value);
        else _user[key] = StringObservable(Binding.toKey("USER", key), value, scope: scope);
      });

      // clear missing claims
      _user.forEach((key, observable)
      {
        bool clear = !token.claims.containsKey(key);
        if (clear) observable.set(null);
      });

      // set rights
      if (!_user.containsKey('rights')) _user['rights'] = StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);

      // set connected = true
      if (!_user.containsKey('connected'))
           _user['connected'] = StringObservable(Binding.toKey("USER", 'connected'), true, scope: scope);
      else _user['connected']!.set(true);

      // set token
      this.token = token;
      return true;
    }

    // clear all claims
    else
    {
      // clear user values
      _user.forEach((key, observable) => observable.set(null));

      // set phrase language
      phrase.language = _user.containsKey('language') ? _user['language'] as String? : Phrases.english;

      // clear rights
      if (!_user.containsKey('rights')) _user['rights'] = StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);

      // set connected = false
      if (!_user.containsKey('connected'))
           _user['connected'] = StringObservable(Binding.toKey("USER", 'connected'), false, scope: scope);
      else _user['connected']!.set(false);

      // clear token
      this.token = null;
      return false;
    }
  }

  Future<bool> logoff() async
  {
    // set rights
    if (!_user.containsKey('rights'))
         _user['rights'] = StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);
    else _user['rights']!.set(0);

    // set connected
    if (!_user.containsKey('connected'))
         _user['connected'] = StringObservable(Binding.toKey("USER", 'connected'), false, scope: scope);
    else _user['connected']!.set(false);

    // remember token
    this.token = null;
    return true;
  }

  // return specific user claim
  String? userProperty(String property)
  {
    if ((_user.containsKey(property)) && (_user[property] is Observable)) return _user[property]?.get();
    return null;
  }

  void setApplicationTitle(String? title) async
  {
    title = title ?? _app?.settings("APPLICATION_NAME");
    if (!S.isNullOrEmpty(title))
    {
      // print('setting title to $title');
      SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(label: title, primaryColor: Colors.blue.value));
    }
  }

  // launches the application
  launch(ApplicationModel app)
  {
    // Close current application
    if (this._app != null) close(_app!);

    Log().info("Activating Application (${app.title}) @ ${app.domain}");

    // set the default domain on the Url utilities
    URI.rootHost = app.domain ?? "";

    // set the current application
    _app = app;

    // apply theme settings
    app.setTheme(theme);

    // set credentials
    if (app.jwt != null) logon(token);

    // set fml version support level
    //if (config?.get("FML_VERSION") != null) fmlVersion = S.toVersionNumber(config!.get("FML_VERSION")!) ?? currentVersion;

    // build the STASH
    // List<StashEntry> entries = await Stash.findAll(System().host);
    // entries.forEach((entry) => scope?.setObservable("STASH.${entry.key}", entry.value));

    // update application level bindables
    _domain?.set(app.domain);
    _scheme?.set(app.scheme);
    _host?.set(app.host);
  }

  // launches the application
  close(ApplicationModel app)
  {
    Log().info("Closing Application ${app.url}");

    // set the default domain on the Url utilities
    URI.rootHost = "";

    // logoff
    logoff();

    // set fml version support level
    //if (config?.get("FML_VERSION") != null) fmlVersion = S.toVersionNumber(config!.get("FML_VERSION")!) ?? currentVersion;

    // build the STASH
    // List<StashEntry> entries = await Stash.findAll(System().host);
    // entries.forEach((entry) => scope?.setObservable("STASH.${entry.key}", entry.value));

    // update application level bindables
    _domain?.set(null);
    _scheme?.set(null);
    _host?.set(null);
  }

  /// Event Manager Host
  final EventManager manager = EventManager();
  registerEventListener(EventTypes type, OnEventCallback callback, {int? priority}) => manager.register(type, callback, priority: priority);
  removeEventListener(EventTypes type, OnEventCallback callback) => manager.remove(type, callback);
  broadcastEvent(WidgetModel source, Event event) => manager.broadcast(this, event);
  executeEvent(WidgetModel source, String event) => manager.execute(this, event);
}

// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/base/model.dart';
import 'package:fml/event/handler.dart' ;
import 'package:xml/xml.dart';
import 'payload.dart';
import 'iNfcListener.dart';
import 'nfc.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class NcfModel extends DataSourceModel implements IDataSource, INfcListener
{
  @override
  bool get autoexecute => super.autoexecute ?? true;

  // message count
  late IntegerObservable _received;
  int get received => _received.get() ?? 0;

  // serial
  late StringObservable _serial;
  String? get serial => _serial.get();

  // message
  late StringObservable _message;
  String? get message => _message.get();
  
  // method
  StringObservable? _method;
  set method(dynamic v)
  {
    if (_method != null)
    {
      _method!.set(v);
    }
    else if (v != null)
    {
      _method = StringObservable(Binding.toKey(id, 'method'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get method => _method?.get() ?? "read";

  NcfModel(WidgetModel parent, String? id) : super(parent, id)
  {
    _received = IntegerObservable(Binding.toKey(id, 'received'), 0, scope: scope);
    _serial   = StringObservable(Binding.toKey(id, 'serial'), null, scope: scope);
    _message  = StringObservable(Binding.toKey(id, 'payload'), null, scope: scope);
  }

  static NcfModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    NcfModel? model;
    try
    {
      model = NcfModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'iframe.Model');
      model = null;
    }
    return model;
  }

  @override
  void dispose()
  {
    Reader().removeListener(this);
    super.dispose();
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {

    // deserialize
    super.deserialize(xml);

    // properties
    method = Xml.get(node: xml, tag: 'method');
  }

  Future<bool> start({bool refresh: false, String? key}) async
  {
    bool ok = true;

    if (!isMobile)
    {
      System.toast("NFC is only available on mobile devices");
      return ok;
    }

    switch (method.toLowerCase().trim())
    {
      case "read":
        Reader().registerListener(this);
        break;

      case "write":
        return await _write(body);
    }

    return true;
  }

  Future<bool> stop() async
  {
    Reader().removeListener(this);
    super.stop();
    return true;
  }

  Future<bool> _write(String? message) async
  {
    if (!S.isNullOrEmpty(message))
    {
      Log().debug('NFC WRITE: Polling for 60 seconds');
      String stripTags = message!.replaceAll('\r', '').replaceAll('\t', '').replaceAll('\n', '').replaceAll(RegExp("\<[^\>]*\>", caseSensitive: false), '');
      Writer writer = Writer(stripTags, callback: onResult);
      bool ok = await writer.write();

      // write succeeded
      if (ok && !S.isNullOrEmpty(onsuccess))
      {
        EventHandler handler = EventHandler(this);
        await handler.execute(onSuccessObservable);
      }

      // write failed
      else if (!ok && !S.isNullOrEmpty(onfail))
      {
        EventHandler handler = EventHandler(this);
        await handler.execute(onFailObservable);
      }
    }
    return true;
  }

  onResult(bool b)
  {
    // success
    if (b && onsuccess != null) EventHandler(this).execute(onSuccessObservable);

    // fail
    if (!b && onfail != null) EventHandler(this).execute(onFailObservable);
  }
  
  @override
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;

    if (!isMobile)
    {
      System.toast("NFC is only available on mobile devices");
      return false;
    }

    String function = propertyOrFunction.toLowerCase().trim();
    if (method.toLowerCase().trim() == "read")
    {
      switch (function)
      {
        case "read"  :
        case "start" :
          Reader().registerListener(this);
          return true;
        case "stop"  : return await stop();
      }
    }
    else if (method.toLowerCase().trim() == "write")
    {
      switch (function)
      {
        case "start" :
        case "write" :
          String? message = S.toStr(S.item(arguments, 0)) ?? body;
          return await _write(message);
        case "stop"  : return await stop();
      }
    }
    return super.execute(propertyOrFunction, arguments);
  }

  onMessage(Payload payload)
  {
    // enabled?
    if (enabled == false) return;

    // increment the number of messages received
    _received.set(received + 1);

    // set last serial received
    _serial.set(payload.id);

    // set last message bindable
    _message.set(payload.message);

    // deserialize the data
    Data data = Data.from(payload.message, root: root);

    // if the message didn't deserialize (length 0)
    // so create a simple map with topic and message bindables <id>.data.topic and <id>.data.message
    // otherwise the data is the deserialized message payload
    if (data.length == 0) data.insert(0, {'serial': payload.id , 'message' : payload.message});

    // fire the onresponse
    onResponse(data, code: 200);
  }
}

// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/map/map_view.dart';
import 'package:fml/widgets/map/marker/map_marker_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum MapTypes { satellite, hybrid, terrain, roadmap }

class MapModel extends BoxModel {
  final List<String> layers = [];

  // marker prototypes
  final prototypes = HashMap<String?, List<XmlElement>>();

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  @override
  bool get canExpandInfinitelyHigh => !hasBoundedHeight;

  // latitude
  DoubleObservable? _latitude;
  set latitude(dynamic v) {
    if (_latitude != null) {
      _latitude!.set(v);
    } else if (v != null) {
      _latitude = DoubleObservable(Binding.toKey(id, 'latitude'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get latitude => _latitude?.get();

  // longitude
  DoubleObservable? _longitude;
  set longitude(dynamic v) {
    if (_longitude != null) {
      _longitude!.set(v);
    } else if (v != null) {
      _longitude = DoubleObservable(Binding.toKey(id, 'longitude'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get longitude => _longitude?.get();

  // zoom level
  DoubleObservable? _zoom;
  set zoom(dynamic v) {
    if (_zoom != null) {
      _zoom!.set(v);
    } else if (v != null) {
      _zoom = DoubleObservable(Binding.toKey(id, 'zoom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get zoom {
    double? scale = _zoom?.get() ?? 1;
    if (_zoom == null) return scale;

    scale = _zoom?.get();
    scale ??= 1;
    if ((scale < 1)) scale = 1;
    if ((scale > 20)) scale = 20;
    return scale;
  }

  // autozoom
  BooleanObservable? _autozoom;
  set autozoom(dynamic v) {
    if (_autozoom != null) {
      _autozoom!.set(v);
    } else if (v != null) {
      _autozoom = BooleanObservable(Binding.toKey(id, 'autozoom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get autozoom => _autozoom?.get() ?? true;

  final List<MapMarkerModel> markers = [];

  MapModel(Model super.parent, super.id,
      {dynamic zoom, dynamic visible}) {
    // instantiate busy observable
    busy = false;

    this.zoom = zoom;
    this.visible = visible;
  }

  static MapModel? fromXml(Model parent, XmlElement xml) {
    MapModel? model;
    try {
      model = MapModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'map.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    zoom = Xml.get(node: xml, tag: 'zoom');
    autozoom = Xml.get(node: xml, tag: 'autozoom');
    latitude = Xml.get(node: xml, tag: 'latitude');
    longitude = Xml.get(node: xml, tag: 'longitude');

    // add layers
    var layers = Xml.getChildElements(node: xml, tag: "LAYER");
    if (layers != null) {
      for (var layer in layers) {
        String? url = Xml.get(node: layer, tag: 'url');
        if (url != null) this.layers.add(url);
      }
    }

    // build locations
    List<MapMarkerModel> markers =
        findChildrenOfExactType(MapMarkerModel).cast<MapMarkerModel>();
    for (var model in markers) {
      // data driven prototype location
      if (!isNullOrEmpty(model.datasource)) {
        if (!prototypes.containsKey(model.datasource)) {
          prototypes[model.datasource] = [];
        }

        // build prototype
        var prototype = prototypeOf(model.element) ?? model.element;

        // add location model
        if (prototype != null) {
          prototypes[model.datasource]!.add(prototype);
        }

        // register listener to the models datasource
        IDataSource? source = scope?.getDataSource(model.datasource);
        if (source != null) source.register(this);
      }

      // static location
      else {
        this.markers.add(model);
      }
    }
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = false;
    bool ok = await _build(list, source);
    notifyListeners('list', markers);
    return ok;
  }

  // HashMap<String, Uint8List> _icons = HashMap<String, Uint8List>();

  Future<bool> _build(Data? list, IDataSource source) async {
    try {
      var prototypes = this.prototypes.containsKey(source.id)
          ? this.prototypes[source.id]
          : null;
      if (prototypes == null) return true;

      // Remove Old Locations
      var obsoleteMarkers =
          markers.where((model) => source.id == model.datasource);
      markers.removeWhere((model) => obsoleteMarkers.contains(model));
      for (var model in obsoleteMarkers) {
        model.dispose();
      }

      // build new locations
      if ((list != null) && (list.isNotEmpty)) {
        for (var prototype in prototypes) {
          for (var data in list) {
            var location =
                MapMarkerModel.fromXml(parent!, prototype, data: data);
            if (location != null) markers.add(location);
          }
        }
      }
    } catch (e) {
      Log().error('Error building list. Error is $e', caller: 'MAP');
      return false;
    }

    return true;
  }

  @override
  Widget getView({Key? key}) {
    var view = MapView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}

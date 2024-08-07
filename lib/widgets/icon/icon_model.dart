// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class IconModel extends ViewableModel {
  // icon
  IconObservable? _icon;
  set icon(dynamic v) {
    if (_icon != null) {
      _icon!.set(v);
    } else if (v != null) {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  IconData? get icon => _icon?.get();

  // size
  DoubleObservable? _size;
  set size(dynamic v) {
    if (_size != null) {
      _size!.set(v);
    } else if (v != null) {
      _size = DoubleObservable(Binding.toKey(id, 'size'), null,
          scope: scope,
          listener: onPropertyChange,
          getter: _sizeGetter,
          setter: _sizeSetter);
      _size!.set(v);
    }
  }

  double? get size => _size?.get() ?? 24;

  dynamic _sizeGetter() => width;
  dynamic _sizeSetter(dynamic value, {Observable? setter}) {
    width = value;
    height = value;
    return width;
  }

  IconModel(super.parent, super.id,
      {dynamic visible,
      dynamic icon,
      dynamic size,
      dynamic color,
      dynamic opacity}) {
    this.visible = visible;
    this.icon = icon;
    this.color = color;
    this.opacity = opacity;
    this.size = size;
  }

  static IconModel? fromXml(Model parent, XmlElement xml) {
    IconModel? model;
    try {
      model = IconModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'icon.Model');
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
    icon = Xml.get(node: xml, tag: 'icon') ?? Xml.get(node: xml, tag: 'value');
    size = Xml.get(node: xml, tag: 'size');
  }

  @override
  Widget getView({Key? key}) {
    var view = IconView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}

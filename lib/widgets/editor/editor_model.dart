// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/editor/editor_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class EditorModel extends ViewableModel {
  // theme
  StringObservable? _theme;
  set theme(dynamic v) {
    if (_theme != null) {
      _theme!.set(v);
    } else {
      if (v != null) {
        _theme = StringObservable(Binding.toKey(id, 'theme'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }

  String? get theme => _theme?.get();

  // value
  StringObservable? _value;
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else {
      if (v != null) {
        _value = StringObservable(Binding.toKey(id, 'value'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }

  String? get value => _value?.get();

  // language
  StringObservable? _language;
  set language(dynamic v) {
    if (_language != null) {
      _language!.set(v);
    } else {
      if (v != null) {
        _language = StringObservable(Binding.toKey(id, 'language'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }

  String get language => _language?.get() ?? "xml";

  EditorModel(super.parent, super.id, {dynamic value, dynamic language}) {
    if (value != null) this.value = value;
    if (language != null) this.language = language;
  }

  static EditorModel? fromXml(Model parent, XmlElement xml) {
    EditorModel? model;
    try {
      model = EditorModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'EditorModel');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    value = Xml.get(node: xml, tag: 'value');
    language = Xml.get(node: xml, tag: 'language')?.toLowerCase().trim();
    theme = Xml.get(node: xml, tag: 'theme');
  }

  @override
  Widget getView({Key? key}) {
    var view = EditorView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}

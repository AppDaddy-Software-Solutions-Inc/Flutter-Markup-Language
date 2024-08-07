// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class PageModel extends BoxModel {
  @override
  LayoutType layoutType = LayoutType.column;

  @override
  bool get expand => true;

  // url
  StringObservable? _url;
  set url(dynamic v) {
    if (_url != null) {
      _url!.set(v);
    } else if (v != null) {
      _url = StringObservable(Binding.toKey(id, 'url'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get url => _url?.get();

  PageModel(super.parent, super.id, {dynamic data, dynamic url})
      : super(scope: Scope(parent: parent?.scope)) {
    this.data = data;
    this.url = url;
  }

  static PageModel? fromXml(Model? parent, XmlElement? xml,
      {dynamic data, dynamic onTap, dynamic onLongPress}) {
    PageModel? model;
    try {
      // build model
      model = PageModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'pager.page.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml) {
    if (xml == null) return;

    // deserialize
    super.deserialize(xml);

    // properties
    url = Xml.get(node: xml, tag: 'url');
  }

  @override
  Widget getView({Key? key}) => BoxView(this, (_,__) => inflate());
}

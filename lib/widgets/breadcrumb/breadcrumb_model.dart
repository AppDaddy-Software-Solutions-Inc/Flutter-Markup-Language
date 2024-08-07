// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/breadcrumb/breadcrumb_view.dart';
import 'package:fml/helpers/helpers.dart';

/// Breadcrumb Model
///
/// Defines the properties of [BREADCRUMB.BreadcrumbView] widget
class BreadcrumbModel extends ViewableModel {
  
  /// background color of the breadcrumb bar
  ColorObservable? _backgroundcolor;
  set backgroundcolor(dynamic v) {
    if (_backgroundcolor != null) {
      _backgroundcolor!.set(v);
    } else if (v != null) {
      _backgroundcolor = ColorObservable(
          Binding.toKey(id, 'backgroundcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get backgroundcolor => _backgroundcolor?.get();

  BreadcrumbModel({
    Model? parent,
    String? id,
    dynamic height,
    dynamic color,
    dynamic backgroundcolor,
    dynamic opacity,
    dynamic width,
  }) : super(parent, id) {
    // constraints
    if (height != null) this.height = height;
    if (width != null) this.width = width;

    this.color = color;
    this.backgroundcolor = backgroundcolor;
    this.opacity = opacity;
  }

  static BreadcrumbModel? fromXml(Model parent, XmlElement xml) {
    BreadcrumbModel? model;
    try {
// build model
      model = BreadcrumbModel(parent: parent);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'breadcrumb.Model');
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
    backgroundcolor = Xml.get(node: xml, tag: 'backgroundcolor');
  }

  @override
  Widget getView({Key? key}) {
    var view = BreadcrumbView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}

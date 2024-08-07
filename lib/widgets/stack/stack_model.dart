// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class StackModel extends BoxModel {
  @override
  LayoutType layoutType = LayoutType.stack;

  @override
  String? get layout => "stack";

  StackModel(Model super.parent, super.id, {super.scope, super.data});

  static StackModel? fromXml(Model parent, XmlElement xml, {Scope? scope, dynamic data}) {
    StackModel? model;
    try {
      // build model
      model = StackModel(parent, Xml.get(node: xml, tag: 'id'), scope: scope, data: data);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'stack.Model');
      model = null;
    }
    return model;
  }

  @override
  List<Widget> inflate() {
    // sort children by depth
    if (children != null) {
      children!.sort((a, b) {
        if (a is ViewableMixin && b is ViewableMixin) {
          if (a.depth != null && b.depth != null) {
            return a.depth?.compareTo(b.depth!) ?? 0;
          }
        }
        return 0;
      });
    }
    return super.inflate();
  }
}

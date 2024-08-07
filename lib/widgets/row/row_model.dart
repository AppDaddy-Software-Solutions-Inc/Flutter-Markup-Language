// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class RowModel extends BoxModel {
  @override
  LayoutType layoutType = LayoutType.row;

  @override
  String? get layout => "row";

  // indicates if the widget will grow in
  // its vertical axis
  @override
  bool get expandVertically {
    if (!super.expandVertically) return false;
    bool flexible = false;
    for (var child in viewableChildren) {
      if (child.visible && child.expandVertically) {
        flexible = true;
        break;
      }
    }
    return flexible;
  }

  RowModel(Model super.parent, super.id, {super.scope, super.data});

  static RowModel? fromXml(Model parent, XmlElement xml,
      {Scope? scope, dynamic data}) {
    RowModel? model;
    try {
      // build model
      model = RowModel(parent, Xml.get(node: xml, tag: 'id'),
          scope: scope, data: data);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'row.Model');
      model = null;
    }
    return model;
  }
}

// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/table/table_row_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TableRowCellModel extends BoxModel {
  // row
  TableRowModel? get row =>
      parent is TableRowModel ? parent as TableRowModel : null;

  @override
  double? get paddingTop => super.paddingTop ?? row?.paddingTop;

  @override
  double? get paddingRight => super.paddingRight ?? row?.paddingRight;

  @override
  double? get paddingBottom => super.paddingBottom ?? row?.paddingBottom;

  @override
  double? get paddingLeft => super.paddingLeft ?? row?.paddingLeft;

  @override
  String? get halign => super.halign ?? row?.halign;

  @override
  String? get valign => super.valign ?? row?.valign;

  @override
  double? get width => null;

  @override
  double? get height => null;

  // Position in Row
  int? get index {
    if ((parent != null) && (parent is TableRowModel)) {
      return (parent as TableRowModel).cells.indexOf(this);
    }
    return null;
  }

  // value - used to sort
  StringObservable? _value;
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null) {
      _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope);
    }
  }
  String? get value => _value?.get();

  // editable
  BooleanObservable? _editable;
  set editable(dynamic v) {
    if (_editable != null) {
      _editable!.set(v);
    } else if (v != null) {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool? get editable => _editable?.get() ?? row?.editable;

  // selected
  BooleanObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else if (v != null) {
      _selected = BooleanObservable(Binding.toKey(id, 'selected'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get selected => _selected?.get() ?? false;

  // onChange - only used for simple data grid
  StringObservable? _onChange;
  set onChange(dynamic v) {
    if (_onChange != null) {
      _onChange!.set(v);
    } else if (v != null) {
      _onChange =
          StringObservable(Binding.toKey(id, 'onchange'), v, scope: scope);
    }
  }
  String? get onChange => _onChange?.get();

  TableRowCellModel(WidgetModel super.parent, super.id);

  static TableRowCellModel? fromXml(WidgetModel parent, XmlElement xml) {
    TableRowCellModel? model;
    try {
      model = TableRowCellModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'column.Model');
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
    value = Xml.get(node: xml, tag: 'value');
    onChange = Xml.get(node: xml, tag: 'onchange');
    if (_value == null) {
      var txt = findChildOfExactType(TextModel);
      if (txt is TextModel) value = txt.value;
    }
    editable = Xml.get(node: xml, tag: 'editable');
  }

  // on change handler - fired on cell edit
  Future<bool> onChangeHandler() async =>
      _onChange != null ? await EventHandler(this).execute(_onChange) : true;

  static bool usesRenderer(TableRowCellModel cell) {
    // no children
    if (cell.children?.isEmpty ?? true) return false;

    // multiple children
    if (cell.children!.length > 1) return true;

    // only child is not a text model
    if (cell.children!.first is! TextModel) return true;

    var xml = cell.children!.first.element!;

    // value is an eval
    if (cell.valueIsEval) return true;

    // text model has attributes other than text="" or label=""
    if (xml.attributes.firstWhereOrNull((a) =>
            a.name.local.toLowerCase() != "label" &&
            a.name.local.toLowerCase() != "value") !=
        null) return true;

    // text model has elements other than <TEXT/> or <LABEL/>
    if (xml.childElements.firstWhereOrNull((e) =>
            e.nodeType == XmlNodeType.ELEMENT &&
            e.name.local.toLowerCase() != "label" &&
            e.name.local.toLowerCase() != "value") !=
        null) return true;

    return false;
  }

  // returns true is the model has input fields
  static bool hasEnterableFields(TableRowCellModel cell) =>
      cell.findDescendantsOfExactType(InputModel).isNotEmpty;

  bool get valueIsEval => _value?.isEval ?? false;
}

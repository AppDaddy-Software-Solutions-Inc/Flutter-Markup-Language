// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/form/form_mixin.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/table_row_cell_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TableRowModel extends BoxModel  with FormMixin {

  @override
  String? get layout => super.layout ?? "row";

  // cells
  final List<TableRowCellModel> cells = [];

  // table
  TableModel? get table => parent is TableModel ? parent as TableModel : null;

  @override
  double? get paddingTop => super.paddingTop ?? table?.paddingTop;

  @override
  double? get paddingRight => super.paddingRight ?? table?.paddingRight;

  @override
  double? get paddingBottom => super.paddingBottom ?? table?.paddingBottom;

  @override
  double? get paddingLeft => super.paddingLeft ?? table?.paddingLeft;

  @override
  String? get halign => super.halign ?? table?.halign;

  @override
  String? get valign => super.valign ?? table?.valign;

  // cell by index
  TableRowCellModel? cell(int index) =>
      index >= 0 && index < cells.length ? cells[index] : null;

  // column uses editable
  bool get maybeEditable => _editable != null;

  // editable - used on non row prototype only
  BooleanObservable? _editable;
  set editable(dynamic v) {
    if (_editable != null) {
      _editable!.set(v);
    } else if (v != null) {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool? get editable => _editable?.get();

  // posting source source
  List<String>? _postbrokers;
  set postbrokers(dynamic v) {
    if (v is String) {
      var values = v.split(",");
      _postbrokers = [];
      for (var e in values) {
        if (!isNullOrEmpty(e)) _postbrokers!.add(e.trim());
      }
    }
  }
  List<String>? get postbrokers => _postbrokers;

  // selected
  BooleanObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else {
      _selected = BooleanObservable(Binding.toKey(id, 'selected'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get selected => _selected?.get() ?? false;

  // onclick
  StringObservable? _onClick;
  set onclick(dynamic v) {
    if (_onClick != null) {
      _onClick!.set(v);
    } else if (v != null) {
      _onClick = StringObservable(Binding.toKey(id, 'onclick'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onclick => _onClick?.get();

  // onComplete
  StringObservable? _onComplete;
  set oncomplete(dynamic v) {
    if (_onComplete != null) {
      _onComplete!.set(v);
    } else if (v != null) {
      _onComplete = StringObservable(Binding.toKey(id, 'oncomplete'), v,
          scope: scope, lazyEvaluation: true);
    }
  }
  String? get oncomplete => _onComplete?.get();

  // onInsert
  StringObservable? _onInsert;
  set onInsert(dynamic v) {
    if (_onInsert != null) {
      _onInsert!.set(v);
    } else if (v != null) {
      _onInsert = StringObservable(Binding.toKey(id, 'oninsert'), v,
          scope: scope, lazyEvaluation: true);
    }
  }
  String? get onInsert => _onInsert?.get();

  // onDelete
  StringObservable? _onDelete;
  set onDelete(dynamic v) {
    if (_onDelete != null) {
      _onDelete!.set(v);
    } else if (v != null) {
      _onDelete = StringObservable(Binding.toKey(id, 'ondelete'), v,
          scope: scope, lazyEvaluation: true);
    }
  }
  String? get onDelete => _onDelete?.get();

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

  TableRowModel(Model super.parent, super.id, {dynamic data})
      : super(scope: Scope(parent: parent.scope)) {
    this.data = data;
    dirty = false;
  }

  static TableRowModel? fromXml(Model parent, XmlElement? xml,
      {dynamic data}) {
    if (xml == null) return null;
    TableRowModel? model;
    try {
      model = TableRowModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'tableRow.Model');
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
    editable = Xml.get(node: xml, tag: 'editable');
    oncomplete = Xml.get(node: xml, tag: 'oncomplete');
    onclick = Xml.get(node: xml, tag: 'onclick');
    onInsert = Xml.get(node: xml, tag: 'oninsert');
    onDelete = Xml.get(node: xml, tag: 'ondelete');
    onChange = Xml.get(node: xml, tag: 'onchange');
    postbrokers = Xml.attribute(node: xml, tag: 'post') ?? Xml.attribute(node: xml, tag: 'postbroker');

    // get cells
    cells.addAll(findChildrenOfExactType(TableRowCellModel).cast<TableRowCellModel>());

    // row is a form?
    if (_postbrokers != null) {

      // build form fields and register dirty listeners to each
      fields = formFieldsOf(this);

      // Register Listener to Dirty Field
      for (var field in fields) {
        field.registerDirtyListener(onDirtyListener);
      }
    }
  }

  @override
  void onPropertyChange(Observable observable) {
    notifyListeners(observable.key, observable.get());
  }

  Future<bool> onClick(BuildContext context) async {
    if (onclick == null) return true;
    return await EventHandler(this).execute(_onClick);
  }

  // on change handler - fired on cell edit
  Future<bool> onChangeHandler() async =>
      _onChange != null ? await EventHandler(this).execute(_onChange) : true;

  Future<bool> complete() async {
    busy = true;

    // post the row
    bool ok = await _post();

    // mark row cells as clean
    if (ok) {
      dirty = false;
      for (var cell in cells) {
        cell.dirty = false;
      }
    }

    // mark fields as clean
    if (ok) {
      for (var field in fields) {
        field.dirty = false;
      }
    }

    busy = false;

    return ok;
  }

  Future<bool> _post() async {

    bool ok = true;
    if (scope != null && postbrokers != null) {

      for (String id in postbrokers!) {

        // get the post broker
        IDataSource? source = scope!.getDataSource(id);
        if (ok && source != null && table != null) {

          // build the posting body
          if (!source.custombody) {
            source.body = await FormMixin.buildPostingBody(table!, fields,
                rootname: source.root ?? "FORM");
          }

          ok = await source.start();
        }
        if (!ok) break;
      }
    } else {
      ok = false;
    }
    return ok;
  }

  Future<bool> onInsertHandler() async {
    // fire the onchange event
    bool ok = true;
    if (_onInsert != null) {
      ok = await EventHandler(this).execute(_onInsert);
    }
    return ok;
  }

  Future<bool> onDeleteHandler() async {
    // fire the onchange event
    bool ok = true;
    if (_onDelete != null) {
      ok = await EventHandler(this).execute(_onDelete);
    }
    return ok;
  }
}

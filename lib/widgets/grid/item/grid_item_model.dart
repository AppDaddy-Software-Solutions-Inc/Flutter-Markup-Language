// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/rendering.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/form/form_mixin.dart';
import 'package:fml/widgets/grid/grid_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class GridItemModel extends BoxModel with FormMixin {

  // indicates if the widget will grow in
  // its horizontal axis
  @override
  bool get expandHorizontally => false;

  // indicates if the widget will grow in
  // its vertical axis
  @override
  bool get expandVertically => false;

  // posting source source
  List<String>? _postbrokers;
  set postbrokers(dynamic v) {
    if (v is String) {
      List<String> values = v.split(",");
      _postbrokers = [];
      for (var e in values) {
        if (!isNullOrEmpty(e)) _postbrokers!.add(e.trim());
      }
    }
  }
  List<String>? get postbrokers => _postbrokers;

  // dataset  index
  // This property indicates your position on the dataset, 0 being the top
  IntegerObservable? get indexObservable => _index;
  IntegerObservable? _index;
  set index(dynamic v) {
    if (_index != null) {
      _index!.set(v);
    } else if (v != null) {
      _index = IntegerObservable(Binding.toKey(id, 'index'), v, scope: scope);
    }
  }
  int get index => _index?.get() ?? -1;

// indicates if this item has been selected
  BooleanObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else if (v != null) {
      _selected =
          BooleanObservable(Binding.toKey(id, 'selected'), v, scope: scope);
    }
  }
  bool get selected => _selected?.get() ?? false;

  // indicates that this item can be selected
  // by clicking it
  BooleanObservable? _selectable;
  set selectable(dynamic v) {
    if (_selectable != null) {
      _selectable!.set(v);
    } else if (v != null) {
      _selectable =
          BooleanObservable(Binding.toKey(id, 'selectable'), v, scope: scope);
    }
  }
  bool get selectable => _selectable?.get() ?? true;

  /// [Event]s to execute when the item is clicked
  StringObservable? _onClick;
  set onClick(dynamic v) {
    if (_onClick != null) {
      _onClick!.set(v);
    } else if (v != null) {
      _onClick = StringObservable(Binding.toKey(id, 'onclick'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onClick => _onClick?.get();

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

  GridItemModel(Model super.parent, super.id,
      {super.data, dynamic backgroundcolor})
      : super(scope: Scope(parent: parent.scope));

  static GridItemModel? fromXml(Model parent, XmlElement? xml, {dynamic data}) {
    GridItemModel? model;
    try {
      // build model
      model = GridItemModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'grid.item.Model');
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
    selected = Xml.get(node: xml, tag: 'selected');
    selectable = Xml.get(node: xml, tag: 'selectable');
    onClick = Xml.get(node: xml, tag: 'onclick');
    onInsert = Xml.get(node: xml, tag: 'oninsert');
    onDelete = Xml.get(node: xml, tag: 'ondelete');
    postbrokers = Xml.attribute(node: xml, tag: 'post') ?? Xml.attribute(node: xml, tag: 'postbroker');

    // grid item is a form?
    if (_postbrokers != null) {

      // build form fields and register dirty listeners to each
      fields = formFieldsOf(this);

      // Register Listener to Dirty Field
      for (var field in fields) {
        field.registerDirtyListener(onDirtyListener);
      }
    }
  }

  Future<bool> onTap() async {
    if (!selectable) return true;
    var grid = findAncestorOfExactType(GridModel);
    if (grid is GridModel) {
      grid.onTap(this);
    }
    return true;
  }

  @override
  void onDrop(IDragDrop draggable, {Offset? dropSpot}) {
    if (parent is GridModel) {
      (parent as GridModel).onDragDrop(this, draggable, dropSpot: dropSpot);
    }
  }

  Future<bool> _post() async {
    if (dirty == false) return true;

    var list = findAncestorOfExactType(GridModel);

    bool ok = true;
    if (list != null && scope != null && postbrokers != null) {
      for (String id in postbrokers!) {
        IDataSource? source = scope!.getDataSource(id);
        if (source != null && ok && list != null) {
          if (!source.custombody) {
            source.body = await FormMixin.buildPostingBody(list!, fields,
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

  Future<bool> complete() async {
    busy = true;

    // post the ITEM
    bool ok = await _post();

    // mark fields as clean
    if (ok) {
      for (var field in fields) {
        field.dirty = false;
      }
    }

    busy = false;

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

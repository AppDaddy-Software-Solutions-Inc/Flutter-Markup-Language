// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/table/table_header_group_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TableHeaderModel extends BoxModel {
  @override
  String? get layout => super.layout ?? "column";

  // rendered group models
  final List<TableHeaderGroupModel> groups = [];

  // rendered cell models
  final List<TableHeaderCellModel> cells = [];

  // dynamic cells
  bool get isDynamic => prototypes.isNotEmpty;
  var prototypes = <XmlElement, Model?>{};

  // list of static cell ids
  // used in dynamic table creation
  List<String>? staticFields;

  // cell by index
  TableHeaderCellModel? cell(int index) =>
      index >= 0 && index < cells.length ? cells[index] : null;

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

  // show menu
  BooleanObservable? _menu;
  set menu(dynamic v) {
    if (_menu != null) {
      _menu!.set(v);
    } else if (v != null) {
      _menu = BooleanObservable(Binding.toKey(id, 'menu'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get menu => _menu?.get() ?? table?.menu ?? true;

  // allow sorting
  BooleanObservable? _sortable;
  set sortable(dynamic v) {
    if (_sortable != null) {
      _sortable!.set(v);
    } else if (v != null) {
      _sortable = BooleanObservable(Binding.toKey(id, 'sortable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get sortable => _sortable?.get() ?? table?.sortable ?? true;

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

  bool? get editable => _editable?.get() ?? table?.editable;

  // allow filtering
  BooleanObservable? _filter;
  set filter(dynamic v) {
    if (_filter != null) {
      _filter!.set(v);
    } else if (v != null) {
      _filter = BooleanObservable(Binding.toKey(id, 'filter'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get filter => _filter?.get() ?? table?.filter ?? false;

  // size - defines how columns are fitted
  StringObservable? _fit;
  set fit(dynamic v) {
    if (_fit != null) {
      _fit!.set(v);
    } else if (v != null) {
      _fit = StringObservable(Binding.toKey(id, 'fit'), v,
          scope: scope, listener: onFitChange);
    }
  }

  String? get fit => _fit?.get();

  // resize - defines how columns resized
  StringObservable? _resize;
  set resize(dynamic v) {
    if (_resize != null) {
      _resize!.set(v);
    } else if (v != null) {
      _resize = StringObservable(Binding.toKey(id, 'resize'), v,
          scope: scope, listener: onFitChange);
    }
  }

  String? get resize => _resize?.get();

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

  TableHeaderModel(Model super.parent, super.id)
      : super(scope: Scope(parent: parent.scope));

  static TableHeaderModel? fromXml(Model parent, XmlElement xml,
      {Map<dynamic, dynamic>? data}) {
    TableHeaderModel? model;
    try {
      model = TableHeaderModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'tableHeader.Model');
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
    menu = Xml.get(node: xml, tag: 'menu');
    sortable = Xml.get(node: xml, tag: 'sortable');
    resizeable = Xml.get(node: xml, tag: 'resizeable');
    editable = Xml.get(node: xml, tag: 'editable');
    filter = Xml.get(node: xml, tag: 'filter');
    fit = Xml.get(node: xml, tag: 'fit');
    resize = Xml.get(node: xml, tag: 'resize');

    // events
    onInsert = Xml.get(node: xml, tag: 'oninsert');
    onDelete = Xml.get(node: xml, tag: 'ondelete');
    onChange = Xml.get(node: xml, tag: 'onchange');

    // get header cells
    cells.addAll(
        findDescendantsOfExactType(TableHeaderCellModel, breakOn: TableModel)
            .cast<TableHeaderCellModel>());
    if (cells.isEmpty) _buildDefaultCell();

    // get cell groups
    groups.addAll(
        findDescendantsOfExactType(TableHeaderGroupModel, breakOn: TableModel)
            .cast<TableHeaderGroupModel>());

    // remove cells from child list
    removeChildrenOfExactType(TableHeaderCellModel);

    // build dynamic prototypes
    _buildDynamicPrototypes();
  }

  // on change handler - fired on cell edit
  Future<bool> onChangeHandler() async =>
      _onChange != null ? await EventHandler(this).execute(_onChange) : true;

  void _buildDefaultCell() {
    var td = XmlElement(XmlName("TD"));
    Xml.setAttribute(td, "field", TableModel.dynamicTableValue2);
    var cell = TableHeaderCellModel.fromXml(this, td);
    if (cell != null) cells.add(cell);
  }

  void _buildDynamicPrototypes() {
    bool hasDynamicCells =
        cells.firstWhereOrNull((cell) => cell.isDynamic) != null;
    if (hasDynamicCells) {
      for (var cell in cells) {
        var e = cell.element!.copy();
        if (cell.isDynamic) {
          e.attributes.add(XmlAttribute(XmlName("dynamic"), "true"));
        } else {
          staticFields ??= [];
          staticFields!.add(cell.id);
        }
        prototypes[e] = cell.parent;
      }
    }
  }

  void onFitChange(Observable observable) => table?.autosize(fit);

  @override
  dispose() {
    super.dispose();

    // dispose of cells
    for (var cell in cells) {
      cell.dispose();
    }
  }
}

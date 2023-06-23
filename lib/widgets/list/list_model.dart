// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/handler.dart'            ;
import 'package:fml/widgets/list/list_view.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'     ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class ListModel extends DecoratedWidgetModel implements IForm, IScrolling
{
  final HashMap<int,ListItemModel> items = HashMap<int,ListItemModel>();

  // prototype
  XmlElement? prototype;

  // full list of data
  // pointing to data broker data
  Data? _dataset;

  // returns the number of records in the dataset
  int? get records => _dataset?.length;

  BooleanObservable? _scrollShadows;
  set scrollShadows (dynamic v)
  {
    if (_scrollShadows != null)
    {
      _scrollShadows!.set(v);
    }
    else if (v != null)
    {
      _scrollShadows = BooleanObservable(Binding.toKey(id, 'scrollshadows'), v, scope: scope);
    }
  }
  bool get scrollShadows => _scrollShadows?.get() ?? false;
  
  BooleanObservable? _scrollButtons;
  set scrollButtons (dynamic v)
  {
    if (_scrollButtons != null)
    {
      _scrollButtons!.set(v);
    }
    else if (v != null)
    {
      _scrollButtons = BooleanObservable(Binding.toKey(id, 'scrollbuttons'), v, scope: scope);
    }
  }
  bool get scrollButtons => _scrollButtons?.get() ?? false;


  // moreup 
  BooleanObservable? _moreUp;
  @override
  set moreUp (dynamic v)
  {
    if (_moreUp != null)
    {
      _moreUp!.set(v);
    }
    else if (v != null)
    {
      _moreUp = BooleanObservable(Binding.toKey(id, 'moreup'), v, scope: scope);
    }
  }
  @override
  bool? get moreUp => _moreUp?.get();

  // moreDown 
  BooleanObservable? _moreDown;
  @override
  set moreDown (dynamic v)
  {
    if (_moreDown != null)
    {
      _moreDown!.set(v);
    }
    else if (v != null)
    {
      _moreDown = BooleanObservable(Binding.toKey(id, 'moredown'), v, scope: scope);
    }
  }
  @override
  bool? get moreDown => _moreDown?.get();

  // moreLeft 
  BooleanObservable? _moreLeft;
  @override
  set moreLeft (dynamic v)
  {
    if (_moreLeft != null)
    {
      _moreLeft!.set(v);
    }
    else if (v != null)
    {
      _moreLeft = BooleanObservable(Binding.toKey(id, 'moreleft'), v, scope: scope);
    }
  }
  @override
  bool? get moreLeft => _moreLeft?.get();

  // moreRight 
  BooleanObservable? _moreRight;
  @override
  set moreRight (dynamic v)
  {
    if (_moreRight != null)
    {
      _moreRight!.set(v);
    }
    else if (v != null)
    {
      _moreRight = BooleanObservable(Binding.toKey(id, 'moreright'), v, scope: scope);
    }
  }
  @override
  bool? get moreRight => _moreRight?.get();

  // dirty 
  @override
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
  @override
  set dirty (dynamic v)
  {
    if (_dirty != null)
    {
      _dirty!.set(v);
    }
    else if (v != null)
    {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope);
    }
  }
  @override
  bool get dirty => _dirty?.get() ?? false;

  void onDirtyListener(Observable property)
  {
    bool isDirty = false;
      for (var entry in items.entries)
      {
        if ((entry.value.dirty == true))
        {
          isDirty = true;
          break;
        }
      }
    dirty = isDirty;
  }

  // Clean 
  @override
  set clean (bool b)
  {
    dirty = false;
      items.forEach((index, item) => item.dirty = false);
  }

  // oncomplete 
  StringObservable? _oncomplete;
  set oncomplete (dynamic v)
  {
    if (_oncomplete != null)
    {
      _oncomplete!.set(v);
    }
    else if (v != null)
    {
      _oncomplete = StringObservable(Binding.toKey(id, 'oncomplete'), v, scope: scope, lazyEval: true);
    }
  }
  String? get oncomplete => _oncomplete?.get();

  // Direction 
  StringObservable? _direction;
  set direction (dynamic v)
  {
    if (_direction != null)
    {
      _direction!.set(v);
    }
    else if (v != null)
    {
      _direction = StringObservable(Binding.toKey(id, 'direction'), v, scope: scope, listener: onPropertyChange);
    }
  }
  dynamic get direction => _direction?.get();

  BooleanObservable? _collapsed;
  set collapsed (dynamic v)
  {
    if (_collapsed != null)
    {
      _collapsed!.set(v);
    }
    else if (v != null)
    {
      _collapsed = BooleanObservable(Binding.toKey(id, 'collapsed'), v, scope: scope);
    }
  }
  bool get collapsed => _collapsed?.get() ?? false;

  /// Calls an [Event] String when the scroll overscrolls
  StringObservable? _onpulldown;
  set onpulldown (dynamic v)
  {
    if (_onpulldown != null)
    {
      _onpulldown!.set(v);
    }
    else if (v != null)
    {
      _onpulldown = StringObservable(Binding.toKey(id, 'onpulldown'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  dynamic get onpulldown => _onpulldown?.get();

  BooleanObservable? _draggable;
  set draggable(dynamic v) {
    if (_draggable != null) {
      _draggable!.set(v);
    } else if (v != null) {
      _draggable = BooleanObservable(Binding.toKey(id, 'draggable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get draggable => _draggable?.get() ?? false;

  BooleanObservable? _reverse;
  set reverse(dynamic v) {
    if (_reverse != null) {
      _reverse!.set(v);
    } else if (v != null) {
      _reverse = BooleanObservable(Binding.toKey(id, 'reverse'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get reverse => _reverse?.get() ?? false;

  ListModel(WidgetModel? parent, String? id, {dynamic direction, dynamic reverse, dynamic draggable, dynamic scrollShadows, dynamic onpulldown}) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    this.direction = direction;
    this.reverse = reverse;
    this.draggable = draggable;
    this.onpulldown = onpulldown;
    this.scrollShadows = scrollShadows;
    scrollButtons = scrollButtons;
    collapsed = collapsed;
    moreUp = false;
    moreDown = false;
    moreLeft = false;
    moreRight = false;
  }

  static ListModel? fromXml(WidgetModel? parent, XmlElement xml)
  {
    ListModel? model;
    try
    {
      model = ListModel(parent, Xml.get(node: xml, tag: 'id'));


      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'list.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    direction  = Xml.get(node: xml, tag: 'direction');
    draggable = Xml.get(node: xml, tag: 'draggable');
    scrollShadows = Xml.get(node: xml, tag: 'scrollshadows');
    scrollButtons = Xml.get(node: xml, tag: 'scrollbuttons');
    collapsed = Xml.get(node: xml, tag: 'collapsed');
    onpulldown  = Xml.get(node: xml, tag: 'onpulldown');
    reverse  = Xml.get(node: xml, tag: 'reverse');

    // clear items
    this.items.forEach((_,item) => item.dispose());
    this.items.clear();

    // Process Items
    int i = 0;
    List<ListItemModel> items = findChildrenOfExactType(ListItemModel).cast<ListItemModel>();

    // set prototype
    if ((!S.isNullOrEmpty(datasource)) && (items.isNotEmpty))
    {
      prototype = WidgetModel.prototypeOf(items[0].element);
      items.removeAt(0);
    }

    // build items
    for (var item in items) {
      this.items[i++] = item;
    }
  }

  ListItemModel? getItemModel(int index)
  {
    // fixed list?
    if (S.isNullOrEmpty(datasource)) return (index < items.length) ? items[index] : null;

    // item model exists?
    if (_dataset == null) return null;

    var list = _dataset!;
    if (list.length < (index + 1)) return null;
    if (items.containsKey(index)) return items[index];
    if (index.isNegative || list.length < index) return null;

    // build item model
    var model = ListItemModel.fromXml(this, prototype, data: list[index]);
    if (model != null)
    {
      // set the index
      model.index = index;

      // set the selected data
      if (model.selected == true)
      {
        // this must be done after the build
        WidgetsBinding.instance.addPostFrameCallback((_) => data = model.data);
      }

      // register listener to dirty field
      if (model.dirtyObservable != null) model.dirtyObservable!.registerListener(onDirtyListener);

      // save model
      items[index] = model;
    }

    return model;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    busy = true;

      clean = true;

      // clear items
      items.forEach((_,item) => item.dispose());
      items.clear();

    if (list != null)
    {_dataset = list;   }
    else _dataset = Data();
    notifyListeners('list', items);

    busy = false;
    return true;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');

    // clear items
    items.forEach((_,item) => item.dispose());
    items.clear();

    super.dispose();
  }

  @override
  Future<bool> complete() async
  {
    busy = true;

    bool ok = true;

    // Post the Form
    if (dirty) {for (var entry in items.entries) {
      ok = await entry.value.complete();
    }}

    busy = false;
    return ok;
  }

  @override
  Future<bool> onComplete(BuildContext context) async
  {
    return await EventHandler(this).execute(_oncomplete);
  }

  @override
  Future<bool> save() async
  {
    // not implemented
    return true;
  }

  Future<void> onPull(BuildContext context) async
  {
    await EventHandler(this).execute(_onpulldown);
  }

  Future<bool> onTap(ListItemModel? model) async
  {
    items.forEach((key, item)
    {
       if (item == model)
       {
         // toggle selected
         bool isSelected = (item.selected ?? false) ? false : true;

         // set values
         item.selected = isSelected;
         data = isSelected ? item.data : Data();
       }
       else
       {
         item.selected = false;
       }
    });
    return true;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      // selects the item by index
      case "select" :
        int index = S.toInt(S.item(arguments, 0)) ?? -1;
        if (index >= 0 && index < items.length)
        {
          var model = items[index];
          if (model != null && model.selected == false) onTap(model);
        }
        return true;

      // de-selects the item by index
      case "deselect" :
        int index = S.toInt(S.item(arguments, 0)) ?? -1;
        if (index >= 0 && _dataset != null && index < _dataset!.length)
        {
          var model = items[index];
          if (model != null && model.selected == true) onTap(model);
        }
        return true;

    // de-selects the item by index
      case "clear" :
        onTap(null);
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(ListLayoutView(this));
}

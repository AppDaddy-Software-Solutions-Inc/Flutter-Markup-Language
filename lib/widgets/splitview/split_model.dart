// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/splitview/split_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class SplitModel extends BoxModel
{
  @override
  String? get layout => vertical ? "column" : "row";

  /// vertical or horizontal splitter?
  bool? _vertical;
  bool get vertical => _vertical ?? false;

  /// left:right view size ratio
  final double defaultRatio = 0.25;
  DoubleObservable? _ratio;
  set ratio (dynamic v)
  {
    if (_ratio != null)
    {
      _ratio!.set(v);
    }
    else if (v != null)
    {
      _ratio = DoubleObservable(Binding.toKey(id, 'ratio'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get ratio => _ratio?.get() ?? defaultRatio;
  
  /// The splitter bar divider color
  ColorObservable? _dividerColor;
  set dividerColor (dynamic v)
  {
    if (_dividerColor != null)
    {
      _dividerColor!.set(v);
    }
    else if (v != null)
    {
      _dividerColor = ColorObservable(Binding.toKey(id, 'dividercolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get dividerColor => _dividerColor?.get();

  /// The splitter bar divider width
  DoubleObservable? _dividerWidth;
  set dividerWidth (dynamic v)
  {
    if (_dividerWidth != null)
    {
      _dividerWidth!.set(v);
    }
    else if (v != null)
    {
      _dividerWidth = DoubleObservable(Binding.toKey(id, 'dividerwidth'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get dividerWidth
  {
    var width = _dividerWidth?.get() ?? (System().useragent == 'desktop' || isNullOrEmpty(System().useragent) ? 6.0 : 12.0);
    if (width % 2 != 0) width = width + 1;
    return width;
  }

  /// The splitter bar divider handle color
  ColorObservable? _dividerHandleColor;
  set dividerHandleColor (dynamic v)
  {
    if (_dividerHandleColor != null)
    {
      _dividerHandleColor!.set(v);
    }
    else if (v != null)
    {
      _dividerHandleColor = ColorObservable(Binding.toKey(id, 'dividerhandlecolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get dividerHandleColor => _dividerHandleColor?.get();
  
  SplitModel(WidgetModel super.parent, super.id, {bool? vertical})
  {
    if (vertical != null) _vertical = vertical;
  }

  static SplitModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    SplitModel? model;
    try
    {
      model = SplitModel(parent, Xml.get(node: xml, tag: 'id'), vertical: Xml.get(node: xml, tag: 'direction') == "vertical");
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'form.Model');
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
    ratio = Xml.get(node: xml, tag: 'ratio');
    dividerColor = Xml.get(node: xml, tag: 'dividercolor');
    dividerWidth = Xml.get(node: xml, tag: 'dividerwidth');
    dividerHandleColor  = Xml.get(node: xml, tag: 'dividerhandlecolor');

    // remove non view children
    children?.removeWhere((element) => element is! BoxModel);
  }

  @override
  List<Widget> inflate()
  {
    SplitViewState? view = findListenerOfExactType(SplitViewState);
    if (view == null) return [];
    return view.inflate();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(SplitView(this));
}



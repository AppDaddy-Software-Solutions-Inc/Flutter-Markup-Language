// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/animation/animation_model.dart';
import 'package:fml/widgets/animation/animation_view.dart';
import 'package:fml/widgets/widget/constraint.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class ViewableWidgetModel extends WidgetModel
{
  // Width
  double? _widthPercentage;
  double? get widthPercentage => _widthPercentage;
  DoubleObservable? _width;
  set width(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _widthPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else _widthPercentage = null;
      if (v != null && v.runtimeType == String && v.contains('%'))
      {
        String s = v;
        v = s.replaceAll('%', '000000');
      }
      if (_width == null)
           _width = DoubleObservable(Binding.toKey(id, 'width'), v, scope: scope, listener: onPropertyChange);
      else if (v != null) _width!.set(v);
    }
  }
  double? get width => _width?.get();

  // Height
  double? _heightPercentage;
  double? get heightPercentage => _heightPercentage;
  DoubleObservable? _height;
  set height(dynamic v)
  {
    if (v != null)
    {
      if (S.isPercentage(v))
      {
        _heightPercentage = S.toDouble(v.split("%")[0]);
        v = null;
      }
      else _heightPercentage = null;
      if (v != null && v.runtimeType == String && v.contains('%'))
      {
        String s = v;
        v = s.replaceAll('%', '000000');
      }
      if (_height == null)
        _height = DoubleObservable(Binding.toKey(id, 'height'), v, scope: scope, listener: onPropertyChange);
      else if (v != null) _height!.set(v);
    }
  }
  double? get height => _height?.get();

  // Constraints
  final Constraint _modelConstraints = Constraint();
  final Constraint _viewConstraints  = Constraint();

  bool get hasVerticalSizing    => ((height != null) && (height! >= 0)) || (_modelConstraints.minHeight != null) || (_modelConstraints.maxHeight != null);
  bool get haslHorizontalSizing => ((width  != null) && (width!  >= 0)) || (_modelConstraints.minWidth  != null) || (_modelConstraints.maxWidth  != null);
  bool get hasSizing => hasVerticalSizing || haslHorizontalSizing;

  // Min Width
  set minWidth(double? v) => _viewConstraints.minWidth = v;
  double? get minWidth
  {
    double? v;
    if ((v == null) && (_viewConstraints.minWidth != null) && (_viewConstraints.minWidth != double.infinity)) v = _viewConstraints.minWidth;
    if ((v == null) && (parent is ViewableWidgetModel)) v = (parent as ViewableWidgetModel).minWidth;
    return v;
  }

  // Min Height
  set minHeight(double? v) => _viewConstraints.minHeight = v;
  double? get minHeight
  {
    double? v;
    if ((v == null) && (_viewConstraints.minHeight  != null) && (_viewConstraints.minHeight  != double.infinity)) v = _viewConstraints.minHeight;
    if ((v == null) && (parent is ViewableWidgetModel)) v = (parent as ViewableWidgetModel).minHeight;
    return v;
  }

  // Max Width
  set maxWidth(double? v)
  {
    _viewConstraints.maxWidth = v;
    if (_width?.value != null && _width!.value >= 100000) _widthPercentage = (_width!.value / 1000000)!;
    if (_widthPercentage != null)
    {
      double? width;
      var maxwidth = this.maxWidth;
      if (maxwidth != null)
      {
        width = maxwidth * (_widthPercentage! / 100.0);
        if ((_modelConstraints.minWidth != null) && (_modelConstraints.minWidth! > width))  width = _modelConstraints.minWidth;
        if ((_modelConstraints.maxWidth != null) && (_modelConstraints.maxWidth! < width!)) width = _modelConstraints.maxWidth;
      }
      _width?.set(width, notify: false);
    }
  }
  double? get maxWidth
  {
    double? v;
    if ((v == null) && (_viewConstraints.maxWidth != null) && (_viewConstraints.maxWidth != double.infinity)) v = _viewConstraints.maxWidth;
    if ((v == null) && (parent != null))
    {
      ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
      if (parent?.padding != null)
      {
        var vpad = getParentHPadding(parent!.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        v = (parent.width != null) ? (parent.width! - vpad) : (parent.maxWidth! - vpad);
      }
      else if (parent != null) v = (parent.width ?? parent.maxWidth);
    }
    return v;
  }

  // Max Height
  set maxHeight(double? v)
  {
    _viewConstraints.maxHeight = v;

    if (_height?.value != null && _height!.value >= 100000) _heightPercentage = (_height!.value / 1000000)!;
    if (_heightPercentage != null)
    {
      double? height;
      var maxheight = this.maxHeight;
      if (maxheight != null)
      {
        if (this.parent != null)
        {
          double vpadding = 0;
          ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
          if (parent != null) vpadding = getParentVPadding(parent.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);

          height = ((maxheight - vpadding) * (_heightPercentage! / 100.0));
          if ((_modelConstraints.minHeight!= null) && (_modelConstraints.minHeight! > height)) height = _modelConstraints.minHeight?? 0;
          if ((_modelConstraints.maxHeight!= null) && (_modelConstraints.maxHeight! < height)) height = _modelConstraints.maxHeight;
        }
      }
      _height?.set(height, notify: false);
    }
  }
  double? get maxHeight
  {
    double? v;
    if ((v == null) && (_viewConstraints.maxHeight != null) && (_viewConstraints.maxHeight != double.infinity)) v = _viewConstraints.maxHeight;
    if ((v == null) && (parent != null))
    {
      ViewableWidgetModel? parent = (this.parent is ViewableWidgetModel) ? (this.parent as ViewableWidgetModel) : null;
      if (parent?.padding != null && _heightPercentage == null)
      {
        var vpad = getParentVPadding(parent!.paddings, parent.padding, parent.padding2, parent.padding3, parent.padding4);
        v = (parent.height != null) ? (parent.height! - vpad) : (parent.maxHeight! - vpad);
      }
      else if (parent != null) v = (parent.height ?? parent.maxHeight);
    }
    return v;
  }

  /// alignment and layout attributes
  ///
  /// The horizontal alignment of the widgets children, overrides `center`. Can be `left`, `right`, `start`, or `end`.
  StringObservable? _halign;
  set halign(dynamic v)
  {
    if (_halign != null)
    {
      _halign!.set(v);
    }
    else if (v != null)
    {
      _halign = StringObservable(Binding.toKey(id, 'halign'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get halign => _halign?.get();

  /// The vertical alignment of the widgets children, overrides `center`. Can be `top`, `bottom`, `start`, or `end`.
  StringObservable? _valign;
  set valign(dynamic v)
  {
    if (_valign != null)
    {
      _valign!.set(v);
    }
    else if (v != null)
    {
      _valign = StringObservable(Binding.toKey(id, 'valign'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get valign => _valign?.get();

  // used by the veiw to determine if it needs to wrap itself
  // in a VisibilityDetector
  bool? _visibilityDetector;
  bool get needsVisibilityDetector => _visibilityDetector ?? false;

  /// onstage event string - fires when object is 100 on screen
  StringObservable? _onstage;
  set onstage(dynamic v)
  {
    if (_onstage != null)
    {
      _onstage!.set(v);
    }
    else if (v != null)
    {
      _onstage = StringObservable(Binding.toKey(id, 'onstage'), v, scope: scope);

      // create the visibility tag
      visibility = 0;
    }
  }
  String? get onstage => _onstage?.get();

  /// offstage event string - fires when object is 100 on screen
  StringObservable? _offstage;
  set offstage(dynamic v)
  {
    if (_offstage != null)
    {
      _offstage!.set(v);
    }
    else if (v != null)
    {
      _offstage = StringObservable(Binding.toKey(id, 'offstage'), v, scope: scope);

      // create the visibility tag
      visibility = 0;
    }
  }
  String? get offstage => _offstage?.get();

  /// visibility - percent of object visible on screen
  DoubleObservable? _visibility;
  set visibility(dynamic v)
  {
    if (_visibility != null)
    {
      _visibility!.set(v);
    }
    else if (v != null)
    {
      _visibility = DoubleObservable(Binding.toKey(id, 'visibility'), v, scope: scope);
    }
  }
  double? get visibility => _visibility?.get();

  // animations
  Map<String, AnimationModel>? _animationmap;
  List<String>? _animations;
  set animations(dynamic v)
  {
    if (v is String)
    {
      var s = v.split(",");
      _animations = [];
      s.forEach((element) => _animations!.add(element.trim()));
    }
  }
  List<String> get animations => List.unmodifiable(_animations ?? []);

  int paddings = 0; 
  set _paddings(dynamic v)
  {
    // build PADDINGS array
    if (v is String)
    {
      var s = v.split(',');
      paddings = s.length;
      if (s.length > 0) padding  = s[0];
      if (s.length > 1) padding2 = s[1];
      if (s.length > 2) padding3 = s[2];
      if (s.length > 3) padding4 = s[3];
    }
  }

  // padding
  DoubleObservable? _padding;
  set padding(dynamic v)
  {
    if (_padding != null) _padding!.set(v);
    else if (v != null) _padding = DoubleObservable(Binding.toKey(id, 'pad'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding => _padding?.get() ?? 0;

  // padding 2
  DoubleObservable? _padding2;
  set padding2(dynamic v)
  {
    if (_padding2 != null) _padding2!.set(v);
    else if (v != null) _padding2 = DoubleObservable(Binding.toKey(id, 'pad2'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding2 => _padding2?.get() ?? 0;

  // padding 3
  DoubleObservable? _padding3;
  set padding3(dynamic v)
  {
    if (_padding3 != null) _padding3!.set(v);
    else if (v != null) _padding3 = DoubleObservable(Binding.toKey(id, 'pad3'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding3 => _padding3?.get() ?? 0;

  // padding 4
  DoubleObservable? _padding4;
  set padding4(dynamic v)
  {
    if (_padding4 != null) _padding4!.set(v);
    else if (v != null) _padding4 = DoubleObservable(Binding.toKey(id, 'pad4'), v, scope: scope, listener: onPropertyChange);
  }
  double get padding4 => _padding4?.get() ?? 0;
  
  
  // visible
  BooleanObservable? _visible;
  set visible(dynamic v)
  {
    if (_visible != null)
    {
      _visible!.set(v);
    }
    else if (v != null)
    {
      _visible = BooleanObservable(Binding.toKey(id, 'visible'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get visible => _visible?.get() ?? true;

  // is visible
  static bool isVisible(DecoratedWidgetModel? widget)
  {
    if (widget == null) return false;
    if (widget.visible == false) return false;
    if (widget.parent is DecoratedWidgetModel) return isVisible(widget.parent as DecoratedWidgetModel);
    return true;
  }

  // enabled
  BooleanObservable? _enabled;
  set enabled(dynamic v)
  {
    if (_enabled != null)
    {
      _enabled!.set(v);
    }
    else if (v != null)
    {
      _enabled = BooleanObservable(Binding.toKey(id, 'enabled'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get enabled => _enabled?.get() ?? true;

  ViewableWidgetModel(WidgetModel? parent, String? id, {Scope?  scope}) : super(parent, id, scope: scope);

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // set constraints
    _modelConstraints.minWidth  = S.toDouble(Xml.get(node: xml, tag: 'minwidth'));
    _modelConstraints.maxWidth  = S.toDouble(Xml.get(node: xml, tag: 'maxwidth'));
    _modelConstraints.minHeight = S.toDouble(Xml.get(node: xml, tag: 'minheight'));
    _modelConstraints.maxHeight = S.toDouble(Xml.get(node: xml, tag: 'maxheight'));

    // properties
    visible   = Xml.get(node: xml, tag: 'visible');
    enabled   = Xml.get(node: xml, tag: 'enabled');
    width     = Xml.get(node: xml, tag: 'width');
    height    = Xml.get(node: xml, tag: 'height');
    halign    = Xml.get(node: xml, tag: 'halign');
    valign    = Xml.get(node: xml, tag: 'valign');
    onstage   = Xml.get(node: xml, tag: 'onstage');
    offstage  = Xml.get(node: xml, tag: 'offstage');
    animations = Xml.attribute(node: xml, tag: 'animation');

    // view requires a VisibilityDetector if either onstage or offstage is set or
    // someone is bound to my visibility
    _visibilityDetector = !S.isNullOrEmpty(onstage) || !S.isNullOrEmpty(offstage) || WidgetModel.isBound(this, Binding.toKey(id, 'visibility'));

    // pad is always defined as an attribute. PAD as an element name is the PADDING widget
    _paddings = Xml.attribute(node: xml, tag: 'pad');
  }

  static double getParentVPadding(int paddings, double? padding, double padding2, double padding3, double padding4)
  {
    double insets = 0.0;
    if (paddings > 0)
    {
      // pad all
      if (paddings == 1) insets = (padding ?? 0) * 2;

      // pad directions v,h
      else if (paddings == 2) insets = (padding ?? 0) * 2;

      // pad sides top, right, bottom, left
      else if (paddings > 2) insets = (padding ?? 0) + padding3;
    }
    //should add up all of the padded siblings to do this so you can have multiple padded siblings unconstrained.
    return insets;
  }

  static double getParentHPadding(int paddings, double? padding, double padding2, double padding3, double padding4)
  {
    double insets = 0.0;
    if (paddings > 0)
    {
      // pad all
      if (paddings == 1) insets = (padding ?? 0) * 2;

      // pad directions v,h
      else if (paddings == 2) insets = padding2 * 2;

      // pad sides top, right, bottom, left
      else if (paddings > 2) insets = padding2 + padding4;
    }

    //should add up all of the padded siblings to do this.
    return insets;
  }

  Constraint getConstraints()
  {
    Constraint constraint = Constraint();
    constraint.minHeight = height ?? _modelConstraints.minHeight ?? minHeight ?? 0.0;
    constraint.maxHeight = height ?? _modelConstraints.maxHeight ?? maxHeight ?? double.infinity;
    constraint.minWidth  = width  ?? _modelConstraints.minWidth  ?? minWidth  ?? 0.0;
    constraint.maxWidth  = width  ?? _modelConstraints.maxWidth  ?? maxWidth  ?? double.infinity;

    // ensure not negative
    if(constraint.minHeight! < 0) constraint.minHeight = 0;
    if(constraint.maxHeight! < 0) constraint.maxHeight = double.infinity;

    // ensure max > min
    if (constraint.minHeight! > constraint.maxHeight!)
    {
      if (_modelConstraints.maxHeight != null)
        constraint.minHeight = constraint.maxHeight;
      else constraint.maxHeight = constraint.minHeight;
    }

    // ensure not negative
    if(constraint.minWidth! < 0) constraint.minWidth = 0;
    if(constraint.maxWidth! < 0) constraint.maxWidth = double.infinity;

    // ensure max > min
    if (constraint.minWidth! > constraint.maxWidth!)
    {
      if (_modelConstraints.maxWidth != null)
        constraint.minWidth = constraint.maxWidth;
      else constraint.maxWidth = constraint.minWidth;
    }
    return constraint;
  }

  AnimationModel? getAnimationModel(String id)
  {
    // model already created
    if (_animationmap != null && _animationmap!.containsKey(id)) return _animationmap![id];

    var model = Scope.findWidgetModel(id, scope);
    if (model is AnimationModel && model.element != null)
    {
      // make a copy of the model
      var xml = model.element!.copy();

      // we dont want duplicate model ids
      Xml.setAttribute(xml, "id", Uuid().v4().toString());

      // build the model
      model = AnimationModel.fromXml(this, model.element!);
      if (model is AnimationModel)
      {
        // add to map
        if (_animationmap == null) _animationmap = Map<String, AnimationModel>();
        _animationmap![id] = model;
        return model;
      }
    }
    return null;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case "animate" :
        if (_animationmap != null)
        {
          var _id = S.item(arguments, 0);
          if (_id == null && animations.isNotEmpty) _id = animations.first;
          if (_animationmap!.containsKey(_id)) _animationmap![_id]!.execute(caller, propertyOrFunction, arguments);
        }
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  // set visibility
  void onVisibilityChanged(VisibilityInfo info)
  {
    visibility = info.visibleFraction * 100;
    if (visibility! > 0)
         EventHandler(this).execute(_onstage);
    else EventHandler(this).execute(_offstage);
  }

  Widget getReactiveView(Widget view)
  {
    // wrap in visibility detector
    if (needsVisibilityDetector) view = VisibilityDetector(key: ObjectKey(this), onVisibilityChanged: onVisibilityChanged, child: view);
    if (this.animations.isEmpty) return view;

    var animations = this.animations.reversed;
    animations.forEach((element)
    {
      var model = getAnimationModel(element);
      if (model != null) view = AnimationView(model, view);
    });
    return view;
  }
}

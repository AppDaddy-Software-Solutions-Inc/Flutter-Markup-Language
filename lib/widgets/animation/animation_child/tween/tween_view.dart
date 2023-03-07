// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/tween/tween_model.dart'
    as TweenModel;
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class TweenView extends StatefulWidget {
  final TweenModel.AnimationModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController controller;

  TweenView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  TweenViewState createState() => TweenViewState();
}

class TweenViewState extends State<TweenView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  late Animation<dynamic> _animation;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller;

    widget.model.value = widget.model.from;

    _controller.addListener(() {
      setState(() {
        if (widget.model.type == "color") {
          widget.model.value = "#${_animation.value.value.toRadixString(16)}";
        } else {
          widget.model.value = _animation.value.toString();
        }
      });
    });
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TweenView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // re-register model listeners
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    // remove model listener
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback to fire the [_AnimationViewState.build] when the [AnimationModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // Tween

    double _begin = widget.model.begin;
    double _end = widget.model.end;
    Curve _curve = AnimationHelper.getCurve(widget.model.curve);
    dynamic _from;
    dynamic _to;
    Tween<dynamic> _newTween;
    // we must check from != to and begin !< end

    if (widget.model.type == "color") {
      _from = S.toColor(widget.model.from) ?? Colors.white;
      _to = S.toColor(widget.model.to) ?? Colors.black;
      _newTween = ColorTween(
        begin: _from,
        end: _to,
      );
    } else {
      _from = S.toDouble(widget.model.from) ?? 0;
      _to = S.toDouble(widget.model.to) ?? 1;
      _newTween = Tween<double>(
        begin: _from,
        end: _to,
      );
    }

    if (_begin != 0.0 || _end != 1.0) {
      _curve = Interval(
        _begin,
        _end,
        // the style curve to pass.
        curve: _curve,
      );
    }

    _animation = _newTween.animate(CurvedAnimation(
      curve: _curve,
      parent: _controller,
    ));

    // Return View
    return Container(child: widget.child);
  }
}

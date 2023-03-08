// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/slide/slide_transition_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class SlideTransitionView extends StatefulWidget {
  final SlideTransitionModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController? controller;

  SlideTransitionView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  SlideTransitionViewState createState() => SlideTransitionViewState();
}

class SlideTransitionViewState extends State<SlideTransitionView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  List<double> _defaultFrom = [-1, 0];
  late Animation<Offset> _animation;
  bool soloRequestBuild = false;
  String? _direction;
  TextDirection? _align;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.model.duration), reverseDuration: Duration(milliseconds: widget.model.reverseduration ?? widget.model.duration,))
    ..addStatusListener((status) {
    _animationListener(status);
    });
      widget.model.controller = _controller;
      soloRequestBuild = true;
    } else {
      _controller = widget.controller!;
      widget.model.controller = _controller;
    }
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);

    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.animate, onAnimate);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.reset, onReset);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SlideTransitionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // re-register model listeners
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);

      if(soloRequestBuild) {
        // de-register event listeners
        EventManager.of(oldWidget.model)?.removeEventListener(
            EventTypes.animate, onAnimate);
        EventManager.of(widget.model)?.removeEventListener(
            EventTypes.reset, onReset);

        // register event listeners
        EventManager.of(widget.model)?.registerEventListener(
            EventTypes.animate, onAnimate);
        EventManager.of(widget.model)?.registerEventListener(
            EventTypes.reset, onReset);

        _controller.duration = Duration(milliseconds: widget.model.duration);
        _controller.reverseDuration = Duration(
            milliseconds: widget.model.reverseduration ??
                widget.model.duration);
      }
      }
  }

  @override
  void dispose() {

    if(soloRequestBuild) {
      stop();
      // remove controller
      _controller.dispose();
      // de-register event listeners
      EventManager.of(widget.model)?.removeEventListener(
          EventTypes.animate, onAnimate);
      EventManager.of(widget.model)?.removeEventListener(
          EventTypes.reset, onReset);
    }

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
    _direction = widget.model.direction?.toLowerCase();

    if (_direction == "right") {
      _align = TextDirection.ltr;
      _defaultFrom = [-1, 0];
    } else if (_direction == "left") {
      _align = TextDirection.rtl;
      _defaultFrom = [-1, 0];
    } else if (_direction == "up") {
      _defaultFrom = [0, 1];
    } else if (_direction == "down") {
      _defaultFrom = [0, -1];
    }

    // Tween
    List<String>? from = widget.model.from?.split(",");
    Offset fromOffset = Offset(
        S.toDouble(from?.elementAt(0)) ?? _defaultFrom[0],
        S.toDouble(from?.elementAt(1)) ?? _defaultFrom[1]);
    List<String>? to = widget.model.to.split(",");
    Offset toOffset = Offset(
        S.toDouble(to.elementAt(0)) ?? 0, S.toDouble(to.elementAt(1)) ?? 0);
    double _begin = widget.model.begin;
    double _end = widget.model.end;
    Curve _curve = AnimationHelper.getCurve(widget.model.curve);
    Tween<Offset> _newTween = Tween<Offset>(
      begin: fromOffset,
      end: toOffset,
    );

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

    // Build View
    Widget? view;

    view = SlideTransition(
      position: _animation,
      textDirection: _align,
      child: widget.child,
    );

    // Return View
    return view;
  }

  void onAnimate(Event event) {
    if (event.parameters == null) return;

    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((S.isNullOrEmpty(id)) || (id == widget.model.id)) {
      bool? enabled = (event.parameters != null)
          ? S.toBool(event.parameters!['enabled'])
          : true;
      if (enabled != false)
        start();
      else
        stop();
      event.handled = true;
    }
  }

  void onReset(Event event) {
    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((S.isNullOrEmpty(id)) || (id == widget.model.id)) {
      reset();
    }
  }

  void reset() {
    try {

      _controller.reset();

    } catch (e) {}
  }

  void start() {
    try {
      if (_controller.isCompleted) {
        _controller.reverse();
        widget.model.onstart;
      } else if (_controller.isDismissed) {
        _controller.forward();
        widget.model.onstart;
      } else {
        _controller.forward();
        widget.model.onstart;
      }

    } catch (e) {}
  }

  void stop() {
    try {
      _controller.reset();
      _controller.stop();
    } catch (e) {}
  }

  void _animationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.model.oncomplete;
    } else if  (status == AnimationStatus.dismissed) {
      widget.model.ondismiss;
    }
  }
}
// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/flip/flip_card_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class FlipCardView extends StatefulWidget {
  final FlipCardModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController? controller;
  FlipCardView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  FlipCardViewState createState() => FlipCardViewState();
}

class FlipCardViewState extends State<FlipCardView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool soloRequestBuild = false;

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

    _controller.addListener(() {setState(() {

    });});
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
  void didUpdateWidget(FlipCardView oldWidget) {
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
    double _begin = widget.model.begin;
    double _end = widget.model.end;
    Curve _curve = AnimationHelper.getCurve(widget.model.curve);

    // Build View
    Widget? view;
    dynamic frontWidget;
    double _from;
    double _to;
    Tween<double> _newTween;

    if (_begin != 0.0 || _end != 1.0) {
      _curve = Interval(
        _begin,
        _end,
        // the style curve to pass.
        curve: _curve,
      );
    }

    _from = widget.model.from;
    _to = widget.model.to;
    _newTween = Tween<double>(
      begin: _from,
      end: _to,
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

    //get front and back widgets.

    //this is done likely wrong. We need to find each element of type, not sure if getting the view here is any good

     frontWidget = widget.child;
    if(_animation.value <= 0.5) {
      frontWidget.model.children
          .elementAt(0)
          .visible = false;
      frontWidget.model.children
          .elementAt(1)
          .visible = true;
      widget.model.side = "front";
    } else {
    frontWidget.model.children
        .elementAt(0)
        .visible = true;
    frontWidget.model.children
        .elementAt(1)
        .visible = false;
    widget.model.side = "back";
    }


    view = Stack(
      fit: StackFit.passthrough,
      children:[
        _buildContent(
          frontWidget: frontWidget ?? Container(),
      )]);

    return view;
  }

  Widget _buildContent({required dynamic frontWidget}) {
    /// pointer events that would reach the backside of the card should be


      if (widget.model.direction?.toLowerCase() == "vertical") {
        return Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(pi * _animation.value),
            child: Container(
              child:  Transform(
                alignment: FractionalOffset.center,
                transform:  Matrix4.identity()
                  ..rotateX(_animation.value <= 0.5 ? 0: pi), child: frontWidget,),
            ));

      }
        return Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(pi * _animation.value),
          child: Container(
          child:  Transform(
          alignment: FractionalOffset.center,
    transform:  Matrix4.identity()
    ..rotateY(_animation.value <= 0.5 ? 0: pi), child: frontWidget,),
        ));
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
      if(widget.model.hasrun) return;
      if (_controller.isCompleted) {
        if(widget.model.runonce) widget.model.hasrun = true;
        _controller.reverse();
        widget.model.onStart(context);
      } else if (_controller.isDismissed) {
        _controller.forward();
        if(widget.model.runonce) widget.model.hasrun = true;
        widget.model.onStart(context);
      } else {
        _controller.forward();
        if(widget.model.runonce) widget.model.hasrun = true;
        widget.model.onStart(context);
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
      widget.model.onComplete(context);
    } else if  (status == AnimationStatus.dismissed) {
      widget.model.onDismiss(context);
    }
  }
}

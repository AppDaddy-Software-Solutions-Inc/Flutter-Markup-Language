// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'gesture_model.dart';

class GestureView extends StatefulWidget implements ViewableWidgetView {
  @override
  final GestureModel model;
  GestureView(this.model) : super(key: ObjectKey(model));

  @override
  State<GestureView> createState() => _GestureViewState();
}

class _GestureViewState extends ViewableWidgetState<GestureView> {
  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build child views
    List<Widget> children = widget.model.inflate();
    Widget child = children.length == 1
        ? children[0]
        : Column(mainAxisSize: MainAxisSize.min, children: children);

    Offset? dragStart;
    Offset? dragEnd;

    if (!widget.model.enabled) return child;

    return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        onHorizontalDragStart: (DragStartDetails d) =>
            dragStart = d.globalPosition,
        onHorizontalDragUpdate: (DragUpdateDetails d) =>
            dragEnd = d.globalPosition,
        onHorizontalDragEnd: (DragEndDetails d) =>
            (dragStart?.dx ?? 0) - (dragEnd?.dx ?? 0) > 0
                ? onSwipeLeft()
                : onSwipeRight(),
        onVerticalDragStart: (DragStartDetails d) =>
            dragStart = d.globalPosition,
        onVerticalDragUpdate: (DragUpdateDetails d) =>
            dragEnd = d.globalPosition,
        onVerticalDragEnd: (DragEndDetails d) =>
            (dragStart?.dy ?? 0) - (dragEnd?.dy ?? 0) > 0
                ? onSwipeUp()
                : onSwipeDown(),
        onSecondaryTap: onRightClick,
        child: MouseRegion(cursor: SystemMouseCursors.click, child: child));
  }

  onTap() async {
    Model.unfocus();
    await widget.model.onClick(context);
  }

  onDoubleTap() async {
    Model.unfocus();
    await widget.model.onDoubleTap(context);
  }

  onLongPress() async {
    Model.unfocus();
    await widget.model.onLongPress(context);
  }

  onSwipeLeft() async {
    Model.unfocus();
    await widget.model.onSwipeLeft(context);
  }

  onSwipeRight() async {
    Model.unfocus();
    await widget.model.onSwipeRight(context);
  }

  onSwipeUp() async {
    Model.unfocus();
    await widget.model.onSwipeUp(context);
  }

  onSwipeDown() async {
    Model.unfocus();
    await widget.model.onSwipeDown(context);
  }

  onRightClick() async {
    Model.unfocus();
    await widget.model.onRightClick(context);
  }
}

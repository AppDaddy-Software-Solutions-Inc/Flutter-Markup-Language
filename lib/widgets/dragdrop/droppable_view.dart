// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class DroppableView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ViewableMixin model;
  final Widget view;

  DroppableView(this.model, this.view) : super(key: ObjectKey(model));

  @override
  State<DroppableView> createState() => _DroppableViewState();
}

class _DroppableViewState extends ViewableWidgetState<DroppableView> {
  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    return DragTarget(
        onWillAcceptWithDetails: onWillAccept,
        onAcceptWithDetails: onAccept,
        builder: onBuild);
  }

  bool onWillAccept(DragTargetDetails<IDragDrop> details) =>
      widget.model.willAccept(details.data);

  void onAccept(DragTargetDetails<IDragDrop> details) =>
      widget.model.onDrop(details.data, dropSpot: details.offset);

  Widget onBuild(context, List<dynamic> cd, List<dynamic> rd) => widget.view;
}

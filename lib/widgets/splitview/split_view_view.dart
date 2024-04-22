// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/splitview/split_view_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model.dart';

class SplitViewView extends StatefulWidget implements ViewableWidgetView {

  @override
  final SplitViewModel model;

  SplitViewView(this.model) : super(key: ObjectKey(model));

  @override
  State<SplitViewView> createState() => SplitViewViewState();
}

class SplitViewViewState extends ViewableWidgetState<SplitViewView> {

  BoxConstraints constraints = const BoxConstraints();

  BoxView? view1;
  BoxView? view2;

  void onBack(Event event) {
    event.handled = true;
    String? pages = fromMap(event.parameters, 'until');
    if (!isNullOrEmpty(pages)) NavigationManager().back(pages);
  }

  void onClose(Event event) {
    event.handled = true;
    NavigationManager().back(-1);
  }

  void _onDrag(DragUpdateDetails details, BoxConstraints constraints) {

    var ratio = widget.model.ratio;

    var maxHeight = constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
    var maxWidth = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
    if (widget.model.vertical) {
      if (maxHeight > 0) {
        var height = (ratio * maxHeight) + details.delta.dy;
        ratio = height / maxHeight;
      }
    } else {
      if (maxWidth > 0) {
        var width = (ratio * maxWidth) + details.delta.dx;
        ratio = width / maxWidth;
      }
    }

    // reset the ratio
    if (ratio < 0) ratio = 0;
    if (ratio > 1) ratio = 1;
    widget.model.ratio = ratio;
  }

  Widget _buildHandle(BoxConstraints constraints) {
    var myDividerColor =
        widget.model.dividerColor ?? Theme.of(context).colorScheme.onInverseSurface;
    var myDividerWidth = widget.model.dividerWidth;

    Widget view = widget.model.vertical
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (DragUpdateDetails details) =>
                _onDrag(details, constraints),
            onTap: () => widget.model.ratio = 0,
            child: Container(
                color: myDividerColor,
                child: SizedBox(
                    width: constraints.maxWidth,
                    height: myDividerWidth,
                    child: MouseRegion(
                        cursor: SystemMouseCursors.resizeUpDown,
                        child: Stack(children: [
                          Positioned(
                              top: -10,
                              child: Icon(Icons.drag_handle,
                                  color: widget.model.dividerHandleColor))
                        ])))))
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (DragUpdateDetails details) =>
                _onDrag(details, constraints),
            child: Container(
                color: myDividerColor,
                child: SizedBox(
                    width: myDividerWidth,
                    height: constraints.maxHeight,
                    child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: RotationTransition(
                            turns: const AlwaysStoppedAnimation(.25),
                            child: Icon(Icons.drag_handle,
                                color: widget.model.dividerHandleColor))))));

    return view;
  }

  BoxView get _missingView => BoxView(BoxModel(widget.model, null), (_,__) => const []);

  @override
  Widget build(BuildContext context) => BoxView(widget.model, builder);

  List<Widget> builder(BuildContext context, BoxConstraints constraints) {

    // left pane
    if (view1 == null) {
      var children = widget.model.viewableChildren;

      Widget? view;
      if (children.isNotEmpty) view = children.elementAt(0).getView();
      if (view is! BoxView) view = _missingView;
      view1 = view;

      // right pane
      view = null;
      if (children.length > 1) view = children.elementAt(1).getView();
      if (view is! BoxView) view = _missingView;
      view2 = view;
    }


    // ratio box1:box2. if 1, box 1 is 100% size
    var ratio = widget.model.ratio;
    if (ratio < 0) ratio = 0;
    if (ratio > 1) ratio = 1;
    var flex = (ratio * 1000).ceil();

    var leftPane  = view1!;
    var rightPane = view2!;

    List<Widget> children = [];

    // left/top pane
    leftPane.model.setFlex(flex);
    leftPane.model.needsLayout = true;
    children.add(leftPane);

    // handle
    Widget handle = _buildHandle(constraints);
    children.add(handle);

    // right/bottom pane
    rightPane.model.setFlex(1000 - flex);
    rightPane.model.needsLayout = true;
    children.add(rightPane);

    return children;
  }
}

// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/widgets/scroller/iscrollable.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:flutter/services.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class DraggableView extends StatefulWidget implements IWidgetView
{
  @override
  final ViewableWidgetModel model;
  final Widget view;

  DraggableView(this.model, this.view) : super(key: ObjectKey(model));

  @override
  State<DraggableView> createState() => _DraggableViewState();
}

class _DraggableViewState extends WidgetState<DraggableView>
{
  Timer? autoscroll;

  bool dragging = false;
  SystemMouseCursor cursor = SystemMouseCursors.grab;

  @override
  void initState()
  {
    super.initState();
    dragging = false;
  }

  @override
  didChangeDependencies()
  {
    dragging = false;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(DraggableView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    dragging = false;
  }
  
  @override
  Widget build(BuildContext context)
  {
    var draggable = Draggable(
        child: widget.view,
        feedback: widget.view,
        data: widget.model,
        onDragCompleted: onDragCompleted,
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd);

    var view = MouseRegion(cursor: cursor, child: draggable);

    // is wrapped inside a IScrollable?
    var scroller = widget.model.firstAncestorWhere((element) => element is IScrollable);

    // wrap in listener if in IScrollable
    return scroller == null ? view : Listener(child: view, onPointerMove: (event) => onPointerMove(event, scroller));
  }

  void onDragCompleted()
  {
    setState(()
    {
      dragging = false;
    });
  }

  void onDragStarted()
  {
    setState(()
    {
      dragging = true;
      cursor = SystemMouseCursors.grabbing;
    });
    ViewableWidgetModel.onDrag(context, widget.model);
  }

  void onDragEnd(DraggableDetails details)
  {
    setState(()
    {
      autoscroll?.cancel();
      dragging = false;
      cursor = SystemMouseCursors.grab;
    });
  }

  void onPointerMove(PointerMoveEvent event, IScrollable scroller)
  {
    autoscroll?.cancel();

    if (!dragging)
    {
      return;
    }

    var position = scroller.positionOf();
    var size = scroller.sizeOf();
    if (size != null && position != null)
    {
      double topY = position.dy;
      double bottomY = topY + size.height;

      const detectedRange = 100;
      const pixels = 3;
      if (event.position.dy < topY + detectedRange)
      {
        scroller.scrollUp(pixels);
        autoscroll = Timer.periodic(Duration(milliseconds: 100), (_) => scroller.scrollUp(detectedRange));
      }

      if (event.position.dy > bottomY - detectedRange)
      {
        scroller.scrollDown(pixels);
        autoscroll = Timer.periodic(Duration(milliseconds: 100), (_) => scroller.scrollDown(detectedRange));
      }
    }
  }
}

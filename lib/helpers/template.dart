// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/beacon/beacon_model.dart';
import 'package:fml/datasources/detectors/biometrics/biometrics_detector_model.dart';
import 'package:fml/datasources/sse/model.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/datasources/stash/stash_model.dart';
import 'package:fml/datasources/log/log_model.dart';
import 'package:fml/datasources/test/test_data_model.dart';
import 'package:fml/datasources/transforms/subquery.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector_model.dart';
import 'package:fml/datasources/detectors/text/text_detector_model.dart';
import 'package:fml/datasources/data/model.dart';
import 'package:fml/datasources/gps/model.dart';
import 'package:fml/datasources/http/model.dart';
import 'package:fml/datasources/mqtt/mqtt_model.dart';
import 'package:fml/datasources/nfc/nfc_model.dart';
import 'package:fml/datasources/socket/socket_model.dart';
import 'package:fml/datasources/zebra/model.dart';
import 'package:fml/widgets/alarm/alarm_model.dart';
import 'package:fml/widgets/animation/animation_child/flip/flip_card_model.dart';
import 'package:fml/widgets/animation/animation_child/transform/transform_model.dart';
import 'package:fml/widgets/animation/animation_child/tween/tween_model.dart';
import 'package:fml/widgets/animation/animation_model.dart';
import 'package:fml/widgets/animation/animation_child/fade/fade_transition_model.dart';
import 'package:fml/widgets/animation/animation_child/rotate/rotate_transition_model.dart';
import 'package:fml/widgets/animation/animation_child/scale/scale_transition_model.dart';
import 'package:fml/widgets/animation/animation_child/size/size_transition_model.dart';
import 'package:fml/widgets/animation/animation_child/slide/slide_transition_model.dart';
import 'package:fml/widgets/breadcrumb/breadcrumb_model.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/button/button_model.dart';
import 'package:fml/widgets/camera/camera_model.dart';
import 'package:fml/widgets/card/card_model.dart';
import 'package:fml/widgets/center/center_model.dart';
import 'package:fml/widgets/chart/chart_model.dart';
import 'package:fml/widgets/chart_painter/axis/chart_axis_model.dart';
import 'package:fml/widgets/chart/label/chart_label_model.dart';
import 'package:fml/widgets/chart/series/chart_series_model.dart';
import 'package:fml/widgets/chart_painter/bar/bar_chart_model.dart';
import 'package:fml/widgets/chart_painter/bar/bar_series.dart';
import 'package:fml/widgets/chart_painter/chart_model.dart';
import 'package:fml/widgets/chart_painter/line/line_chart_model.dart';
import 'package:fml/widgets/chart_painter/line/line_series.dart';
import 'package:fml/widgets/chart_painter/pie/pie_chart_model.dart';
import 'package:fml/widgets/chart_painter/pie/pie_series.dart';
import 'package:fml/widgets/checkbox/checkbox_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/datepicker/datepicker_model.dart';
import 'package:fml/datasources/http/delete/model.dart';
import 'package:fml/widgets/editor/editor_model.dart';
import 'package:fml/widgets/field/field_model.dart';
import 'package:fml/widgets/filepicker/filepicker_model.dart';
import 'package:fml/widgets/footer/footer_model.dart';
import 'package:fml/widgets/form/form_model.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/gesture/gesture_model.dart';
import 'package:fml/datasources/http/get/model.dart';
import 'package:fml/widgets/grid/item/grid_item_model.dart';
import 'package:fml/widgets/grid/grid_model.dart';
import 'package:fml/widgets/header/header_model.dart';
import 'package:fml/widgets/icon/icon_model.dart';
import 'package:fml/widgets/iframe/inline_frame_model.dart';
import 'package:fml/widgets/image/image_model.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/widgets/link/link_model.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/list/list_model.dart';
import 'package:fml/widgets/map/marker/map_marker_model.dart';
import 'package:fml/widgets/map/map_model.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:fml/widgets/menu/menu_model.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/padding/padding_model.dart';
import 'package:fml/widgets/pager/page/page_model.dart';
import 'package:fml/widgets/pager/pager_model.dart';
import 'package:fml/widgets/popover/item/popover_item_model.dart';
import 'package:fml/widgets/popover/popover_model.dart';
import 'package:fml/widgets/positioned/positioned_model.dart';
import 'package:fml/datasources/http/put/model.dart';
import 'package:fml/datasources/http/post/model.dart';
import 'package:fml/widgets/prototype/prototype_model.dart';
import 'package:fml/widgets/radio/radio_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/scribble/scribble_model.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/select/select_model.dart';
import 'package:fml/widgets/slider/slider_model.dart';
import 'package:fml/widgets/splitview/split_model.dart';
import 'package:fml/widgets/stack/stack_model.dart';
import 'package:fml/widgets/switch/switch_model.dart';
import 'package:fml/widgets/table/table_footer_cell_model.dart';
import 'package:fml/widgets/table/table_footer_model.dart';
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:fml/widgets/table/table_header_group_model.dart';
import 'package:fml/widgets/table/table_header_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/table_norows_model.dart';
import 'package:fml/widgets/table/table_row_cell_model.dart';
import 'package:fml/widgets/table/table_row_model.dart';
import 'package:fml/widgets/tabview/tab_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/timer/timer_model.dart';
import 'package:fml/widgets/tooltip/v1/tooltip_model.dart' as v1;
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart' as v2;
import 'package:fml/datasources/transforms/calc.dart';
import 'package:fml/datasources/transforms/distinct.dart';
import 'package:fml/datasources/transforms/sort.dart';
import 'package:fml/datasources/transforms/eval.dart';
import 'package:fml/datasources/transforms/filter.dart';
import 'package:fml/datasources/transforms/pivot.dart';
import 'package:fml/datasources/transforms/format.dart';
import 'package:fml/datasources/transforms/flip.dart';
import 'package:fml/datasources/transforms/resize.dart';
import 'package:fml/datasources/transforms/crop.dart';
import 'package:fml/datasources/transforms/grayscale.dart';
import 'package:fml/widgets/treeview/tree_model.dart';
import 'package:fml/widgets/treeview/node/tree_node_model.dart';
import 'package:fml/widgets/trigger/condition/trigger_condition_model.dart';
import 'package:fml/widgets/trigger/trigger_model.dart';
import 'package:fml/widgets/typeahead/typeahead_model.dart';
import 'package:fml/widgets/variable/variable_model.dart';
import 'package:fml/widgets/video/video_model.dart';
import 'package:fml/widgets/html/html_model.dart';
import 'package:fml/widgets/span/span_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

Future<void> addChild(WidgetModel model, List<dynamic> arguments) async
{
  // fml
  var xml = elementAt(arguments, 0);

  // if index is null, add to end of list.
  int? index = toInt(elementAt(arguments, 1));

  // silent
  bool silent = toBool(elementAt(arguments, 2)) ?? true;

  if (xml == null || xml is! String) return;

  // append
  await _appendXml(model, xml, index, silent);
}

Future<void> removeChild(WidgetModel model, List<dynamic> arguments) async
{
  // if index is null, remove all children before replacement.
  int? index = toInt(elementAt(arguments, 0));

  // check for children then remove them
  if (model.children != null && index == null) {
    // dispose of the last item
    model.children!.last.dispose();

    // check if the list is greater than 0, remove at the final index.
    if (model.children!.isNotEmpty) model.children!.removeLast();
  }
  else if (model.children != null && index != null) {

    // check if index is in range, then dispose of the child at that index.
    if (index >= 0 && model.children!.length > index) {
      model.children![index].dispose();
      model.children!.removeAt(index);
    }
    // Could add handling for negative index removing from the end?
  }
}

Future<void> removeChildren(WidgetModel model, List<dynamic> arguments) async
{
  // dispose of all children
  model.children?.forEach((child) => child.dispose());
  model.children?.clear();
}

Future<void> replaceChild(WidgetModel model, List<dynamic> arguments) async
{
  // fml
  var xml = elementAt(arguments, 0);

  // if index is null, remove last child before replacement.
  int? index = toInt(elementAt(arguments, 1));

  // silent
  bool silent = toBool(elementAt(arguments, 2)) ?? true;

  if (xml == null || xml is! String) return;

  // check for children then remove them
  if (model.children != null && index == null) {
    // dispose of the last item
    model.children!.last.dispose();

    // check if the list is greater than 0, remove at the final index.
    if (model.children!.isNotEmpty) model.children!.removeAt(model.children!.length - 1);
    print(index.toString());
  } else if (model.children != null && index != null) {
    // check if index is in range, then dispose of the child at that index.
    if (index >= 0 && model.children!.length > index) {
      model.children![index].dispose();
      model.children!.removeAt(index);
    }
    // Could add handling for negative index removing from the end?
  }

  // add elements
  await _appendXml(model,xml, index, silent);
}

Future<void> replaceChildren(WidgetModel model, List<dynamic> arguments) async
{
  // fml
  var xml = elementAt(arguments, 0);

  // silent
  bool silent = toBool(elementAt(arguments, 1)) ?? true;

  if (xml == null || xml is! String) return;

  // dispose of all children
  model.children?.forEach((child) => child.dispose());
  model.children?.clear();

  // add elements
  await _appendXml(model, xml, null, silent);
}

Future<void> removeWidget(WidgetModel model, List<dynamic> arguments) async
{
  // index
  int? index = (model.parent?.children?.contains(model) ?? false)
      ? model.parent?.children?.indexOf(model)
      : null;

  // index should never be null
  if (index != null) {
    // dispose of this model
    model.dispose();
    model.parent?.children?.removeAt(index);
  }
}

Future<void> replaceWidget(WidgetModel model, List<dynamic> arguments) async
{
  // fml
  var xml = elementAt(arguments, 0);

  // get my position in my parents child list
  int? index = (model.parent?.children?.contains(model) ?? false)
      ? model.parent?.children?.indexOf(model)
      : null;

  // silent
  bool silent = toBool(elementAt(arguments, 1)) ?? true;

  if (xml == null || xml is! String) return;

  // index should never be null
  if (index != null) {
    // dispose of myself
    model.dispose();

    // remove myself from the list
    model.parent?.children?.removeAt(index);

    // add new fml
    await _appendXml(model, xml, index, silent);
  }
}

Future<bool> _appendXml(WidgetModel model, String xml, int? index, [bool silent = true]) async
{
  List<XmlElement> nodes = [];

  Exception? exception;

  // parse the xml
  var document = Xml.tryParseException(xml);

  // failed parse
  if (document is Exception) {
    exception = document;

    // try parsing xml wrapped in a root tag
    // this allows the user to send a list of elements
    // and not have top wrap in a root tag
    document = Xml.tryParseException("<ROOT>$xml</ROOT>");
    if (document is XmlDocument) {
      nodes = document.rootElement.childElements.toList();
      exception = null;
    }
  }

  // successfully parsed the xml
  else if (document is XmlDocument) {
    nodes = document.childElements.toList();
  }

  // build error node
  if (exception != null && !silent) {
    var text = XmlElement(XmlName("TEXT"), [
      XmlAttribute(XmlName("size"), '18'),
      XmlAttribute(XmlName("color"), '#EF5858'),
      XmlAttribute(XmlName("value"), exception.toString())
    ]);
    var center = XmlElement(XmlName("CENTER"));
    center.children.add(text);
    nodes.add(center);
  }

  // valid fml?
  for (var element in nodes) {
    _appendChild(model, element, index);
  }

  return exception != null && nodes.isNotEmpty;
}

/// This will be overridden for more complex widgets such as TABLE
/// where children may actually be header or footer declarations that require
/// a complete restructuring/rebuild of the parent
Future<bool> _appendChild(WidgetModel parent, XmlElement element, int? index) async
{
  WidgetModel? model = WidgetModel.fromXml(parent, element);
  if (model != null)
  {
    // model is a datasource
    if (model is IDataSource)
    {
      // add it to the datasource list
      parent.datasources ??= [];
      parent.datasources!.add(model as IDataSource);

      // start brokers
      parent.initialize();
    }

    // model is widget
    else
    {
      // add it to the child list
      parent.children ??= [];

      // position specified?
      if (index != null && index < parent.children!.length) {
        parent.children!.insert(index, model);
      } else {
        parent.children!.add(model);
      }
    }
  }
  return (model != null);
}

XmlElement cloneNode(XmlElement node, Scope? scope) {
  if (Xml.hasAttribute(node: node, tag: "clone")) {
    var id = Xml.attribute(node: node, tag: "clone");
    var model = Scope.findWidgetModel(id, scope);
    if (model != null) {
      if (model.element != null) {
        var n1 = model.element!.localName.trim();
        var n2 = node.localName.trim();

        if (n1.toLowerCase() == n2.toLowerCase()) {
          // copy element
          var element = model.element!.copy();
          for (var attribute in node.attributes) {
            Xml.setAttribute(element, attribute.localName, attribute.value);
          }
          node.replace(element);
          node = element;
        } else {
          Log().exception(
              "A model of type <$n2/> cannot be cloned from a model of type <$n1/>");
        }
      } else {
        Log().exception("Model $id has no element to copy from");
      }
    } else {
      Log()
          .exception("Error attempting to clone model $id. Model not found.");
    }
  }
  return node;
}

bool excludeFromTemplate(XmlElement node, Scope? scope) {
  bool exclude = false;

  // exclude node from template?
  var value = node.getAttribute('exclude');
  if (value != null) {
    var bindable = BooleanObservable(null, value, scope: scope);
    exclude = bindable.get() ?? false;
    bindable.dispose();
  }
  return exclude;
}

XmlElement? prototypeOf(XmlElement? node)
{
  if (node == null) return null;

  // get the id
  var id = Xml.attribute(node: node, tag: "id");

  // if missing, assign it a unique key
  if (id == null)
  {
    id = newId();
    Xml.setAttribute(node, "id", id);
  }

  // process data bindings
  var xml = node.toString();
  var bindings = Binding.getBindings(xml);
  List<String?> processed = [];

  if (bindings != null)
  {
    bool doReplace = false;

    // process each binding
    for (var binding in bindings)
    {
      // special case
      if ((binding.source == 'data') && !processed.contains(binding.signature))
      {
        doReplace = true;

        processed.add(binding.signature);

        // set the signature
        var signature = "{$id.${binding.source}.${binding.property}${(binding.dotnotation?.signature != null ? ".${binding.dotnotation!.signature}" : "")}}";
        xml = xml.replaceAll(binding.signature, signature);
      }
    }

    // parse the new xml
    var newNode = Xml.tryParse(xml)?.rootElement;

    // if valid node, we need to replace this node in the tree so
    // ancestor prototypes don't translate data incorrectly
    if (newNode != null)
    {
      if (doReplace)
      {
        var parent = node.parent;
        var index  = node.parent?.children.indexOf(node) ?? -1;
        newNode = newNode.copy();
        if (index >= 0 && parent != null)
        {
          parent.children.removeAt(index);
          parent.children.insert(index, newNode);
        }
      }
      node = newNode;
    }
  }

  return node;
}

bool isDataSource(String element) {
  switch (element.toLowerCase()) {
    case "barcode":
      return true;
    case "beacon":
      return true;
    case "biometric":
      return true;
    case "data":
      return true;
    case "delete":
      return true;
    case "detector":
      return true;
    case "filepicker":
      return true;
    case "get":
      return true;
    case "gps":
      return true;
    case "http":
      return true;
    case 'log':
      return true;
    case "mqtt":
      return true;
    case "nfc":
      return true;
    case "ocr":
      return true;
    case "post":
      return true;
    case "put":
      return true;
    case "socket":
      return true;
    case "sse":
      return true;
    case 'stash':
      return true;
    case "testdata":
      return true;
    case "zebra":
      return true;
    default:
      return false;
  }
}

WidgetModel? fromXmlNode(WidgetModel parent, XmlElement node, Scope? scope, dynamic data)
{
  WidgetModel? model;

  switch (node.localName.toLowerCase()) {

    case "alarm":
      model = AlarmModel.fromXml(parent, node);
      break;

    case "animate": // Preferred Case
    case "animation": // Animation may be deprecated
      model = AnimationModel.fromXml(parent, node);
      break;

    case "autocomplete":
      model = InputModel.fromXml(parent, node, type: "autocomplete");
      break;

    case "barcode":
      model = BarcodeDetectorModel.fromXml(parent, node);
      break;

    case "beacon":
      model = BeaconModel.fromXml(parent, node);
      break;

    case "biometic":
      model = BiometricsDetectorModel.fromXml(parent, node);
      break;

    case "box": // Preferred Case
    case "container": // Container may be deprecated
      bool isPrototype = Xml.hasAttribute(node: node, tag: "data") || Xml.hasAttribute(node: node, tag: "datasource");
      model = isPrototype ? PrototypeModel.fromXml(parent, node) : BoxModel.fromXml(parent, node, scope: scope, data: data);
      break;

    case "breadcrumb":
      model = BreadcrumbModel.fromXml(parent, node);
      break;

    case "busy":
      model = BusyModel.fromXml(parent, node);
      break;

    case "button":
    case "btn":
      model = ButtonModel.fromXml(parent, node);
      break;

    case "buttonstate":
      model = ButtonModel.fromXml(parent, node);
      break;

    case "calc":
      if (parent is IDataSource) model = Calc.fromXml(parent, node);
      break;

    case "camera":
      model = CameraModel.fromXml(parent, node);
      break;

    case "card":
      model = CardModel.fromXml(parent, node);
      break;

    case "center":
      model = CenterModel.fromXml(parent, node);
      break;

    case "chart":
      model = ChartModel.fromXml(parent, node);
      break;

    case "linechart":
      model = LineChartModel.fromXml(parent, node);
      break;

    case "piechart":
      model = PieChartModel.fromXml(parent, node);
      break;

    case "barchart":
      model = BarChartModel.fromXml(parent, node);
      break;

    case "body":
    // we dont want to deserialize datasorce body models
    // in the future we may wish to have a BODY element
    // for now just return null
      if (parent is! IDataSource) model = null;
      model = null;
      break;

  // case "sfchart":
  //   model = SFCHART.ChartModel.fromXml(parent, node);
  //   break;

    case "html":
      model = HtmlModel.fromXml(parent, node);
      break;

    case "checkbox":
    case "check":
      model = CheckboxModel.fromXml(parent, node);
      break;

    case "const":
    case "constant":
      model = VariableModel.fromXml(parent, node, constant: true);
      break;

    case "crop":
      if (parent is IDataSource) model = Crop.fromXml(parent, node);
      break;

    case "column":
    case "col": //shorthand case
      bool isPrototype = Xml.hasAttribute(node: node, tag: "data") || Xml.hasAttribute(node: node, tag: "datasource");
      model = isPrototype ? PrototypeModel.fromXml(parent, node) : ColumnModel.fromXml(parent, node, scope: scope, data: data);
      break;

    case "condition":
    case "case":
      if (parent is TriggerModel) {
        model = TriggerConditionModel.fromXml(parent, node);
      }
      break;

    case "data":
      model = DataModel.fromXml(parent, node);
      break;

    case "datepicker":
      model = DatepickerModel.fromXml(parent, node);
      break;

    case "delete":
      model = HttpDeleteModel.fromXml(parent, node);
      break;

    case "distinct":
      if (parent is IDataSource) model = Distinct.fromXml(parent, node);
      break;

    case "editor":
      model = EditorModel.fromXml(parent, node);
      break;

  // deprecated. use row/column/box with %sizing or flex
    case "expand":
    case "expanded":
      model = ColumnModel.fromXml(parent, node);
      if (model is ColumnModel && model.flex == null) model.flex = "1";
      break;

    case "eval":
      if (parent is IDataSource) model = Eval.fromXml(parent, node);
      break;

    case "field":
      model = FieldModel.fromXml(parent, node);
      break;

    case "filepicker":
      model = FilepickerModel.fromXml(parent, node);
      break;

    case "filter":
      if (parent is IDataSource) {
        model = Filter.fromXml(parent, node);
      }
      break;

    case "flip":
      if (parent is IDataSource) {
        model = Flip.fromXml(parent, node);
      } else if (parent is AnimationModel) {
        model = FlipCardModel.fromXml(parent, node);
      } else {
        model = FlipCardModel.fromXml(parent, node);
      }
      break;

    case "fml":
    // <FML> root models are never a child element
    // of another parent element, rather they get created from the FrameworkModel.fromXml() routine.
    // If there is a future reason to do that, this item will need to be revisited. In the meantime,
    // an <FML> tag encountered in the element xml stream is treated as a <BOX>, not as a new outer framework.
      model = BoxModel.fromXml(parent, node);
      break;

    case "footer":
      if (parent is FrameworkModel) {
        model = FooterModel.fromXml(parent, node);
      }
      break;

    case "form":
      model = FormModel.fromXml(parent, node);
      break;

    case "format":
      if (parent is IDataSource) {
        model = Format.fromXml(parent, node);
      }
      break;

    case "gesture":
      model = GestureModel.fromXml(parent, node);
      break;

    case "get":
      model = HttpGetModel.fromXml(parent, node);
      break;

    case "greyscale":
    case "grayscale":
      if (parent is IDataSource) {
        model = Grayscale.fromXml(parent, node);
      }
      break;

    case "gps":
      model = GpsModel.fromXml(parent, node);
      break;

    case "grid":
      model = GridModel.fromXml(parent, node);
      break;

    case "header":
      if (parent is FrameworkModel) {
        model = HeaderModel.fromXml(parent, node);
      }
      break;

    case "http":
      model = HttpModel.fromXml(parent, node);
      break;

    case "icon":
      model = IconModel.fromXml(parent, node);
      break;

    case "webview":
    case "iframe":
      model = InlineFrameModel.fromXml(parent, node);
      break;

    case "image":
    case "img":
      model = ImageModel.fromXml(parent, node);
      break;

    case "item":
      if (parent is GridModel) {
        model = GridItemModel.fromXml(parent, node);
      }
      if (parent is ListModel) {
        model = ListItemModel.fromXml(parent, node);
      }
      if (parent is MenuModel) {
        model = MenuItemModel.fromXml(parent, node);
      }
      if (parent is PopoverModel) {
        model = PopoverItemModel.fromXml(parent, node);
      }
      break;

    case "input":
      model = InputModel.fromXml(parent, node);
      break;

    case "layout":
      model = BoxModel.fromXml(parent, node);
      break;

    case "label":
      if (parent is ChartModel) {
        model = ChartLabelModel.fromXml(parent, node);
      }
      break;

    case "link":
      model = LinkModel.fromXml(parent, node);
      break;

    case "list":
      model = ListModel.fromXml(parent, node);
      break;

    case "log":
      model = LogModel.fromXml(parent, node);
      break;

    case "map":
      model = MapModel.fromXml(parent, node);
      break;

    case "menu":
      model = MenuModel.fromXml(parent, node);
      break;

    case "modal":
      model = ModalModel.fromXml(parent, node);
      break;

    case "mqtt":
      model = MqttModel.fromXml(parent, node);
      break;

    case "nfc":
      model = NcfModel.fromXml(parent, node);
      break;

    case "node":
      if (parent is TreeModel || parent is TreeNodeModel)
      {
        model = TreeNodeModel.fromXml(parent, node);
      }
      break;

    case "ocr":
      model = TextDetectorModel.fromXml(parent, node);
      break;

    case "option":
      if (parent is SelectModel ||
          parent is CheckboxModel ||
          parent is RadioModel ||
          parent is TypeaheadModel) model = OptionModel.fromXml(parent, node);
      break;

    case "fade":
      if (parent is AnimationModel) {
        model = FadeTransitionModel.fromXml(parent, node);
      } else {
        model = FadeTransitionModel.fromXml(parent, node);
      }
      break;

    case "rotate":
      if (parent is AnimationModel) {
        model = RotateTransitionModel.fromXml(parent, node);
      } else {
        model = RotateTransitionModel.fromXml(parent, node);
      }
      break;

    case "sbox":
    case "shrinkbox":
      model = BoxModel.fromXml(parent, node, expandDefault: false);
      break;

    case "size":
      if (parent is AnimationModel) {
        model = SizeTransitionModel.fromXml(parent, node);
      } else {
        model = SizeTransitionModel.fromXml(parent, node);
      }
      break;

    case "slide":
      if (parent is AnimationModel) {
        model = SlideTransitionModel.fromXml(
          parent,
          node,
        );
      } else {
        model = SlideTransitionModel.fromXml(parent, node);
      }
      break;

    case "scale":
      if (parent is AnimationModel) {
        model = ScaleTransitionModel.fromXml(parent, node);
      } else {
        model = ScaleTransitionModel.fromXml(parent, node);
      }
      break;

    case "stash":
      model = StashModel.fromXml(parent, node);
      break;

    case "subquery":
      if (parent is HttpGetModel) model = Query.fromXml(parent, node);
      break;

    case "testdata":
      model = TestDataModel.fromXml(parent, node);
      break;

    case "transform":
      if (parent is AnimationModel) {
        model = TransformModel.fromXml(parent, node);
      } else {
        model = TransformModel.fromXml(parent, node);
      }
      break;

    case "tween":
      if (parent is AnimationModel) {
        model = TweenModel.fromXml(parent, node);
      } else {
        model = TweenModel.fromXml(parent, node);
      }
      break;

    case "pad": // Preferred Case.
    case "padding": // Padding could be deprecated.
      model = PaddingModel.fromXml(parent, node);
      break;

    case "page":
      if (parent is PagerModel)
      {
        model = PageModel.fromXml(parent, node);
      }
      break;

    case "pager":
      model = PagerModel.fromXml(parent, node);
      break;

    case "pivot":
      if (parent is IDataSource) model = Pivot.fromXml(parent, node);
      break;

    case "put":
      model = HttpPutModel.fromXml(parent, node);
      break;

    case "popover":
      model = PopoverModel.fromXml(parent, node);
      break;

    case "popoveritem":
      model = PopoverItemModel.fromXml(parent, node);
      break;

    case "position": // Preferred case
    case "pos": // Shorthand case
    case "positioned": // Positioned may be deprecated
      model = PositionedModel.fromXml(parent, node);
      break;

    case "marker":
      if (parent is MapModel) {
        model = MapMarkerModel.fromXml(parent, node);
      }
      break;

    case "post":
      model = HttpPostModel.fromXml(parent, node);
      break;

    case "radio":
      model = RadioModel.fromXml(parent, node);
      break;

    case "resize":
      if (parent is IDataSource) model = Resize.fromXml(parent, node);
      break;

    case "row":
      bool isPrototype = Xml.hasAttribute(node: node, tag: "data") || Xml.hasAttribute(node: node, tag: "datasource");
      model = isPrototype ? PrototypeModel.fromXml(parent, node) : RowModel.fromXml(parent, node, scope: scope, data: data);
      break;

    case "scribble":
      model = ScribbleModel.fromXml(parent, node);
      break;

    case "scroll": // Preferred Case
    case "scroller": // Scroller may be deprecated.
      model = ScrollerModel.fromXml(parent, node);
      break;

    case "select":
      model = SelectModel.fromXml(parent, node);
      break;

    case "series":
      if (parent is ChartModel) {
        model = ChartSeriesModel.fromXml(parent, node);
      }else if (parent is BarChartModel){
        model = BarChartSeriesModel.fromXml(parent, node);
      } else if (parent is LineChartModel){
        model = LineChartSeriesModel.fromXml(parent, node);
      }else if (parent is PieChartModel){
        model = PieChartSeriesModel.fromXml(parent, node);
      }
      // else if (parent is SFCHART.ChartModel) model = SFCHART.ChartSeriesModel.fromXml(parent, node);
      break;

    case "slider":
      model = SliderModel.fromXml(parent, node);
      break;

    case "socket":
      model = SocketModel.fromXml(parent, node);
      break;

    case "sort":
      if (parent is IDataSource) model = Sort.fromXml(parent, node);
      break;

    case "span":
      model = SpanModel.fromXml(parent, node);
      break;

    case "sse":
      model = SseModel.fromXml(parent, node);
      break;

    case "stack":
      model = StackModel.fromXml(parent, node);
      break;

    case "splitview":
      model = SplitModel.fromXml(parent, node);
      break;

    case "table":
      model = TableModel.fromXml(parent, node);
      break;

    case "th":
    case "tableheader":
      if (parent is TableModel) {
        model = TableHeaderModel.fromXml(parent, node);
      }
      break;

    case "tr":
    case "tablerow":
      if (parent is TableModel) {
        model = TableRowModel.fromXml(parent, node);
      }
      break;

    case "tf":
    case "tablefooter":
      if (parent is TableModel) {
        model = TableFooterModel.fromXml(parent, node);
      }
      break;

    case "nodata":
    case "norows":
      if (parent is TableModel) {
        model = TableNoRowsModel.fromXml(parent, node);
      }
      break;

    case "td":
    case "tabledata":
    case "cell":
      if (parent is TableHeaderModel || parent is TableHeaderGroupModel)
      {
        model = TableHeaderCellModel.fromXml(parent, node);
      }
      if (parent is TableRowModel) {
        model = TableRowCellModel.fromXml(parent, node);
      }
      if (parent is TableFooterModel) {
        model = TableFooterCellModel.fromXml(parent, node);
      }
      break;

    case "tg":
    case "group":
      if (parent is TableHeaderModel || parent is TableHeaderGroupModel) {
        model = TableHeaderGroupModel.fromXml(parent, node);
      }
      break;

    case "tabview":
      model = TabModel.fromXml(parent, node);
      break;

    case "text":
    case "txt":
      model = TextModel.fromXml(parent, node);
      break;

    case "theme":
      model = ThemeModel.fromXml(parent, node);
      break;

    case "timer":
      model = TimerModel.fromXml(parent, node);
      break;

    case "toggle":
    case "switch":
      model = SwitchModel.fromXml(parent, node);
      break;

    case "tip":
    case "tooltip":
      if (Xml.attribute(node: node, tag: "label") != null ||
          Xml.attribute(node: node, tag: "text") != null) {
        model = v1.TooltipModel.fromXml(parent, node);
      } else {
        model = v2.TooltipModel.fromXml(parent, node);
      }
      break;

    case "treeview":
      model = TreeModel.fromXml(parent, node);
      break;

    case "trigger":
      model = TriggerModel.fromXml(parent, node);
      break;

    case "typeahead":
      model = TypeaheadModel.fromXml(parent, node);
      break;

    case "variable":
    case "var":
      model = VariableModel.fromXml(parent, node);
      break;

    case "video":
      model = VideoModel.fromXml(parent, node);
      break;

    case "view":
      if (parent is SplitModel) {
        model = BoxModel.fromXml(parent, node);
      }
      break;

    case "window":
      model = FrameworkModel.fromXml(parent, node);
      break;

    case "xaxis":
      if (parent is ChartPainterModel) {
        model = ChartAxisModel.fromXml(parent, node, ChartAxis.X);
      }
      // else if (parent is SFCHART.ChartModel) model = SFCHART.ChartAxisModel.fromXml(parent, node, SFCHART.Axis.X);
      break;

    case "yaxis":
      if (parent is ChartPainterModel) {
        model = ChartAxisModel.fromXml(parent, node, ChartAxis.Y);
      }
      // else if (parent is SFCHART.ChartModel) model = SFCHART.ChartAxisModel.fromXml(parent, node, SFCHART.Axis.Y);
      break;

    case "zebra":
      model = ZebraModel.fromXml(parent, node);
      break;

    default:
      break;
  }

  return model;
}
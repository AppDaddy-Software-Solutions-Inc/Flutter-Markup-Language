// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/datasources/http/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class HttpPatchModel extends HttpModel implements IDataSource
{
  // method
  @override
  String get method => "patch";

  HttpPatchModel(WidgetModel parent, String? id) : super(parent, id);

  static HttpPatchModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    HttpPatchModel? model;
    try
    {
      model = HttpPatchModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'iframe.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {    super.deserialize(xml);
  }
}

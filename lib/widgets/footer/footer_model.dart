// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/widgets/footer/footer_view.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class FooterModel extends DecoratedWidgetModel implements IViewableWidget
{
  // override
  double? get height => super.height ?? 50;

  FooterModel(
    WidgetModel parent,
    String? id,
   {dynamic color,
    dynamic height,
  }) : super(parent, id)
  {
    this.color = color;
    this.height = height;
  }
  
  static FooterModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    FooterModel? model;
    try
    {
      /////////////////
      /* Build Model */
      /////////////////
      model = FooterModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'footer.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize 
    super.deserialize(xml);
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => FooterView(this);
}
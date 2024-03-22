// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/system.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class Template {
  static String errorPageAttribute = "errorpage";

  final String? name;
  final XmlDocument? document;
  bool get isAutoGeneratedErrorPage => document != null
      ? Xml.hasAttribute(node: document!.rootElement, tag: errorPageAttribute)
      : false;

  Template({this.name, this.document});

  factory Template.fromXmlDocument(
      {String? name, XmlDocument? xml, Map<String, String?>? parameters}) {
    Template template = Template(name: name, document: xml);
    template = Template.clone(template: template, parameters: parameters);
    return template;
  }

  factory Template.fromFml(
      {String? name, required String fml, Map<String, String?>? parameters}) {
    var document = Xml.tryParse(fml);
    return Template.fromXmlDocument(
        name: name, xml: document, parameters: parameters);
  }

  factory Template.clone(
      {required Template template, Map<String, String?>? parameters}) {
    try {
      // Convert Xml Document to Xml String
      String? xml = template.document.toString();

      // Replace Bindings in Xml
      if (parameters != null) {
        xml = Binding.applyMap(xml, parameters, caseSensitive: false);
      }

      // Replace query parameters
      xml = Binding.applyMap(xml, System.currentApp?.queryParameters,
          caseSensitive: false);

      // Replace config parameters
      xml = Binding.applyMap(xml, System.currentApp?.configParameters,
          caseSensitive: false);

      // Replace System Uuid
      String s = Binding.toKey(System.myId, 'uuid')!;
      while (xml!.contains(s)) {
        xml = xml.replaceFirst(s, newId());
      }

      // Convert Xml String to Xml Document
      XmlDocument document = XmlDocument.parse(xml);

      // return the new template
      template = Template(name: template.name, document: document);
    } catch (e) {
      Log().debug(e.toString());
    }

    return template;
  }

  factory Template.error(
      {required Template template, Map<String, String?>? parameters}) {
    try {
      // Convert Xml Document to Xml String
      String? xml = template.document.toString();

      // Replace Bindings in Xml
      if (parameters != null) {
        xml = Binding.applyMap(xml, parameters, caseSensitive: false);
      }

      // Replace query parameters
      xml = Binding.applyMap(xml, System.currentApp?.queryParameters,
          caseSensitive: false);

      // Replace config parameters
      xml = Binding.applyMap(xml, System.currentApp?.configParameters,
          caseSensitive: false);

      // Replace System Uuid
      String s = Binding.toKey(System.myId, 'uuid')!;
      while (xml!.contains(s)) {
        xml = xml.replaceFirst(s, newId());
      }

      // Convert Xml String to Xml Document
      XmlDocument document = XmlDocument.parse(xml);

      // return the new template
      template = Template(name: template.name, document: document);
    } catch (e) {
      Log().debug(e.toString());
    }

    return template;
  }
}

// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/data/data.dart';
import 'package:fml/data/dotnotation.dart';
import 'package:fml/datasources/gps/payload.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/phrase.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:validators/validators.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/hive/form.dart' as hive_form;
import 'package:fml/widgets/form/form_view.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

abstract class IForm {
  // Dirty
  bool? get dirty;
  set dirty(bool? b);
  BooleanObservable? get dirtyObservable;

  // Clean
  set clean(bool b);

  // Routines
  Future<bool> save();
  Future<bool> complete();
  Future<bool> onComplete(BuildContext context);
}

enum StatusCodes { incomplete, complete }

class FormModel extends BoxModel
{
  @override
  String get layout => super.layout ?? "column";

  List<IFormField> fields = [];

  List<IForm> forms = [];

  // posting source source
  List<String>? _postbrokers;
  set postbrokers(dynamic v) {
    if (v is String) {
      var values = v.split(",");
      _postbrokers = [];
      for (var e in values) {
        if (!S.isNullOrEmpty(e)) _postbrokers!.add(e.trim());
      }
    }
  }

  List<String>? get postbrokers => _postbrokers;

  // status
  StringObservable? _status;
  set status(dynamic v) {
    StatusCodes? status = S.toEnum(v.toString(), StatusCodes.values);
    status ??= StatusCodes.incomplete;
    v = S.fromEnum(status);
    if (_status != null) {
      _status!.set(v);
    } else if (v != null) {
      _status ??=
          StringObservable(Binding.toKey(id, 'status'), v, scope: scope);
      _completed ??= BooleanObservable(
          Binding.toKey(id, 'complete'), (status == StatusCodes.complete),
          scope: scope);
    }
  }

  String? get status => _status?.get();

  BooleanObservable? _completed;
  bool get completed =>
      (S.toEnum(status, StatusCodes.values) == StatusCodes.complete);

  // editable
  BooleanObservable? _editable;
  set editable(dynamic v) {
    if (_editable != null) {
      _editable!.set(v);
    } else if (v != null) {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get editable => _editable?.get();

  // autosave
  BooleanObservable? _autosave;
  set autosave(dynamic v) {
    if (_autosave != null) {
      _autosave!.set(v);
    } else if (v != null) {
      _autosave =
          BooleanObservable(Binding.toKey(id, 'autosave'), v, scope: scope);
    }
  }

  bool? get autosave {
    if ((isWeb) || (_autosave == null)) return false;
    return _autosave?.get();
  }

  // mandatory
  BooleanObservable? _mandatory;
  set mandatory(dynamic v) {
    if (_mandatory != null) {
      _mandatory!.set(v);
    } else if (v != null) {
      _mandatory =
          BooleanObservable(Binding.toKey(id, 'mandatory'), v, scope: scope);
    }
  }

  bool? get mandatory => _mandatory?.get();

  // dirty
  BooleanObservable? _dirty;
  set dirty(dynamic v) {
    if (_dirty != null) {
      _dirty!.set(v);
    } else if (v != null) {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope);
    }
  }

  bool? get dirty => _dirty?.get();

  void onDirtyListener(Observable property) {
    // set form dirty
    bool isDirty = false;
    for (var field in fields) {
      if (field.dirty == true) isDirty = true;
    }
    dirty = isDirty;

    // auto save?
    if ((isDirty == true) && (autosave == true)) save();
  }

  set clean(bool b) {
    // clean all fields
    for (var field in fields) {
      field.dirty = false;
    }

    // clean all sub-forms
    for (var form in forms) {
      form.clean = false;
    }
  }

  // gps
  BooleanObservable? _geocode;
  set geocode(dynamic v) {
    if (_geocode != null) {
      _geocode!.set(v);
    } else if (v != null) {
      _geocode = BooleanObservable(Binding.toKey(id, 'gps'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get geocode {
    if (_geocode == null) return (isMobile ? true : false);
    return _geocode?.get();
  }

  // on complete event
  StringObservable? _oncomplete;
  set oncomplete(dynamic v) {
    if (_oncomplete != null) {
      _oncomplete!.set(v);
    } else if (v != null) {
      _oncomplete = StringObservable(Binding.toKey(id, 'oncomplete'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get oncomplete => _oncomplete?.get();

  // Show Exception
  BooleanObservable? _showexception;
  set showexception(dynamic v) {
    if (_showexception != null) {
      _showexception!.set(v);
    } else if (v != null) {
      _showexception = BooleanObservable(Binding.toKey(id, 'showexception'), v,
          scope: scope);
    }
  }

  bool get showexception => _showexception?.get() ?? true;

  Map<String, String?> get map {
    Map<String, String?> myMap = <String, String?>{};

    for (var field in fields) {
      if ((field.elementName != "attachment") &&
          (!S.isNullOrEmpty(field.value))) {
        String? value;

        // List of Values

        if (field.value is List) {
          field.value.forEach((v) {
            value = (value == null) ? v.toString() : "${value!},$v";
          });
        } else {
          value = field.value.toString();
        }

        ///
        // Set the Value
        ///
        if (field.id != null) myMap[field.id!] = value;
      }
    }

    return myMap;
  }

  FormModel(
    WidgetModel parent,
    String? id, {
    String? type,
    String? title,
    dynamic status,
    dynamic busy,
    dynamic visible,
    dynamic autosave,
    dynamic mandatory,
    dynamic geocode,
    dynamic oncomplete,
    dynamic showexception,
    dynamic data,
  }) : super(parent, id) {
    // instantiate busy observable
    busy = false;

    this.status = status;
    this.autosave = autosave;
    this.mandatory = mandatory;
    dirty = false;
    this.geocode = geocode;
    this.oncomplete = oncomplete;
    this.showexception = showexception;
    this.data = data;
  }

  static FormModel? fromXml(WidgetModel parent, XmlElement xml) {
    FormModel? model;

    try {
      model = FormModel(parent, Xml.get(node: xml, tag: 'id'),
          showexception: Xml.get(node: xml, tag: 'showexception'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'form.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {
    if (xml == null) return;

    // deserialize
    super.deserialize(xml);

    // properties
    status = Xml.get(node: xml, tag: 'status');
    autosave = Xml.get(node: xml, tag: 'autosave');
    mandatory = Xml.get(node: xml, tag: 'mandatory');
    geocode = Xml.get(node: xml, tag: 'geocode');
    oncomplete = Xml.get(node: xml, tag: 'oncomplete');
    postbrokers = Xml.attribute(node: xml, tag: 'post');
    data = Xml.attribute(node: xml, tag: 'data');

    // get fields
    fields.addAll(getFields(children));

    // fill all empty fields with the datasource if specified
    if (data != null) _fillEmptyFields();

    // get forms
    forms.addAll(getForms(children));

    // get all answers
    var nodes = xml.findElements("ANSWER", namespace: "*");

    // clear answers
    for (XmlElement node in nodes) {
      String? id = Xml.get(node: node, tag: 'id');
      IFormField? field = getField(id);
      if (field != null) {
        dynamic value = field.value;
        if (value is List) {
          field.value.clear();
        } else {
          field.value = null;
        }
      }
    }

    // apply answers
    for (XmlElement node in nodes) {
      ///
      // Value
      ///
      String? answer = Xml.getText(node);
      String? id = Xml.get(node: node, tag: 'id');
      IFormField field = getField(id)!;

      dynamic value = field.value;
      if (value is List) {
        field.value.add(answer);
      } else {
        field.value = answer;
      }

      /// GeoCode for each [iFormField] which is set on answer
      field.geocode = Payload(
          latitude: S.toDouble(Xml.attribute(node: node, tag: 'latitude')),
          longitude: S.toDouble(Xml.attribute(node: node, tag: 'longitude')),
          altitude: S.toDouble(Xml.attribute(node: node, tag: 'altitude')),
          epoch: S.toInt(Xml.attribute(node: node, tag: 'epoch')));
    }

    // mark form clean
    clean = true;

    // add dirty listener to each field
    for (var field in fields) {
      if (field.dirtyObservable != null) {
        field.dirtyObservable!.registerListener(onDirtyListener);
      }
    }

    // add dirty listener to each sub-form
    for (var form in forms) {
      Observable? property = form.dirtyObservable;
      if (property != null) property.registerListener(onDirtyListener);
    }
  }

  static List<IFormField> getFields(List<WidgetModel>? children) {
    List<IFormField> fields = [];
    if (children != null) {
      for (var child in children) {
        if (child is IFormField) fields.add(child as IFormField);
        if (child is! IForm) fields.addAll(getFields(child.children));
      }
    }
    return fields;
  }

  static List<IForm> getForms(List<WidgetModel>? children) {
    List<IForm> forms = [];
    if (children != null) {
      for (var child in children) {
        if (child is IForm) forms.add(child as IForm);
        if (child is! IForm) forms.addAll(getForms(child.children));
      }
    }
    return forms;
  }

  Future<bool> _post(hive_form.Form? form, {bool? commit}) async {
    bool ok = true;
    if ((scope != null) && (postbrokers != null)) {
      for (String id in postbrokers!) {
        IDataSource? source = scope!.getDataSource(id);
        if ((source != null) && (ok) && (commit != false)) {
          if (source.custombody != true) {
            source.body =
                await buildPostingBody(fields, rootname: source.root ?? "FORM");
          }
          ok = await source.start(key: form!.key);
        }
        if (!ok) {
          break;
        }
      }
    } else {
      ok = false;
    }
    return ok;
  }

  Future<bool> clear() async {
    busy = true;

    bool ok = true;

    // Clear Fields
    for (var field in fields) {
      field.value = field.defaultValue ?? "";
    }

    // Set Clean
    if (ok == true) clean = true;

    busy = false;

    return ok;
  }

  Future<bool> complete() async {
    busy = true;

    bool ok = true;

    // Post Sub-Forms
    for (IForm form in forms) {
      ok = await form.complete();
      if (!ok) break;
    }

    // validate the form in the complete method.
    bool validated = (await validate() == null);

    // Save the Form and pass the validation check so validate is not called a second time. This is so the form is always saved on complete.
    hive_form.Form? form =
        await save(previouslyValidated: true, validation: validated);

    if (!validated) {
      busy = false;
      return false;
    }

    // Post the Form
    if (ok) ok = await _post(form);

    // Set Clean
    if (ok == true) clean = true;

    // fire on complete events
    if (ok && _oncomplete != null) {
      ok = await EventHandler(this).execute(_oncomplete);
    }

    busy = false;

    // Set Complete
    status = StatusCodes.complete;

    return ok;
  }

  IFormField? getField(String? id) {
    IFormField? model;
    for (IFormField field in fields) {
      if (field.id == id) {
        model = field;
        break;
      }
    }
    return model;
  }

  static bool _serializeAnswers(XmlElement node, List<IFormField> fields) {
    bool ok = true;

    // Remove Old Answers

    node.children.removeWhere((child) {
      if ((child is XmlElement) && (child.name.local == "ANSWER")) {
        return true;
      } else {
        return false;
      }
    });

    // Insert New Answers
    for (var field in fields) {
      _insertAnswers(node, field);
    }

    return ok;
  }

  static bool _insertAnswers(XmlElement root, IFormField field) {
    try {
      // field is postable?
      if ((field.postable ?? false) && (field.values != null)) {
        for (var value in field.values!) {
          // create new element
          XmlElement node = XmlElement(XmlName("ANSWER"));

          // id
          if (field.id != null) {
            node.attributes.add(XmlAttribute(XmlName("id"), field.id!));
          }

          // field
          if (!S.isNullOrEmpty(field.field)) {
            node.attributes.add(XmlAttribute(XmlName("field"), field.field!));
          }

          // field type
          if (!S.isNullOrEmpty(field.elementName)) {
            node.attributes
                .add(XmlAttribute(XmlName('type'), field.elementName));
          }

          // field meta data
          if (!S.isNullOrEmpty(field.meta)) {
            node.attributes.add(XmlAttribute(XmlName('meta'), field.meta));
          }

          /// GeoCode for each [iFormField] which is set on answer
          if (field.geocode != null) field.geocode!.serialize(node);

          // field value
          try {
            // xml data
            if ((field is InputModel) && (field.format == InputFormats.xml)) {
              var document = XmlDocument.parse(value);
              var e = document.rootElement;
              document.children.remove(e);
              node.children.add(e);
            }

            // special characters in xml? wrap in CDATA
            else if (Xml.hasIllegalCharacters(value)) {
              node.children.add(XmlCDATA(value));
            } else {
              node.children.add(XmlText(value));
            }
          } catch (e) {
            node.children.add(XmlCDATA(e.toString()));
          }

          // add to root
          root.children.add(node);
        }
      }
    } catch (e) {
      Log().error("Error serializing answers");
      Log().exception(e, caller: 'form.Model');
      return false;
    }
    return true;
  }

  static Future<String?> serialize(
      XmlElement? node, List<IFormField> fields) async {
    if (node == null) return null;

    // Serialize Answers
    _serializeAnswers(node, fields);

    // Return Formatted Xml
    return node.toXmlString(pretty: true);
  }

  static Future<String?> buildPostingBody(List<IFormField>? fields,
      {String rootname = "FORM"}) async {
    try {
      // build xml document
      XmlDocument document = XmlDocument();
      XmlElement root =
          XmlElement(XmlName(S.isNullOrEmpty(rootname) ? "FORM" : rootname));
      document.children.add(root);

      if (fields != null) {
        for (var field in fields) {
          // postable?
          if (field.postable == true) {
            if (field.values != null) {
              field.values?.forEach((value) {
                XmlElement node;
                String name = field.field ?? field.id ?? "";
                try {
                  // valid element name?
                  if (!S.isNumber(name.substring(0, 1))) {
                    node = XmlElement(XmlName(name));
                  } else {
                    node = XmlElement(XmlName("FIELD"));
                    node.attributes.add(XmlAttribute(XmlName('id'), name));
                  }
                } catch (e) {
                  node = XmlElement(XmlName("FIELD"));
                  node.attributes.add(XmlAttribute(XmlName('id'), name));
                }

                // add field type
                if (!S.isNullOrEmpty(field.elementName)) {
                  node.attributes
                      .add(XmlAttribute(XmlName('type'), field.elementName));
                }

                /// GeoCode for each [iFormField] which is set on answer
                if (field.geocode != null) field.geocode!.serialize(node);

                // add meta data
                if (!S.isNullOrEmpty(field.meta)) {
                  node.attributes
                      .add(XmlAttribute(XmlName('meta'), field.meta));
                }

                // value
                try {
                  // Xml Data
                  if ((field is InputModel) &&
                      (field.format == InputFormats.xml)) {
                    var document = XmlDocument.parse(value);
                    var e = document.rootElement;
                    document.children.remove(e);
                    node.children.add(e);
                  }

                  // Non-XML? Wrap in CDATA
                  else if (Xml.hasIllegalCharacters(value)) {
                    node.children.add(XmlCDATA(value));
                  } else {
                    node.children.add(XmlText(value));
                  }
                } on XmlException catch (e) {
                  node.children.add(XmlCDATA(e.message));
                }

                // Add Node
                root.children.add(node);
              });
            } else {
              // Build Element
              XmlElement node;
              String name = field.field ?? field.id ?? "";
              try {
                // Valid Element Name
                if (!S.isNumber(name.substring(0, 1))) {
                  node = XmlElement(XmlName(name));
                }

                // In-Valid Element Name
                else {
                  node = XmlElement(XmlName("FIELD"));
                  node.attributes.add(XmlAttribute(XmlName('id'), name));
                }
              } catch (e) {
                // In-Valid Element Name
                node = XmlElement(XmlName("FIELD"));
                node.attributes.add(XmlAttribute(XmlName('id'), name));
              }

              // Add Field Type
              if (!S.isNullOrEmpty(field.elementName)) {
                node.attributes
                    .add(XmlAttribute(XmlName('type'), field.elementName));
              }

              // Add Node
              root.children.add(node);
            }
          }
        }
      }

      // Set Body
      return document.toXmlString(pretty: true);
    } catch (e) {
      Log().error(
          "Error serializing posting document. Error is ${e.toString()}");
      return null;
    }
  }

  Future<List<IFormField>?> validate() async {
    // Force Close
    WidgetModel.unfocus();

    // Commit the Form
    var missing = await _getMissing();
    if (missing?.isNotEmpty == true) {
      // display toast message
      String msg =
          phrase.warningMandatory.replaceAll('{#}', missing!.length.toString());
      System.toast("${phrase.warning} $msg");

      // scroll to the field
      var view = findListenerOfExactType(FormViewState);
      //TODO: when field is cleared, scroll to the next alarming field without validation.
      if (view is FormViewState) view.show(missing.first);

      return missing;
    }

    var alarms = await _getAlarms();
    if (alarms?.isNotEmpty == true) {
      // display toast message
      String msg =
          phrase.warningAlarms.replaceAll('{#}', alarms!.length.toString());
      System.toast("${phrase.warning} $msg");

      // scroll to the field
      var view = findListenerOfExactType(FormViewState);
      if (view is FormViewState) view.show(alarms.first);

      return alarms;
    }

    return null;
  }

  Future<hive_form.Form?> save(
      {bool previouslyValidated = false, bool validation = false}) async {
    hive_form.Form? form;

    bool ok = validation;

    // Validate the Data
    if (!previouslyValidated) {
      ok = (await validate() == null);
    }

    // Show Success
    if (ok) {
      // Serialize the Form
      await serialize(element, fields);

      // Serialize Outer Xml
      String xml = framework!.element!.toXmlString(pretty: true);

      // Lookup Form
      form = await hive_form.Form.find(framework!.key);

      // Update the Form
      if (form != null) {
        Log().info('Updating Form');

        form.complete = completed;
        form.updated = DateTime.now().millisecondsSinceEpoch;
        form.template = xml;
        form.data = map;
        await form.update();
      }

      // Insert the Form
      else {
        Log().info('Inserting New form');
        form = hive_form.Form(
            key: framework?.key,
            parent: framework?.dependency,
            complete: completed,
            template: xml,
            data: map);
        await form.insert();
      }
      // Mark Clean
      clean = true;
    }
    return form;
  }

  Future<List<IFormField>?> _getMissing() async {
    List<IFormField>? missing;
    for (var field in fields) {
      bool? isMandatory;
      if ((field.mandatory != null)) isMandatory = field.mandatory;
      if ((isMandatory == null) && (mandatory != null)) isMandatory = mandatory;
      isMandatory ??= false;
      if ((isMandatory) && (!field.answered)) {
        missing ??= [];
        missing.add(field);
        //set the error state of the field and update the error message
        field.systemerrortext = "This Field is Mandatory";
        field.error = true;
      }
    }
    return missing;
  }

  Future<void> _fillEmptyFields() async {
    //display busy
    busy = true;
    bool ok = false;

    if ((scope != null) && (data != null)) {
      //for a single datasource grab the scope
      IDataSource? source = scope!.getDataSource(data[0]);
      if (source != null) {
        // start the datasource
        ok = await source.start();
      }

      // if the data is null do not fill fields
      if (source?.data == null || source == null) ok = false;

      if (ok) {
        for (var field in fields) {
          // check to see if the field is not assigned a by the developer, even if that value is null, and is not answered.
          if ((isNull(field.value) || field.hasDefaulted == true) &&
              field.touched == false) {
            //create the binding string based on the fields ID.
            String binding = '${field.id}';
            //assign the signature of the source to the field and grab it from the data. Data will generally return a list, so we must grab the 0th element.
            dynamic sourceData = Data.fromDotNotation(source!.data!, DotNotation.fromString(binding)!)?.elementAt(0);

            //data can return a jsonmap as part of the data's list if it fails to grab the binding. If this is the case, do not set the value.
            if (sourceData != null && sourceData is! Map) {
              field.value = sourceData.toString();
            }
          }
        }
      }
    }
    //Set busy to false
    busy = false;
  }

  Future<List<IFormField>?> _getAlarms() async {
    List<IFormField>? alarming;
    for (var field in fields) {
      if (field.alarming!) {
        //tell the form that validation has been hit
        field.validationHasHit = true;
        alarming ??= [];
        //add the field to the forms list of alarms
        alarming.add(field);
      }
    }
    return alarming;
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case 'complete':
        return complete();

      case 'save':
        return (await save() != null);

      case 'validate':
        return (await validate() == null);

      case 'clear':
        return clear();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) {
    clean = true;
    return super.onDataSourceSuccess(source, list);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(FormView(this));
}

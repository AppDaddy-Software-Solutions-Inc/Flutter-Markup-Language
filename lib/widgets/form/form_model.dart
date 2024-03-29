// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/data/data.dart';
import 'package:fml/data/dotnotation.dart';
import 'package:fml/datasources/gps/payload.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/fml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/form/form_interface.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/hive/form.dart' as hive;
import 'package:fml/widgets/form/form_view.dart';
import 'package:fml/widgets/input/input_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum StatusCodes { incomplete, complete }

class FormModel extends BoxModel implements IForm {
  @override
  String get layout => super.layout ?? "column";

  // list of all form fields
  List<IFormField> formFields = [];

  List<IForm> forms = [];

  /// Post tells the form whether or not to include the field in the posting body. If post is null, visible determines post.
  BooleanObservable? _post;
  set post(dynamic v) {
    if (_post != null) {
      _post!.set(v);
    } else if (v != null) {
      _post = BooleanObservable(Binding.toKey(id, 'post'), v, scope: scope);
    }
  }

  @override
  bool? get post => _post?.get();

  // dirty
  @override
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
  @override
  set dirty(dynamic v) {
    if (_dirty != null) {
      _dirty!.set(v);
    } else if (v != null) {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope);
    }
  }

  @override
  bool get dirty => _dirty?.get() ?? false;

  // posting source source
  List<String>? _postbrokers;
  set postbrokers(dynamic v) {
    if (v is String) {
      var values = v.split(",");
      _postbrokers = [];
      for (var e in values) {
        if (!isNullOrEmpty(e)) _postbrokers!.add(e.trim());
      }
    }
  }

  List<String>? get postbrokers => _postbrokers;

  // status
  StringObservable? _status;
  set status(dynamic v) {
    StatusCodes? status = toEnum(v.toString(), StatusCodes.values);
    status ??= StatusCodes.incomplete;
    v = fromEnum(status);
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
      (toEnum(status, StatusCodes.values) == StatusCodes.complete);

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
    if ((FmlEngine.isWeb) || (_autosave == null)) return false;
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

  void onDirtyListener(Observable property) {
    // set form dirty
    bool isDirty = false;
    for (var field in formFields) {
      if (field.dirty == true) isDirty = true;
    }
    dirty = isDirty;

    // auto save?
    if (isDirty && autosave == true) _saveForm();
  }

  @override
  set clean(bool b) {
    // clean all fields
    for (var field in formFields) {
      field.dirty = false;
    }

    // clean all sub-forms
    for (var form in forms) {
      form.clean = false;
    }
    dirty = false;
  }

  // gps
  BooleanObservable? _geocode;
  set geocode(dynamic v) {
    if (_geocode != null) {
      _geocode!.set(v);
    } else if (v != null) {
      _geocode = BooleanObservable(Binding.toKey(id, 'geocode'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get geocode {
    if (_geocode == null) return (FmlEngine.isMobile ? true : false);
    return _geocode?.get();
  }

  // on complete event
  StringObservable? _onComplete;
  set onComplete(dynamic v) {
    if (_onComplete != null) {
      _onComplete!.set(v);
    } else if (v != null) {
      _onComplete = StringObservable(Binding.toKey(id, 'onComplete'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get onComplete => _onComplete?.get();

  // on save event
  StringObservable? _onSave;
  set onSave(dynamic v) {
    if (_onSave != null) {
      _onSave!.set(v);
    } else if (v != null) {
      _onSave = StringObservable(Binding.toKey(id, 'onSave'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get onSave => _onSave?.get();

  // on validate event
  StringObservable? _onValidate;
  set onValidate(dynamic v) {
    if (_onValidate != null) {
      _onValidate!.set(v);
    } else if (v != null) {
      _onValidate = StringObservable(Binding.toKey(id, 'onValidate'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get onValidate => _onValidate?.get();

  // failed validation event
  StringObservable? _onInvalid;
  set onInvalid(dynamic v) {
    if (_onInvalid != null) {
      _onInvalid!.set(v);
    } else if (v != null) {
      _onInvalid = StringObservable(Binding.toKey(id, 'onInvalid'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get onInvalid => _onInvalid?.get();

  Map<String, String?> get map {
    Map<String, String?> myMap = <String, String?>{};

    for (var field in formFields) {
      if ((field.elementName != "attachment") &&
          (!isNullOrEmpty(field.value))) {
        String? value;

        // List of Values
        if (field.value is List) {
          field.value.forEach((v) {
            value = (value == null) ? v.toString() : "${value!},$v";
          });
        } else {
          value = field.value.toString();
        }

        // Set the Value
        if (field.id != null) myMap[field.id!] = value;
      }
    }
    return myMap;
  }

  FormModel(
    WidgetModel super.parent,
    super.id, {
    String? type,
    String? title,
    dynamic status,
    dynamic busy,
    dynamic visible,
    dynamic autosave,
    dynamic mandatory,
    dynamic geocode,
    dynamic data,
  }) {
    // instantiate busy observable
    busy = false;

    this.status = status;
    this.autosave = autosave;
    this.mandatory = mandatory;
    dirty = false;
    this.geocode = geocode;
    this.data = data;
  }

  static FormModel? fromXml(WidgetModel parent, XmlElement xml) {
    FormModel? model;

    try {
      model = FormModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'form.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml) {
    if (xml == null) return;

    // deserialize
    super.deserialize(xml);

    // properties
    status = Xml.get(node: xml, tag: 'status');
    autosave = Xml.get(node: xml, tag: 'autosave');
    mandatory = Xml.get(node: xml, tag: 'mandatory');
    post = Xml.get(node: xml, tag: 'post');
    geocode = Xml.get(node: xml, tag: 'geocode');
    postbrokers = Xml.attribute(node: xml, tag: 'post') ??
        Xml.attribute(node: xml, tag: 'postbroker');

    // events
    onComplete = Xml.get(node: xml, tag: 'oncomplete');
    onSave = Xml.get(node: xml, tag: 'onsave');
    onValidate = Xml.get(node: xml, tag: 'onvalidate');
    onInvalid = Xml.get(node: xml, tag: 'oninvalid');

    // get fields
    setFormFields();

    // fill all empty fields with the datasource if specified
    var datasource = Xml.attribute(node: xml, tag: 'data');
    if (datasource != null) {
      IDataSource? source = scope?.getDataSource(datasource);
      if (source != null) source.register(this);
    }

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
          latitude: toDouble(Xml.attribute(node: node, tag: 'latitude')),
          longitude: toDouble(Xml.attribute(node: node, tag: 'longitude')),
          altitude: toDouble(Xml.attribute(node: node, tag: 'altitude')),
          epoch: toInt(Xml.attribute(node: node, tag: 'epoch')));
    }

    // mark form clean
    clean = true;

    // add dirty listener to each field
    for (var field in formFields) {
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

  void setFormFields() {
    formFields.clear();
    formFields.addAll(_getFormFields(children));
  }

  static List<IFormField> _getFormFields(List<WidgetModel>? children) {
    List<IFormField> fields = [];
    if (children != null) {
      for (var child in children) {
        if (child is IFormField) fields.add(child as IFormField);
        if (child is! IForm) fields.addAll(_getFormFields(child.children));
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

  Future<bool> _postForm(hive.Form? form, {bool? commit}) async {
    bool ok = true;
    if ((scope != null) && (postbrokers != null)) {
      for (String id in postbrokers!) {
        IDataSource? source = scope!.getDataSource(id);
        if ((source != null) && (ok) && (commit != false)) {
          if (!source.custombody) {
            source.body = await buildPostingBody(this, formFields,
                rootname: source.root ?? "FORM");
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
    for (var field in formFields) {
      field.value = field.defaultValue ?? "";
    }

    // Set Clean
    if (ok == true) clean = true;

    busy = false;

    return ok;
  }

  @override
  Future<bool> complete() async {
    // set busy
    busy = true;

    // return code
    bool ok = true;

    // set incomplete
    if (ok) status = StatusCodes.incomplete;

    // complete subforms
    // for (IForm form in forms)
    // {
    //   //ok = await form.complete();
    //   if (!ok) break;
    // }

    // validate the form
    if (ok) ok = await validate();

    // save the form and pass the validation check so validate is not called a second time. This is so the form is always saved on complete.
    hive.Form? form;
    if (ok) form = await _saveForm();

    // Post the Form
    if (ok) ok = await _postForm(form);

    // Set Clean
    if (ok == true) clean = true;

    // fire on complete event
    if (ok) ok = await EventHandler(this).execute(_onComplete);

    // set complete
    if (ok) status = StatusCodes.complete;

    // clear busy
    busy = false;

    return ok;
  }

  IFormField? getField(String? id) {
    IFormField? model;
    for (IFormField field in formFields) {
      if (field.id == id) {
        model = field;
        break;
      }
    }
    return model;
  }

  static bool _serializeAnswers(
      XmlElement node, IForm form, List<IFormField> fields) {
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
      _insertAnswers(node, form, field);
    }

    return ok;
  }

  static bool _insertAnswers(XmlElement root, IForm form, IFormField field) {
    try {
      // field is postable?
      if (isPostable(form, field) && (field.values != null)) {
        for (var value in field.values!) {
          // create new element
          XmlElement node = XmlElement(XmlName("ANSWER"));

          // id
          if (field.id != null) {
            node.attributes.add(XmlAttribute(XmlName("id"), field.id!));
          }

          // field
          if (!isNullOrEmpty(field.field)) {
            node.attributes.add(XmlAttribute(XmlName("field"), field.field!));
          }

          // field type
          if (!isNullOrEmpty(field.elementName)) {
            node.attributes
                .add(XmlAttribute(XmlName('type'), field.elementName));
          }

          // field meta data
          if (!isNullOrEmpty(field.metaData)) {
            node.attributes.add(XmlAttribute(XmlName('meta'), field.metaData));
          }

          /// GeoCode for each [iFormField] which is set on answer
          if (field.geocode != null) field.geocode!.serialize(node);

          // field value
          try {
            // xml data
            if (field is InputModel && (field.formatType == "xml")) {
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
      XmlElement? node, IForm form, List<IFormField> fields) async {
    if (node == null) return null;

    // Serialize Answers
    _serializeAnswers(node, form, fields);

    // Return Formatted Xml
    return node.toXmlString(pretty: true);
  }

  static bool isPostable(IForm form, IFormField field) {
    if (field.post != null) return field.post!;
    if (form.post != null) return form.post!;
    if (field.value == null) return false;
    if (field is List && (field as List).isEmpty) return false;
    return true;
  }

  static Future<String?> buildPostingBody(IForm form, List<IFormField>? fields,
      {String rootname = "FORM"}) async {
    try {
      // build xml document
      XmlDocument document = XmlDocument();
      XmlElement root =
          XmlElement(XmlName(isNullOrEmpty(rootname) ? "FORM" : rootname));
      document.children.add(root);

      if (fields != null) {
        for (var field in fields) {
          // postable?
          if (isPostable(form, field) == true) {
            if (field.values != null) {
              field.values?.forEach((value) {
                XmlElement node;
                String name = field.field ?? field.id ?? "";
                try {
                  // valid element name?
                  if (!isNumeric(name.substring(0, 1))) {
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
                if (!isNullOrEmpty(field.elementName)) {
                  node.attributes
                      .add(XmlAttribute(XmlName('type'), field.elementName));
                }

                /// GeoCode for each [iFormField] which is set on answer
                if (field.geocode != null) field.geocode!.serialize(node);

                // add meta data
                if (!isNullOrEmpty(field.metaData)) {
                  node.attributes
                      .add(XmlAttribute(XmlName('meta'), field.metaData));
                }

                // value
                try {
                  // Xml Data
                  if (field is InputModel && field.formatType == "xml") {
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
                if (!isNumeric(name.substring(0, 1))) {
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
              if (!isNullOrEmpty(field.elementName)) {
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

  @override
  Future<bool> validate() async {
    bool ok = true;

    // force commits on focused field
    WidgetModel.unfocus();

    // get all fields in alarm state
    var list = _getAlarmingFields();
    if (list.isNotEmpty) ok = false;

    //taost and scroll
    if (list.isNotEmpty) {
      // display toast message
      //String msg = phrase.warningAlarms.replaceAll('{#}', list.length.toString());
      //System.toast("${phrase.warning} $msg");

      // scroll to the field
      var view = findListenerOfExactType(FormViewState);
      if (view is FormViewState) view.show(list.first);
    }

    // execute validation events
    if (ok) {
      await EventHandler(this).execute(_onValidate);
    } else {
      await EventHandler(this).execute(_onInvalid);
    }

    return ok;
  }

  @override
  Future<bool> save() async {
    var form = await _saveForm();
    return form != null;
  }

  Future<hive.Form?> _saveForm() async {
    hive.Form? form;

    // Serialize the Form
    await serialize(element, this, formFields);

    // Serialize Outer Xml
    String xml = framework!.element!.toXmlString(pretty: true);

    // Lookup Form
    form = await hive.Form.find(framework!.key);

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
      form = hive.Form(
          key: framework?.key,
          parent: framework?.dependency,
          complete: completed,
          template: xml,
          data: map);
      await form.insert();
    }

    // mark clean
    clean = true;

    return form;
  }

  List<IFormField> _getAlarmingFields() {
    List<IFormField> list = [];
    for (var field in formFields) {
      // touch all fields
      field.touched = true;

      var alarm = field.getActiveAlarm();
      if (alarm != null &&
          field.enabled &&
          field.visible &&
          (field.editable ?? true)) {
        list.add(field);
      }
    }
    return list;
  }

  void _fillEmptyFields(Data? data) {
    // if the data is null do not fill fields
    if (data != null) {
      for (var field in formFields) {
        // check to see if the field is not assigned a by the developer, even if that value is null, and is not answered.
        if (isNullOrEmpty(field.value) && !field.touched) {
          //create the binding string based on the fields ID.
          String binding = '${field.id}';

          //assign the signature of the source to the field and grab it from the data. Data will generally return a list, so we must grab the 0th element.
          dynamic sourceData =
              Data.fromDotNotation(data, DotNotation.fromString(binding)!)
                  ?.elementAt(0);

          // data can return a jsonmap as part of the data's list if it fails to grab the binding. If this is the case, do not set the value.
          if (sourceData != null && sourceData is! Map) {
            field.value = sourceData.toString();
          }
        }
      }
    }
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;

    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case 'complete':
        return await complete();

      case 'save':
        return await save();

      case 'validate':
        return await validate();

      case 'clear':
        return clear();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    // fill empty fields?
    if (source.id == datasource) {
      _fillEmptyFields(list);
      source.remove(this);
    }

    // set form clean
    else {
      clean = true;
    }

    return super.onDataSourceSuccess(source, list);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(FormView(this));
}

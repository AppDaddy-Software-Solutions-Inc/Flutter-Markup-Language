// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class Distinct extends TransformModel implements ITransform {
  ///////////
  /* field */
  ///////////
  StringObservable? _field;
  set field(dynamic v) {
    if (_field != null) {
      _field!.set(v);
    } else if (v != null) {
      _field = StringObservable(Binding.toKey(id, 'field'), v, scope: scope);
    }
  }

  String? get field => _field?.get();

  Distinct(Model? parent, {String? id, dynamic enabled, dynamic field})
      : super(parent, id) {
    this.enabled = enabled ?? true;
    this.field = field;
  }

  static Distinct? fromXml(Model? parent, XmlElement xml) {
    String? id = Xml.get(node: xml, tag: 'id');
    if (isNullOrEmpty(id)) id = newId();

    Distinct model = Distinct(parent,
        id: id,
        enabled: Xml.get(node: xml, tag: 'enabled'),
        field: Xml.get(node: xml, tag: 'field'));
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);
  }

  _fromList(Data? data) {
    if (data == null) return null;

    List<Map<String, dynamic>> distinctList = [];
    List<String?> uniqueFields = [];

    if (field == null) {
      data.toSet().toList();
    } else {
      for (dynamic l in data) {
        if (!uniqueFields.contains(l[field])) {
          uniqueFields.add(l[field]);
          distinctList.add(Map<String, dynamic>.from(l));
        }
      }
      data.clear();
      data.addAll(distinctList);
    }
  }

  String encode(String v) {
    List<String?>? bindings = Binding.getBindingStrings(v);
    if (bindings != null) {
      for (var binding in bindings) {
        if (!binding!.contains(".")) {
          v = v.replaceAll(
              binding, binding.replaceAll("{", "[[[[").replaceAll("}", "]]]]"));
        }
      }
    }
    return v;
  }

  String decode(String v) {
    v = v.replaceAll("[[[[", "{");
    v = v.replaceAll("]]]]", "}");
    return v;
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    _fromList(data);
  }
}

// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/colorpicker/colorpicker_model.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/text/text_view.dart';

class ColorPickerView {

  static Color? colorSelected;

  static launchPicker(ColorpickerModel model, BuildContext? context) async {
    if (context == null) return;

    colorSelected = null;

    var buttons = const ColorPickerActionButtons(dialogActionButtons: false, closeButton: true);

    var view = ColorPicker(
        color: toColor(model.value) ?? Colors.transparent,
        onColorChanged: (Color color) => colorSelected = color,
        width: model.width ?? 44,
        height: model.height ?? 44,
        hasBorder: model.border != 'none',
        borderRadius: model.radius,
        borderColor: model.borderColor,
        actionButtons: buttons,
        heading: TextView(TextModel(null, null, value: model.heading, size: 20)),
        subheading: TextView(TextModel(null, null, value: model.subheading, size: 20)));

    // wait for the dialog to be dismissed
    await view.showPickerDialog(context);

    // selected?
    if (colorSelected != null) {
      model.setSelectedColor(colorSelected);
    }
  }
}

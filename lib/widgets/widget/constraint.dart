class Constraints
{
  // width
  double? _width;
  set width(double? v) => _width = v;
  double? get width
  {
    if (_width == null) return null;
    if (_width == double.infinity) return null;
    if (_width! < 0) return null;
    return _width;
  } 
  
  double? _minWidth;
  set minWidth(double? v) => _minWidth = v;
  double? get minWidth
  {
    if (_minWidth == null) return null;
    if (_minWidth == double.infinity) return null;
    if (_minWidth! < 0) return null;
    return _minWidth;
  }

  double? _maxWidth;
  set maxWidth(double? v) => _maxWidth = v;
  double? get maxWidth
  {
    if (_maxWidth == null) return null;
    if (_maxWidth == double.infinity) return null;
    if (_maxWidth! < 0) return null;
    return _maxWidth;
  }

  // height
  double? _height;
  set height(double? v) => _height = v;
  double? get height
  {
    if (_height == null) return null;
    if (_height == double.infinity) return null;
    if (_height! < 0) return null;
    return _height;
  }

  double? _minHeight;
  set minHeight(double? v) => _minHeight = v;
  double? get minHeight
  {
    if (_minHeight == null) return null;
    if (_minHeight == double.infinity) return null;
    if (_minHeight! < 0) return null;
    return _minHeight;
  }

  double? _maxHeight;
  set maxHeight(double? v) => _maxHeight = v;
  double? get maxHeight
  {
    if (_maxHeight == null) return null;
    if (_maxHeight == double.infinity) return null;
    if (_maxHeight! < 0) return null;
    return _maxHeight;
  }

  bool get hasConstraints => hasVerticalConstraints || hasHorizontalConstraints;
  bool get hasNoConstraints => !hasConstraints;

  bool get hasVerticalContractionConstraints => height != null || minHeight != null;
  bool get hasVerticalExpansionConstraints => height != null || maxHeight != null;
  bool get hasVerticalConstraints => hasVerticalExpansionConstraints || hasVerticalContractionConstraints;

  bool get hasHorizontalContractionConstraints => width != null || minWidth != null;
  bool get hasHorizontalExpansionConstraints => width != null || maxWidth != null;
  bool get hasHorizontalConstraints => hasHorizontalExpansionConstraints || hasHorizontalContractionConstraints;
}
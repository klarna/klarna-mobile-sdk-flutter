/// Returns the next placement height for a resize, or null to keep current.
double? nextHeightOnResize({
  required double rawHeight,
  required double prevHeight,
  required bool hasError,
  bool isFirstResize = false,
}) {
  if (hasError) {
    return null;
  }
  if (!rawHeight.isFinite || rawHeight < 0) {
    return null;
  }
  if (rawHeight == prevHeight && !isFirstResize) {
    return null;
  }
  return rawHeight;
}

enum SafetyControlCommand {
  clear(0x00),
  risk(0x01),
  accident(0x02);

  const SafetyControlCommand(this.byteValue);
  final int byteValue;

  String get hex =>
      '0x${byteValue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

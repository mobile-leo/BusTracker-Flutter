class BusPosition {
  final String prefix;
  final bool accessible;
  final double latitude;
  final double longitude;

  const BusPosition({
    required this.prefix,
    required this.accessible,
    required this.latitude,
    required this.longitude,
  });
}

class LineBusPositions {
  final int lineCode;
  final String sign;
  final int direction;
  final String terminalPrimary;
  final String terminalSecondary;
  final List<BusPosition> vehicles;

  const LineBusPositions({
    required this.lineCode,
    required this.sign,
    required this.direction,
    required this.terminalPrimary,
    required this.terminalSecondary,
    required this.vehicles,
  });
}

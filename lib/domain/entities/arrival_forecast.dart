class VehicleForecast {
  final String prefix;
  final bool accessible;
  final String arrivalTime;

  const VehicleForecast({
    required this.prefix,
    required this.accessible,
    required this.arrivalTime,
  });
}

class LineForecast {
  final int lineCode;
  final String sign;
  final int direction;
  final String terminalPrimary;
  final String terminalSecondary;
  final List<VehicleForecast> vehicles;

  const LineForecast({
    required this.lineCode,
    required this.sign,
    required this.direction,
    required this.terminalPrimary,
    required this.terminalSecondary,
    required this.vehicles,
  });
}

class ArrivalForecast {
  final int stopCode;
  final String stopName;
  final String stopAddress;
  final double latitude;
  final double longitude;
  final List<LineForecast> lines;

  const ArrivalForecast({
    required this.stopCode,
    required this.stopName,
    required this.stopAddress,
    required this.latitude,
    required this.longitude,
    required this.lines,
  });
}

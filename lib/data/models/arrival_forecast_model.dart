import '../../domain/entities/arrival_forecast.dart';

class VehicleForecastModel extends VehicleForecast {
  const VehicleForecastModel({
    required super.prefix,
    required super.accessible,
    required super.arrivalTime,
  });

  factory VehicleForecastModel.fromJson(Map<String, dynamic> json) {
    return VehicleForecastModel(
      prefix: json['p']?.toString() ?? '',
      accessible: json['a'] as bool? ?? false,
      arrivalTime: json['t']?.toString() ?? '',
    );
  }
}

class LineForecastModel extends LineForecast {
  LineForecastModel({
    required super.lineCode,
    required super.sign,
    required super.direction,
    required super.terminalPrimary,
    required super.terminalSecondary,
    required super.vehicles,
  });

  factory LineForecastModel.fromJson(Map<String, dynamic> json) {
    final vs =
        (json['vs'] as List<dynamic>?)
            ?.map(
              (v) => VehicleForecastModel.fromJson(v as Map<String, dynamic>),
            )
            .toList() ??
        [];
    return LineForecastModel(
      lineCode: (json['cl'] as num?)?.toInt() ?? 0,
      sign: json['c']?.toString() ?? '',
      direction: (json['sl'] as num?)?.toInt() ?? 1,
      terminalPrimary: json['lt0']?.toString() ?? '',
      terminalSecondary: json['lt1']?.toString() ?? '',
      vehicles: vs,
    );
  }
}

class ArrivalForecastModel extends ArrivalForecast {
  ArrivalForecastModel({
    required super.stopCode,
    required super.stopName,
    required super.stopAddress,
    required super.latitude,
    required super.longitude,
    required super.lines,
  });

  factory ArrivalForecastModel.fromJson(Map<String, dynamic> json) {
    final p = json['p'] as Map<String, dynamic>? ?? {};
    final ls =
        (p['l'] as List<dynamic>?)
            ?.map((l) => LineForecastModel.fromJson(l as Map<String, dynamic>))
            .toList() ??
        [];
    return ArrivalForecastModel(
      stopCode: (p['cp'] as num?)?.toInt() ?? 0,
      stopName: p['np']?.toString() ?? '',
      stopAddress: p['ed']?.toString() ?? '',
      latitude: (p['py'] as num?)?.toDouble() ?? 0.0,
      longitude: (p['px'] as num?)?.toDouble() ?? 0.0,
      lines: ls,
    );
  }
}

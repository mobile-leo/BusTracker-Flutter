import '../../domain/entities/bus_position.dart';

class BusPositionModel extends BusPosition {
  const BusPositionModel({
    required super.prefix,
    required super.accessible,
    required super.latitude,
    required super.longitude,
  });

  factory BusPositionModel.fromJson(Map<String, dynamic> json) {
    return BusPositionModel(
      prefix: json['p']?.toString() ?? '',
      accessible: json['a'] as bool? ?? false,
      latitude: (json['py'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['px'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LineBusPositionsModel extends LineBusPositions {
  LineBusPositionsModel({
    required super.lineCode,
    required super.sign,
    required super.direction,
    required super.terminalPrimary,
    required super.terminalSecondary,
    required super.vehicles,
  });

  factory LineBusPositionsModel.fromJson(Map<String, dynamic> json) {
    final vs =
        (json['vs'] as List<dynamic>?)
            ?.map((v) => BusPositionModel.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];
    return LineBusPositionsModel(
      lineCode: (json['cl'] as num?)?.toInt() ?? 0,
      sign: json['c']?.toString() ?? '',
      direction: (json['sl'] as num?)?.toInt() ?? 1,
      terminalPrimary: json['lt0']?.toString() ?? '',
      terminalSecondary: json['lt1']?.toString() ?? '',
      vehicles: vs,
    );
  }
}

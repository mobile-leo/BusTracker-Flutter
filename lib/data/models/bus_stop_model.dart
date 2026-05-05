import '../../domain/entities/bus_stop.dart';

class BusStopModel extends BusStop {
  const BusStopModel({
    required super.cp,
    required super.np,
    required super.ed,
    required super.latitude,
    required super.longitude,
  });

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    return BusStopModel(
      cp: (json['cp'] as num?)?.toInt() ?? 0,
      np: json['np']?.toString() ?? '',
      ed: json['ed']?.toString() ?? '',
      latitude: (json['py'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['px'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

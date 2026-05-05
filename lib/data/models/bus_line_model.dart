import '../../domain/entities/bus_line.dart';

class BusLineModel extends BusLine {
  const BusLineModel({
    required super.cl,
    required super.lc,
    required super.lt,
    required super.tl,
    required super.sl,
    required super.tp,
    required super.ts,
  });

  factory BusLineModel.fromJson(Map<String, dynamic> json) {
    return BusLineModel(
      cl: (json['cl'] as num?)?.toInt() ?? 0,
      lc: json['lc'] as bool? ?? false,
      lt: json['lt']?.toString() ?? '',
      tl: (json['tl'] as num?)?.toInt() ?? 1,
      sl: (json['sl'] as num?)?.toInt() ?? 1,
      tp: json['tp']?.toString() ?? '',
      ts: json['ts']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'cl': cl,
    'lc': lc,
    'lt': lt,
    'tl': tl,
    'sl': sl,
    'tp': tp,
    'ts': ts,
  };
}

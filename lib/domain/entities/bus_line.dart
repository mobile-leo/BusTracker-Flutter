class BusLine {
  final int cl;
  final bool lc;
  final String lt;
  final int tl;
  final int sl;
  final String tp;
  final String ts;

  const BusLine({
    required this.cl,
    required this.lc,
    required this.lt,
    required this.tl,
    required this.sl,
    required this.tp,
    required this.ts,
  });

  String get fullName => '$lt - $ts';
  String get direction => tl == 1 ? 'Sentido $ts' : 'Sentido $tp';
}

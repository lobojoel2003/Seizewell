import '../domain/types.dart';

/// Brand and data-visualisation colours as ARGB ints, shared by the Flutter
/// UI and the PDF report.
abstract final class Brand {
  static const violet = 0xFF5B3FD3;
  static const violetDeep = 0xFF22165C;
  static const violetNight = 0xFF140D38;
  static const violetSoft = 0xFFEFEBFB;
  static const ink = 0xFF1C1830;
  static const inkMuted = 0xFF5F5A75;
  static const line = 0xFFDCD8E8;
  static const alert = 0xFFC62828;
  static const alertDeep = 0xFF5C0B0B;
  static const amber = 0xFFF2A516;
  static const calm = 0xFF2E7D5B;

  /// Heat map steps: none, 1, 2, 3+ seizures in a day.
  static const heat = [0xFFEDEAF5, 0xFFC4B8F1, 0xFF8F78E4, 0xFF4B2FC4];

  static int heatFor(int count) => heat[count.clamp(0, heat.length - 1)];

  static int typeColor(SeizureType t) => switch (t) {
    SeizureType.focalAware => 0xFF8C7CF2,
    SeizureType.focalImpaired => 0xFF5B3FD3,
    SeizureType.focalToBilateral => 0xFF9B2FB0,
    SeizureType.tonicClonic => 0xFFD2456A,
    SeizureType.absence => 0xFF1F9AA0,
    SeizureType.myoclonic => 0xFFE08A1E,
    SeizureType.atonic => 0xFF3F83DB,
    SeizureType.tonic => 0xFF8B5E3C,
    SeizureType.clonic => 0xFFD0619C,
    SeizureType.spasms => 0xFF34965A,
    SeizureType.unknown => 0xFF8C8FA3,
  };
}

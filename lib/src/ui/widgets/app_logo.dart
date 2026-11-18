import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// The Seizewell mark: a stopwatch ring holding a calm pulse line, drawn in
/// code so it is crisp at any size and needs no image assets.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Seizewell logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: LogoPainter()),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & Size(s, s);
    final r = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.23));
    canvas.drawRRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B61F0), brandViolet, brandDeep],
        ).createShader(rect),
    );
    // Same geometry as assets/brand/icon.svg (1024 units).
    final u = s / 1024;
    final white = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    canvas.drawCircle(
      Offset(512 * u, 566 * u),
      252 * u,
      white..strokeWidth = 72 * u,
    );
    white.strokeWidth = 64 * u;
    canvas
      ..drawLine(Offset(512 * u, 278 * u), Offset(512 * u, 214 * u), white)
      ..drawLine(Offset(438 * u, 196 * u), Offset(586 * u, 196 * u), white);
    white.strokeWidth = 56 * u;
    canvas.drawLine(Offset(714 * u, 356 * u), Offset(752 * u, 318 * u), white);
    final pulse = Path()
      ..moveTo(342 * u, 566 * u)
      ..lineTo(436 * u, 566 * u)
      ..lineTo(478 * u, 452 * u)
      ..lineTo(548 * u, 690 * u)
      ..lineTo(590 * u, 566 * u)
      ..lineTo(682 * u, 566 * u);
    canvas.drawPath(
      pulse,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 56 * u
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFFFD27A),
    );
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) => false;
}

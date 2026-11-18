import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// The one huge button. A caregiver in a frightening moment should be able
/// to hit it without looking twice.
class BigStartButton extends StatefulWidget {
  const BigStartButton({
    super.key,
    required this.onPressed,
    this.running = false,
    this.size = 232,
  });

  final VoidCallback onPressed;
  final bool running;
  final double size;

  @override
  State<BigStartButton> createState() => _BigStartButtonState();
}

class _BigStartButtonState extends State<BigStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    // Respect reduced-motion settings; otherwise breathe gently.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.disableAnimationsOf(context)) _pulse.repeat();
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final colors = widget.running
        ? const [Color(0xFFE5484D), alertRed]
        : const [Color(0xFF7B61F0), brandViolet, Color(0xFF3D25A8)];
    return Semantics(
      button: true,
      label: widget.running
          ? 'Open the running seizure timer'
          : 'Start seizure timer',
      excludeSemantics: true,
      child: SizedBox(
        width: size + 40,
        height: size + 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final t = _pulse.value;
                return Container(
                  width: size + 36 * t,
                  height: size + 36 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[1].withValues(alpha: 0.18 * (1 - t)),
                  ),
                );
              },
            ),
            GestureDetector(
              key: const Key('start-seizure'),
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              onTap: widget.onPressed,
              child: AnimatedScale(
                scale: _pressed ? 0.95 : 1,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors[1].withValues(alpha: 0.45),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(size * 0.14),
                  // Scales down instead of overflowing with very large
                  // accessibility font sizes.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.running
                              ? Icons.timer_rounded
                              : Icons.touch_app_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.running ? 'Timer running' : 'Start',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.running ? 'Tap to open' : 'seizure timer',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

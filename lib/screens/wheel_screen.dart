import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/content.dart';
import '../data/room_controller.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';
import 'game_header.dart';

/// Çark Çevir — whoever spins writes `{spinId, resultIndex}` to
/// `room/game/wheel`; every client (including the spinner) reacts to the
/// `spinId` change by running its own local spin animation ending on the
/// shared `resultIndex`. Same result everywhere, not frame-synced animation.
class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  int? _lastSpinId;
  bool _seenFirstRoom = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
    // Repaint every tick, and once more on completion so `spinning` (derived
    // from _controller.isAnimating) is re-read and the result panel updates.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRoomWheelState(int? spinId, int? resultIndex, int segmentCount) {
    if (!_seenFirstRoom) {
      _seenFirstRoom = true;
      _lastSpinId = spinId;
      if (resultIndex != null) {
        _currentAngle = _angleFor(resultIndex, segmentCount);
        _animation = Tween<double>(begin: _currentAngle, end: _currentAngle).animate(_controller);
      }
      return;
    }
    if (spinId != null && spinId != _lastSpinId) {
      _lastSpinId = spinId;
      // Defer past the current build — starting the animation calls
      // setState (via the controller listener), which build() may not do.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animateTo(resultIndex ?? 0, segmentCount);
      });
    }
  }

  double _angleFor(int winner, int segmentCount) {
    final seg = 2 * pi / segmentCount;
    final winnerCenter = winner * seg + seg / 2;
    final jitter = (_random.nextDouble() - 0.5) * seg * 0.6;
    return -winnerCenter - jitter;
  }

  void _animateTo(int winner, int segmentCount) {
    final target = _angleFor(winner, segmentCount);
    final normalizedTarget = ((target - _currentAngle) % (2 * pi) + (2 * pi)) % (2 * pi);
    const extraSpins = 5;
    final start = _currentAngle;
    final end = _currentAngle + extraSpins * 2 * pi + normalizedTarget;
    setState(() {
      _animation = Tween<double>(begin: start, end: end)
          .chain(CurveTween(curve: const Cubic(0.16, 1, 0.3, 1)))
          .animate(_controller);
    });
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _currentAngle = end % (2 * pi));
    });
  }

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    final wheel = rc.room!.wheel;
    final segmentCount = wheelSegments.length;
    _onRoomWheelState(wheel?.spinId, wheel?.resultIndex, segmentCount);

    final spinning = _controller.isAnimating;
    final result = (!spinning && wheel?.resultIndex != null) ? wheelSegments[wheel!.resultIndex!] : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const GameHeader(title: 'Çark Çevir', trailing: ''),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: NocturneSpace.side),
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: SizedBox(
                          width: 310,
                          height: 330,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Positioned(
                                top: 20,
                                child: Transform.rotate(
                                  angle: _animation.value,
                                  child: CustomPaint(
                                    size: const Size(310, 310),
                                    painter: _WheelPainter(segmentCount),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 20 + 310 / 2 - 48,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: NocturneColors.bg,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: NocturneColors.surface, width: 8),
                                  ),
                                  child: Text(
                                    spinning ? '…' : 'ÇEVİR',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NocturneColors.neutral500),
                                  ),
                                ),
                              ),
                              const Positioned(top: 0, child: _PointerTriangle()),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      NocturneCard(
                        background: NocturneColors.surface2,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const NocturneKicker('Sonuç'),
                            const SizedBox(height: 8),
                            Text(
                              spinning ? '…' : (result?.label.replaceAll('\n', ' ') ?? 'ÇEVİR'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: NocturneColors.accent400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NocturneSpace.side,
                    12,
                    NocturneSpace.side,
                    NocturneSpace.bottomSafe,
                  ),
                  child: NocturnePrimaryButton(
                    label: spinning ? 'Çevriliyor…' : 'Çarkı çevir',
                    onPressed: spinning ? null : () => rc.spinWheel(segmentCount: segmentCount),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final int segmentCount;
  const _WheelPainter(this.segmentCount);

  static const _palette = [
    NocturneColors.surface,
    NocturneColors.accent,
    NocturneColors.surface,
    NocturneColors.accent2_400,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final seg = 2 * pi / segmentCount;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = -pi / 2 + i * seg;
      paint.color = _palette[i % _palette.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, seg, true, paint);
    }

    canvas.drawCircle(
      center,
      radius - 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = NocturneColors.surface,
    );

    for (int i = 0; i < segmentCount; i++) {
      final mid = -pi / 2 + i * seg + seg / 2;
      final textRadius = radius * 0.62;
      final pos = center + Offset(cos(mid), sin(mid)) * textRadius;
      final tp = TextPainter(
        text: TextSpan(
          text: wheelSegments[i].label,
          style: const TextStyle(color: NocturneColors.text, fontSize: 11, fontWeight: FontWeight.w700, height: 1.1),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.65);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(mid + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

class _PointerTriangle extends StatelessWidget {
  const _PointerTriangle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(26, 22), painter: _PointerPainter());
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = NocturneColors.accent);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}

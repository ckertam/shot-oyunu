import 'dart:math';

import 'package:flutter/material.dart';

import '../data/content.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  int? _resultIndex;
  bool _spinning = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;
    final n = wheelSegments.length;
    final seg = 2 * pi / n;
    final winner = _random.nextInt(n);
    final winnerCenter = winner * seg + seg / 2;
    final jitter = (_random.nextDouble() - 0.5) * seg * 0.6;
    final targetMod = -winnerCenter - jitter;
    final normalizedTarget = ((targetMod - _currentAngle) % (2 * pi) + (2 * pi)) % (2 * pi);
    final extraSpins = 5 + _random.nextInt(3);
    final delta = extraSpins * 2 * pi + normalizedTarget;
    final start = _currentAngle;
    final end = _currentAngle + delta;

    setState(() {
      _spinning = true;
      _resultIndex = null;
      _animation = Tween<double>(begin: start, end: end)
          .chain(CurveTween(curve: Curves.easeOutCubic))
          .animate(_controller)
        ..addListener(() => setState(() {}));
    });

    _controller.forward(from: 0).whenComplete(() {
      setState(() {
        _currentAngle = end % (2 * pi);
        _resultIndex = winner;
        _spinning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final angle = _animation.value;
    final result = _resultIndex != null ? wheelSegments[_resultIndex!] : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Çark Çevir')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 280,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 0,
                          child: CustomPaint(
                            size: const Size(36, 24),
                            painter: _PointerPainter(),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          child: Transform.rotate(
                            angle: angle,
                            child: CustomPaint(
                              size: const Size(280, 280),
                              painter: _WheelPainter(),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20 + 280 / 2 - 10,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black26, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (result != null && !_spinning)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(result.colorValue).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(result.colorValue)),
                  ),
                  child: Text(
                    result.label.replaceAll('\n', ' '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB5607),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _spinning ? null : _spin,
                  child: Text(
                    _spinning ? 'ÇEVRİLİYOR...' : 'ÇARKI ÇEVİR',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = wheelSegments.length;
    final seg = 2 * pi / n;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < n; i++) {
      final startAngle = -pi / 2 + i * seg;
      paint.color = Color(wheelSegments[i].colorValue);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, seg, true, paint);
    }

    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 2;
    for (int i = 0; i < n; i++) {
      final a = -pi / 2 + i * seg;
      canvas.drawLine(center, center + Offset(cos(a), sin(a)) * radius, linePaint);
    }

    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.8),
    );

    for (int i = 0; i < n; i++) {
      final mid = -pi / 2 + i * seg + seg / 2;
      final textRadius = radius * 0.62;
      final pos = center + Offset(cos(mid), sin(mid)) * textRadius;

      final tp = TextPainter(
        text: TextSpan(
          text: wheelSegments[i].label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
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

/// Çarkın üstündeki sabit ok — hangi dilimin kazandığını gösterir.
/// (Icons.arrow_drop_down_rounded web'de bu ekranda görünmüyordu, o yüzden
/// tıpkı çark gibi doğrudan canvas'a çiziliyor.)
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}

import 'dart:math';

import 'package:flutter/material.dart';

/// "Hiç Yapmadım" ve "Kim Daha Çok" modları için ortak ekran: karışık
/// sıradaki bir metin listesini tek tek gösterir, "SIRADAKİ" ile ilerler.
class StatementCycleScreen extends StatefulWidget {
  final String title;
  final Color accentColor;
  final List<String> statements;

  const StatementCycleScreen({
    super.key,
    required this.title,
    required this.accentColor,
    required this.statements,
  });

  @override
  State<StatementCycleScreen> createState() => _StatementCycleScreenState();
}

class _StatementCycleScreenState extends State<StatementCycleScreen> {
  late List<String> _order;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _reshuffle();
  }

  void _reshuffle() {
    setState(() {
      _order = List.of(widget.statements)..shuffle(Random());
      _index = 0;
    });
  }

  void _next() {
    setState(() {
      if (_index + 1 >= _order.length) {
        _reshuffle();
      } else {
        _index++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Yeniden karıştır',
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: _reshuffle,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '${_index + 1} / ${_order.length}',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Container(
                      key: ValueKey(_index),
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: accent.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _order[_index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _next,
                  child: const Text(
                    'SIRADAKİ',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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

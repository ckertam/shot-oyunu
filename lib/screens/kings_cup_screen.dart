import 'dart:math';

import 'package:flutter/material.dart';

import '../data/content.dart';

class KingsCupScreen extends StatefulWidget {
  const KingsCupScreen({super.key});

  @override
  State<KingsCupScreen> createState() => _KingsCupScreenState();
}

class _KingsCupScreenState extends State<KingsCupScreen> {
  static const _accent = Color(0xFFFFD166);

  late List<PlayingCard> _deck;
  int _index = -1;

  @override
  void initState() {
    super.initState();
    _reshuffle();
  }

  void _reshuffle() {
    setState(() {
      _deck = buildDeck()..shuffle(Random());
      _index = -1;
    });
  }

  void _drawNext() {
    setState(() {
      if (_index + 1 >= _deck.length) {
        _reshuffle();
      } else {
        _index++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _index >= 0 ? _deck[_index] : null;
    final remaining = _deck.length - (_index + 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kral Bardağı'),
        actions: [
          IconButton(
            tooltip: 'Desteyi yeniden karıştır',
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: _reshuffle,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                current == null ? 'Deste hazır — kart çek!' : 'Kalan kart: $remaining',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: current == null
                        ? _IntroCard(key: const ValueKey('intro'), accent: _accent)
                        : _CardFace(key: ValueKey(_index), card: current, accent: _accent),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _drawNext,
                  child: Text(
                    current == null ? 'KARTI ÇEK' : 'SIRADAKİ KART',
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

class _IntroCard extends StatelessWidget {
  final Color accent;
  const _IntroCard({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.style_rounded, size: 96, color: accent.withValues(alpha: 0.6));
  }
}

class _CardFace extends StatelessWidget {
  final PlayingCard card;
  final Color accent;
  const _CardFace({super.key, required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final color = card.isRed ? const Color(0xFFEF476F) : Colors.white;
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.rank,
            style: TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            card.suit.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: color.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            card.rule,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.35),
          ),
        ],
      ),
    );
  }
}

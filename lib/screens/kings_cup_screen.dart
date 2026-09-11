import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/content.dart';
import '../data/room_controller.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';
import 'game_header.dart';

/// Kral Bardağı — shared deck order + drawnCount live in
/// `room/game/kings` (see RoomRepository.drawNextKing); any player may draw,
/// guarded by a transaction so a shared tap-race can't double-draw a card.
class KingsCupScreen extends StatefulWidget {
  const KingsCupScreen({super.key});

  @override
  State<KingsCupScreen> createState() => _KingsCupScreenState();
}

class _KingsCupScreenState extends State<KingsCupScreen> {
  final _deck = buildDeck();
  bool _busy = false;

  Future<void> _draw() async {
    setState(() => _busy = true);
    try {
      await context.read<RoomController>().drawNextKing(deckSize: _deck.length);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    final kings = rc.room!.kings;
    final drawn = kings?.drawnCount ?? 0;
    final order = kings?.order ?? const <int>[];
    final current = drawn > 0 && drawn <= order.length ? _deck[order[drawn - 1]] : null;
    final remaining = _deck.length - drawn;
    final kingsSoFar = order.take(drawn).where((i) => _deck[i].rank == 'K').length;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameHeader(
                  title: 'Kral Bardağı',
                  trailing: current == null ? 'Deste hazır' : '$remaining kart kaldı',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: NocturneSpace.side),
                    children: [
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: _busy ? null : _draw,
                        child: Container(
                          height: 300,
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: NocturneColors.neutral200,
                            borderRadius: BorderRadius.circular(NocturneRadius.lg),
                          ),
                          child: current == null
                              ? const Center(
                                  child: Text(
                                    'Kartı çekmek için dokun',
                                    style: TextStyle(color: NocturneColors.neutral700, fontWeight: FontWeight.w600),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _CornerRankSuit(rank: current.rank, suit: current.suit),
                                    ),
                                    Text(
                                      current.suit.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w600,
                                        color: NocturneColors.accent2_700,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Transform.rotate(
                                        angle: 3.14159,
                                        child: _CornerRankSuit(rank: current.rank, suit: current.suit),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: NocturneSpace.cardGap),
                      if (current != null)
                        NocturneCard(
                          background: NocturneColors.surface2,
                          child: Text(
                            current.rule,
                            style: const TextStyle(fontSize: 16, height: 1.45, color: NocturneColors.neutral300),
                          ),
                        ),
                      const SizedBox(height: NocturneSpace.cardGap),
                      NocturneCard(
                        background: NocturneColors.surface3,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        child: Row(
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                '4. kral bardağı devirir ve hepsini içer',
                                style: TextStyle(fontSize: 14, color: NocturneColors.neutral500),
                              ),
                            ),
                            Row(
                              children: List.generate(4, (i) {
                                final filled = i < kingsSoFar;
                                return Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: filled ? NocturneColors.accent2_400 : NocturneColors.border2,
                                  ),
                                );
                              }),
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
                    label: current == null ? 'Kart çek' : 'Sıradaki kart',
                    onPressed: _busy ? null : _draw,
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

class _CornerRankSuit extends StatelessWidget {
  final String rank;
  final String suit;
  const _CornerRankSuit({required this.rank, required this.suit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rank,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: NocturneColors.neutral900),
        ),
        Text(
          suit,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NocturneColors.accent2_700),
        ),
      ],
    );
  }
}

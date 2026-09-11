import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/content.dart';
import '../data/local_settings.dart';
import '../data/room_controller.dart';
import '../data/room_models.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';
import 'game_header.dart';

/// Hiç Yapmadım — console (1c) model: the prompt card stays fixed at the
/// top, the player list sits below it, and tapping a player logs a shot for
/// them ("yaptıysan" — whoever admits gets tapped). "Sonraki kart" advances
/// the shared index. Difficulty-aware deck (room.difficulty).
class NeverHaveIScreen extends StatefulWidget {
  const NeverHaveIScreen({super.key});

  @override
  State<NeverHaveIScreen> createState() => _NeverHaveIScreenState();
}

class _NeverHaveIScreenState extends State<NeverHaveIScreen> {
  bool _busy = false;

  Future<void> _next(int deckSize) async {
    setState(() => _busy = true);
    try {
      await context.read<RoomController>().advanceNever(deckSize: deckSize);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    final room = rc.room!;
    final showShots = context.watch<LocalSettings>().shotCounterVisible;
    final deck = room.difficulty == Difficulty.hard ? neverHaveIEverHard : neverHaveIEverLight;
    final never = room.never;
    final index = never?.index ?? -1;
    final order = never?.order ?? const <int>[];
    final prompt = (index >= 0 && index < order.length) ? deck[order[index] % deck.length] : null;
    final players = room.players.values.toList()..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                GameHeader(
                  title: 'Hiç Yapmadım',
                  trailing: prompt == null ? '' : 'Kart ${index + 1} / ${deck.length}',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: NocturneSpace.side),
                    children: [
                      NocturneCard(
                        background: NocturneColors.surface,
                        borderColor: NocturneColors.border,
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NocturneKicker(room.difficulty == Difficulty.hard ? 'Hard' : 'Light'),
                            const SizedBox(height: 18),
                            Text(
                              prompt ?? 'Başlamak için "Sonraki kart"a dokun',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, height: 1.25),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: NocturneSpace.cardGap),
                      const Text(
                        'İçenlere dokun, sonra sonraki kart.',
                        style: TextStyle(fontSize: 14, color: NocturneColors.neutral500),
                      ),
                      const SizedBox(height: NocturneSpace.cardGap),
                      for (final p in players) ...[
                        _PlayerTapRow(player: p, showShots: showShots),
                        const SizedBox(height: NocturneSpace.cardGap),
                      ],
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
                    label: 'Sonraki kart',
                    onPressed: _busy ? null : () => _next(deck.length),
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

class _PlayerTapRow extends StatelessWidget {
  final Player player;
  final bool showShots;
  const _PlayerTapRow({required this.player, required this.showShots});

  @override
  Widget build(BuildContext context) {
    return NocturneCard(
      background: NocturneColors.surface3,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => context.read<RoomController>().incrementShots(player.uid),
      child: Row(
        children: [
          NocturneAvatar(name: player.name),
          const SizedBox(width: 14),
          Expanded(
            child: Text(player.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          if (showShots)
            Text('${player.shots}', style: const TextStyle(fontWeight: FontWeight.w700, color: NocturneColors.accent400)),
        ],
      ),
    );
  }
}

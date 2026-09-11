import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/room_controller.dart';
import '../data/room_models.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';

/// Oyuncu kurulumu — shown while `room.status == lobby`. Each phone already
/// added itself via StartScreen (real multi-device join, unlike the brief's
/// single-shared-device mock where the host typed every name) — this screen
/// is the live waiting room until the host taps "Devam".
class PlayerSetupScreen extends StatelessWidget {
  const PlayerSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    final room = rc.room!;
    final players = room.players.values.toList()
      ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
    final link = 'https://ckertam.github.io/shot-oyunu/?room=${room.code}';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NocturneSpace.side,
                    18,
                    NocturneSpace.side,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const NocturneKicker('ADIM 1 / 2'),
                      const SizedBox(height: 8),
                      const Text(
                        'Masada kim var?',
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600, letterSpacing: -0.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: NocturneSpace.side),
                    children: [
                      for (final p in players) ...[
                        _PlayerRow(player: p, isHost: rc.isHost, myUid: rc.myUid),
                        const SizedBox(height: NocturneSpace.cardGap),
                      ],
                      const SizedBox(height: 4),
                      NocturneCard(
                        background: NocturneColors.surface3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Oda linki',
                              style: TextStyle(fontSize: 13, color: NocturneColors.neutral500),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    link.replaceFirst('https://', ''),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                NocturneChipButton(
                                  label: 'Kopyala',
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: link));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Link kopyalandı')),
                                      );
                                    }
                                  },
                                ),
                              ],
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
                  child: rc.isHost
                      ? NocturnePrimaryButton(
                          label: 'Devam',
                          onPressed: players.length >= 2 ? () => rc.startGame() : null,
                        )
                      : const Text(
                          'Host oyunu başlatacak…',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: NocturneColors.neutral500),
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

class _PlayerRow extends StatelessWidget {
  final Player player;
  final bool isHost;
  final String? myUid;

  const _PlayerRow({required this.player, required this.isHost, required this.myUid});

  @override
  Widget build(BuildContext context) {
    final canRemove = isHost && player.uid != myUid;
    return Opacity(
      opacity: player.connected ? 1 : 0.6,
      child: NocturneCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            NocturneAvatar(name: player.name, accented: player.isHost),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                player.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!player.connected)
              const Text('bağlanıyor…', style: TextStyle(fontSize: 12, color: NocturneColors.neutral500))
            else if (player.isHost)
              const NocturneTag('HOST')
            else if (canRemove)
              IconButton(
                onPressed: () => context.read<RoomController>().removePlayer(player.uid),
                icon: const Icon(Icons.close, size: 18, color: NocturneColors.border3),
                splashRadius: 18,
              ),
          ],
        ),
      ),
    );
  }
}

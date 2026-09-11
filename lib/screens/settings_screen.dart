import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/local_settings.dart';
import '../data/room_controller.dart';
import '../data/room_models.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';

/// Ayarlar — difficulty is shared room state (host-only write, enforced by
/// RTDB rules); the three toggles below it are per-device local prefs.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    final local = context.watch<LocalSettings>();
    final room = rc.room!;
    final connectedCount = room.players.values.where((p) => p.connected).length;

    // Settings is reached via Navigator.push, not RootScreen's state switch —
    // if the host ends the night while someone's in here, pop back out so
    // RootScreen (underneath) can show GameEndScreen.
    if (room.status == RoomStatus.ended) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: NocturneSpace.side, vertical: 12),
              children: [
                const NocturneKicker('Zorluk'),
                const SizedBox(height: 12),
                IgnorePointer(
                  ignoring: !rc.isHost,
                  child: Opacity(
                    opacity: rc.isHost ? 1 : 0.6,
                    child: NocturneSegmentedControl<Difficulty>(
                      options: const [(Difficulty.light, 'Light'), (Difficulty.hard, 'Hard')],
                      selected: room.difficulty,
                      onChanged: (d) => rc.setDifficulty(d),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  room.difficulty == Difficulty.hard
                      ? 'İtiraflar sertleşir, pas hakkı yoktur.'
                      : 'Herkesin oynayabileceği yumuşak sorular.',
                  style: const TextStyle(fontSize: 14, color: NocturneColors.neutral500),
                ),
                const SizedBox(height: 28),
                const NocturneKicker('Oyun'),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(NocturneRadius.lg),
                  child: Column(
                    children: [
                      NocturneToggleRow(
                        label: 'Titreşim',
                        value: local.vibration,
                        onChanged: local.setVibration,
                      ),
                      NocturneToggleRow(
                        label: 'Shot sayacı',
                        value: local.shotCounterVisible,
                        onChanged: local.setShotCounterVisible,
                      ),
                      NocturneToggleRow(
                        label: 'Ekranı açık tut',
                        value: local.keepScreenOn,
                        onChanged: local.setKeepScreenOn,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const NocturneKicker('Oda'),
                const SizedBox(height: 12),
                NocturneCard(
                  background: NocturneColors.surface3,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room.code, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              '$connectedCount oyuncu bağlı',
                              style: const TextStyle(fontSize: 13, color: NocturneColors.neutral500),
                            ),
                          ],
                        ),
                      ),
                      if (rc.isHost)
                        NocturneChipButton(
                          label: 'Kapat',
                          onPressed: () => rc.endNight(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Center(
                  child: Text(
                    'Sorumlu iç. 18+ · v1.0',
                    style: TextStyle(fontSize: 13, color: NocturneColors.neutral600),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

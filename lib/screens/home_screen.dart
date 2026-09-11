import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/content.dart';
import '../data/room_controller.dart';
import '../data/room_models.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';
import 'settings_screen.dart';

/// Ana ekran — mode select. Only the host may pick a mode (enforced by the
/// RTDB rules too); everyone's screen switches together when `room.mode`
/// changes, since RootScreen re-routes on every room update.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    final room = rc.room!;
    final connectedCount = room.players.values.where((p) => p.connected).length;
    final neverCount = room.difficulty == Difficulty.hard
        ? neverHaveIEverHard.length
        : neverHaveIEverLight.length;

    final modes = <(GameMode, String, String, bool)>[
      (GameMode.kings, 'Kral Bardağı', '${kingsCupRules.length * 4} kart, ${kingsCupRules.length} kural, tek bardak', true),
      (GameMode.never, 'Hiç Yapmadım', '$neverCount itiraf', false),
      (GameMode.most, 'Kim Daha Çok', 'Oy ver, en çok oy alan içer', false),
      (GameMode.wheel, 'Çark Çevir', '${wheelSegments.length} dilim, pazarlık yok', false),
    ];

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
                  padding: const EdgeInsets.fromLTRB(NocturneSpace.side, 12, NocturneSpace.side, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bu gece\nne oynuyoruz?',
                              style: TextStyle(
                                fontSize: 40,
                                height: 1.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$connectedCount oyuncu hazır · Oda ${room.code}',
                              style: const TextStyle(fontSize: 15, color: NocturneColors.neutral500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                        icon: const Icon(Icons.settings_outlined, color: NocturneColors.neutral400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: NocturneSpace.side),
                    children: [
                      for (final (mode, title, subtitle, emphasized) in modes) ...[
                        _ModeCard(
                          title: title,
                          subtitle: subtitle,
                          emphasized: emphasized,
                          enabled: rc.isHost,
                          onTap: () => rc.setMode(mode),
                        ),
                        const SizedBox(height: NocturneSpace.cardGap),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NocturneSpace.side,
                    0,
                    NocturneSpace.side,
                    NocturneSpace.bottomSafe,
                  ),
                  child: NocturneCard(
                    background: NocturneColors.surface3,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: link));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Oda linki kopyalandı')),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: NocturneColors.accent900,
                            borderRadius: BorderRadius.circular(NocturneRadius.md),
                          ),
                          child: const Text('+', style: TextStyle(fontSize: 18, color: NocturneColors.accent300)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Arkadaşlarını çağır', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              SizedBox(height: 2),
                              Text(
                                'Oda linkini paylaş, herkes kendi telefonundan',
                                style: TextStyle(fontSize: 13, color: NocturneColors.neutral500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool emphasized;
  final bool enabled;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.emphasized,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: NocturneCard(
        background: emphasized ? NocturneColors.surface : NocturneColors.surface2,
        borderColor: emphasized ? NocturneColors.accent : NocturneColors.border,
        padding: EdgeInsets.all(emphasized ? 24 : 22),
        onTap: enabled ? onTap : null,
        child: emphasized
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: NocturneColors.neutral400)),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: const TextStyle(fontSize: 14, color: NocturneColors.neutral500)),
                      ],
                    ),
                  ),
                  const Text('→', style: TextStyle(fontSize: 20, color: NocturneColors.accent400)),
                ],
              ),
      ),
    );
  }
}

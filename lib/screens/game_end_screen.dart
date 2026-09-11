import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/room_controller.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';

/// Oyun sonu — shown once the host ends the night from Ayarlar. Drops the
/// brief's "en çok pas geçen / en uzun kural" footnote since nothing else in
/// the app tracks passes or house rules; keeps the ranked shot tally, which
/// is real data.
class GameEndScreen extends StatelessWidget {
  const GameEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    final room = rc.room!;
    final ranked = room.sortedByShotsDesc;
    final winner = ranked.isNotEmpty ? ranked.first : null;
    final rest = ranked.skip(1).toList();

    final elapsed = (room.startedAt != null && room.endedAt != null)
        ? Duration(milliseconds: room.endedAt! - room.startedAt!)
        : null;
    final elapsedLabel = elapsed == null
        ? ''
        : '${elapsed.inHours}s ${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}dk';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(NocturneSpace.side, 20, NocturneSpace.side, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NocturneKicker(elapsedLabel.isEmpty ? 'GECE BİTTİ' : 'GECE BİTTİ · $elapsedLabel'),
                      const SizedBox(height: 8),
                      const Text(
                        'Hasar\nraporu',
                        style: TextStyle(fontSize: 42, height: 1.0, fontWeight: FontWeight.w600, letterSpacing: -0.6),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: NocturneSpace.side),
                    children: [
                      const SizedBox(height: 22),
                      if (winner != null)
                        NocturneCard(
                          background: NocturneColors.surface,
                          borderColor: NocturneColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GECENİN ŞAMPİYONU',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: NocturneColors.neutral400,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                winner.name,
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600, letterSpacing: -0.4),
                              ),
                              const SizedBox(height: 4),
                              Text('${winner.shots} shot', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      const SizedBox(height: NocturneSpace.cardGap),
                      for (var i = 0; i < rest.length; i++) ...[
                        NocturneCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                child: Text('${i + 2}', style: const TextStyle(fontSize: 14, color: NocturneColors.neutral500)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(rest[i].name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              Text('${rest[i].shots}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: NocturneSecondaryButton(
                          label: 'Paylaş',
                          onPressed: () async {
                            final text = winner == null
                                ? 'Shot Oyunu gecesi bitti!'
                                : 'Shot Oyunu gecesi bitti! Şampiyon: ${winner.name} (${winner.shots} shot) 🏆';
                            await Clipboard.setData(ClipboardData(text: text));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sonuç panoya kopyalandı')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: rc.isHost
                            ? NocturnePrimaryButton(label: 'Tekrar oyna', onPressed: () => rc.playAgain())
                            : const NocturnePrimaryButton(label: 'Tekrar oyna', onPressed: null),
                      ),
                    ],
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

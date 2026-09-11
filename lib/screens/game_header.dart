import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/room_controller.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';

/// Shared top row for all four game screens: back-to-menu (host only, since
/// only the host may clear `mode` per the RTDB rules), a kicker title, and a
/// trailing status string ("38 kart kaldı", "Soru 7", …).
class GameHeader extends StatelessWidget {
  final String title;
  final String trailing;
  const GameHeader({super.key, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, NocturneSpace.side, 12),
      child: Row(
        children: [
          if (rc.isHost)
            IconButton(
              onPressed: () => rc.clearMode(),
              icon: const Icon(Icons.arrow_back, color: NocturneColors.neutral400),
            )
          else
            const SizedBox(width: 12),
          Expanded(child: NocturneKicker(title)),
          Text(
            trailing,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: NocturneColors.neutral500),
          ),
        ],
      ),
    );
  }
}

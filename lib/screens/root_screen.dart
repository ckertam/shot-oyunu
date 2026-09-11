import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/room_controller.dart';
import '../data/room_models.dart';
import '../theme/nocturne_theme.dart';
import 'game_end_screen.dart';
import 'home_screen.dart';
import 'kings_cup_screen.dart';
import 'most_likely_screen.dart';
import 'never_have_i_screen.dart';
import 'player_setup_screen.dart';
import 'start_screen.dart';
import 'wheel_screen.dart';

/// Routes purely off shared room state — every client re-renders into the
/// same screen when `room.status`/`room.mode` changes, since that's exactly
/// what the brief's "everyone sees the same card" invariant requires.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();

    if (rc.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: NocturneColors.accent)));
    }
    if (rc.room == null || rc.code == null) {
      return const StartScreen();
    }

    final room = rc.room!;
    switch (room.status) {
      case RoomStatus.lobby:
        return const PlayerSetupScreen();
      case RoomStatus.ended:
        return const GameEndScreen();
      case RoomStatus.playing:
        if (room.mode == null) return const HomeScreen();
        switch (room.mode!) {
          case GameMode.kings:
            return const KingsCupScreen();
          case GameMode.never:
            return const NeverHaveIScreen();
          case GameMode.most:
            return const MostLikelyScreen();
          case GameMode.wheel:
            return const WheelScreen();
        }
    }
  }
}

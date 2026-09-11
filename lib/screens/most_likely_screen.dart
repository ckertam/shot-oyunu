import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/content.dart';
import '../data/room_controller.dart';
import '../data/room_models.dart';
import '../theme/nocturne_theme.dart';
import '../theme/nocturne_widgets.dart';
import 'game_header.dart';

/// Kim Daha Çok — a live vote, not the brief's physical "point your finger"
/// gesture: each player taps who they think fits, bars update as votes
/// arrive (no hidden-until-all-voted gate), "Sonraki soru" resets votes and
/// advances the shared index.
class MostLikelyScreen extends StatefulWidget {
  const MostLikelyScreen({super.key});

  @override
  State<MostLikelyScreen> createState() => _MostLikelyScreenState();
}

class _MostLikelyScreenState extends State<MostLikelyScreen> {
  bool _busy = false;

  Future<void> _next(int deckSize) async {
    setState(() => _busy = true);
    try {
      await context.read<RoomController>().advanceMost(deckSize: deckSize);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RoomController>();
    final room = rc.room!;
    final deck = mostLikelyTo;
    final most = room.most;
    final index = most?.index ?? -1;
    final order = most?.order ?? const <int>[];
    final question = (index >= 0 && index < order.length) ? deck[order[index] % deck.length] : null;
    final votes = most?.votes ?? const <String, String>{};
    final players = room.players.values.toList()..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    final tally = <String, int>{for (final p in players) p.uid: 0};
    for (final votedFor in votes.values) {
      if (tally.containsKey(votedFor)) tally[votedFor] = tally[votedFor]! + 1;
    }
    final maxVotes = tally.values.isEmpty ? 0 : tally.values.reduce((a, b) => a > b ? a : b);
    final leaderUid = maxVotes == 0
        ? null
        : tally.entries.firstWhere((e) => e.value == maxVotes).key;
    final myVote = rc.myUid != null ? votes[rc.myUid] : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                GameHeader(
                  title: 'Kim Daha Çok',
                  trailing: question == null ? '' : 'Soru ${index + 1}',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: NocturneSpace.side),
                    children: [
                      NocturneCard(
                        background: NocturneColors.accent900,
                        borderColor: NocturneColors.accent700,
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question ?? 'Başlamak için "Sonraki soru"ya dokun',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, height: 1.2),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Kim olduğunu düşünüyorsan ona dokun.',
                              style: TextStyle(fontSize: 14, color: NocturneColors.neutral300),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Oylar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NocturneColors.neutral500)),
                      const SizedBox(height: 12),
                      for (final p in players) ...[
                        _VoteRow(
                          player: p,
                          votes: tally[p.uid] ?? 0,
                          maxVotes: maxVotes,
                          isLeader: p.uid == leaderUid && maxVotes > 0,
                          isMyVote: p.uid == myVote,
                          onTap: () => rc.castVote(p.uid),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (leaderUid != null) ...[
                        const SizedBox(height: 8),
                        NocturneCard(
                          background: NocturneColors.surface2,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Row(
                            children: [
                              NocturneAvatar(name: players.firstWhere((p) => p.uid == leaderUid).name, accented: true),
                              const SizedBox(width: 12),
                              Text.rich(
                                TextSpan(
                                  style: const TextStyle(fontSize: 15, color: NocturneColors.text),
                                  children: [
                                    TextSpan(
                                      text: players.firstWhere((p) => p.uid == leaderUid).name,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    TextSpan(text: ' $maxVotes shot içiyor'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                    label: 'Sonraki soru',
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

class _VoteRow extends StatelessWidget {
  final Player player;
  final int votes;
  final int maxVotes;
  final bool isLeader;
  final bool isMyVote;
  final VoidCallback onTap;

  const _VoteRow({
    required this.player,
    required this.votes,
    required this.maxVotes,
    required this.isLeader,
    required this.isMyVote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxVotes == 0 ? 0.0 : votes / maxVotes;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NocturneRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isMyVote)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.check_circle, size: 14, color: NocturneColors.accent400),
                  ),
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '$votes',
                  style: TextStyle(color: isLeader ? NocturneColors.accent400 : NocturneColors.neutral500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 10,
                backgroundColor: NocturneColors.border2,
                valueColor: AlwaysStoppedAnimation(
                  isLeader ? NocturneColors.accent : NocturneColors.border3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

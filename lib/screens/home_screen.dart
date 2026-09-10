import 'package:flutter/material.dart';

import '../data/content.dart';
import 'kings_cup_screen.dart';
import 'statement_cycle_screen.dart';
import 'wheel_screen.dart';

class _ModeInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  const _ModeInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modes = <_ModeInfo>[
      _ModeInfo(
        title: 'Kral Bardağı',
        subtitle: 'Kart çek, kurala uy',
        icon: Icons.style_rounded,
        color: const Color(0xFFFFD166),
        builder: (_) => const KingsCupScreen(),
      ),
      _ModeInfo(
        title: 'Hiç Yapmadım',
        subtitle: 'Yapan içer',
        icon: Icons.visibility_off_rounded,
        color: const Color(0xFF06D6A0),
        builder: (_) => StatementCycleScreen(
          title: 'Hiç Yapmadım',
          accentColor: const Color(0xFF06D6A0),
          statements: neverHaveIEver,
        ),
      ),
      _ModeInfo(
        title: 'Kim Daha Çok',
        subtitle: 'En çok oy alan içer',
        icon: Icons.groups_rounded,
        color: const Color(0xFFEF476F),
        builder: (_) => StatementCycleScreen(
          title: 'Kim Daha Çok',
          accentColor: const Color(0xFFEF476F),
          statements: mostLikelyTo,
        ),
      ),
      _ModeInfo(
        title: 'Çark Çevir',
        subtitle: 'Şansına ne çıkarsa',
        icon: Icons.donut_large_rounded,
        color: const Color(0xFFFB5607),
        builder: (_) => const WheelScreen(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text('🍻', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    'Shot Oyunu',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bir mod seç, kadehleri hazırla.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      itemCount: modes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.95,
                          ),
                      itemBuilder: (context, index) {
                        final mode = modes[index];
                        return _ModeCard(
                          mode: mode,
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: mode.builder));
                          },
                        );
                      },
                    ),
                  ),
                  Text(
                    'Sorumlu iç, kimseyi zorlama. 18+',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final _ModeInfo mode;
  final VoidCallback onTap;

  const _ModeCard({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: mode.color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: mode.color.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(mode.icon, color: mode.color, size: 34),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../game/presentation/pages/level_select_page.dart';
import '../../../simulation/presentation/pages/simulation_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.eco, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'EcoBalance',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rabbits eat grass, foxes eat rabbits.\n'
                  'Can you keep the balance?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
                const SizedBox(height: 40),
                _MenuButton(
                  icon: Icons.flag_rounded,
                  title: 'Play levels',
                  subtitle: 'Keep both species alive, earn stars',
                  isMain: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LevelSelectPage()),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.science_outlined,
                  title: 'Sandbox',
                  subtitle: 'Change the rules and watch evolution',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SimulationPage()),
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

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isMain;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isMain ? Colors.white : const Color(0xFF1F2A22);
    final muted = isMain ? Colors.white70 : AppColors.textMuted;

    return Material(
      color: isMain ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isMain
            ? BorderSide.none
            : const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 32, color: foreground),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: muted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

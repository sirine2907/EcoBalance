import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/level_progress.dart';
import '../../domain/levels.dart';
import '../cubit/levels_cubit.dart';
import '../widgets/level_card.dart';
import 'game_page.dart';

class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  @override
  void initState() {
    super.initState();
    context.read<LevelsCubit>().load();
  }

  Future<void> _openLevel(Level level) async {
    final cubit = context.read<LevelsCubit>();

    if (!cubit.isUnlocked(level.number)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Clear level ${level.number - 1} to unlock it.'),
        ));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GamePage(level: level)),
    );
    // stars may have changed
    cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LevelsCubit, Map<int, LevelProgress>>(
      builder: (context, progress) {
        final cubit = context.read<LevelsCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Levels'),
            actions: [
              const Icon(Icons.star_rounded, color: AppColors.star),
              const SizedBox(width: 4),
              Text(
                '${cubit.totalStars} / ${levels.length * 3}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 24),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: levels.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return LevelCard(
                    level: level,
                    progress: progress[level.number],
                    isLocked: !cubit.isUnlocked(level.number),
                    onTap: () => _openLevel(level),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

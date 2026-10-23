import 'package:bloc_test/bloc_test.dart';
import 'package:ecobalance/features/game/domain/entities/level_progress.dart';
import 'package:ecobalance/features/game/domain/usecases/get_progress.dart';
import 'package:ecobalance/features/game/presentation/cubit/levels_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProgress extends Mock implements GetProgress {}

void main() {
  late MockGetProgress getProgress;

  const progress = {
    1: LevelProgress(stars: 3, bestScore: 2000),
    2: LevelProgress(stars: 1, bestScore: 1100),
  };

  setUp(() {
    getProgress = MockGetProgress();
    when(() => getProgress()).thenAnswer((_) async => progress);
  });

  blocTest<LevelsCubit, Map<int, LevelProgress>>(
    'load emits the saved progress',
    build: () => LevelsCubit(getProgress: getProgress),
    act: (cubit) => cubit.load(),
    expect: () => [progress],
  );

  test('only level 1 is open at the start', () {
    final cubit = LevelsCubit(getProgress: getProgress);

    expect(cubit.isUnlocked(1), isTrue);
    expect(cubit.isUnlocked(2), isFalse);
  });

  test('clearing a level opens the next one', () async {
    final cubit = LevelsCubit(getProgress: getProgress);

    await cubit.load();

    expect(cubit.isUnlocked(2), isTrue);
    expect(cubit.isUnlocked(3), isTrue);
    expect(cubit.isUnlocked(4), isFalse);
    expect(cubit.totalStars, 4);
  });
}

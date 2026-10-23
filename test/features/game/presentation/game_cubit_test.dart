import 'package:bloc_test/bloc_test.dart';
import 'package:ecobalance/features/game/domain/entities/level.dart';
import 'package:ecobalance/features/game/domain/entities/level_progress.dart';
import 'package:ecobalance/features/game/domain/game_rules.dart';
import 'package:ecobalance/features/game/domain/usecases/save_level_result.dart';
import 'package:ecobalance/features/game/presentation/cubit/game_cubit.dart';
import 'package:ecobalance/features/game/presentation/cubit/game_state.dart';
import 'package:ecobalance/features/simulation/domain/entities/simulation_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSaveLevelResult extends Mock implements SaveLevelResult {}

const level = Level(
  number: 2,
  name: 'Test',
  description: 'A test level',
  config: SimulationConfig(),
  durationSeconds: 60,
  seeds: 2,
);

void main() {
  late MockSaveLevelResult saveLevelResult;

  setUpAll(() {
    registerFallbackValue(const LevelProgress(stars: 0, bestScore: 0));
  });

  setUp(() {
    saveLevelResult = MockSaveLevelResult();
    when(() => saveLevelResult(any(), any())).thenAnswer((_) async {});
  });

  GameCubit build() =>
      GameCubit(level: level, saveLevelResult: saveLevelResult);

  test('starts playing with all seeds and the full time', () {
    final cubit = build();

    expect(cubit.state.status, GameStatus.playing);
    expect(cubit.state.seedsLeft, 2);
    expect(cubit.state.secondsLeft, 60);
  });

  test('useSeed takes one seed until there are none left', () {
    final cubit = build();

    expect(cubit.useSeed(), isTrue);
    expect(cubit.useSeed(), isTrue);
    expect(cubit.useSeed(), isFalse);
    expect(cubit.state.seedsLeft, 0);
  });

  blocTest<GameCubit, GameState>(
    'counts down the time',
    build: build,
    act: (cubit) => cubit.worldChanged(second: 15, rabbits: 20, foxes: 3),
    expect: () => [
      isA<GameState>().having((s) => s.secondsLeft, 'secondsLeft', 45),
    ],
  );

  blocTest<GameCubit, GameState>(
    'loses when the rabbits die out',
    build: build,
    act: (cubit) => cubit.worldChanged(second: 20, rabbits: 0, foxes: 3),
    expect: () => [
      isA<GameState>()
          .having((s) => s.status, 'status', GameStatus.lost)
          .having((s) => s.rabbitsDied, 'rabbitsDied', true),
    ],
    verify: (_) => verifyNever(() => saveLevelResult(any(), any())),
  );

  blocTest<GameCubit, GameState>(
    'wins at the end of the time and saves the result',
    build: build,
    act: (cubit) => cubit.worldChanged(second: 60, rabbits: 40, foxes: 6),
    expect: () => [
      isA<GameState>()
          .having((s) => s.status, 'status', GameStatus.won)
          .having((s) => s.stars, 'stars', 3)
          .having((s) => s.score, 'score', 1000 + 200 + 200 + 120),
    ],
    verify: (_) => verify(() => saveLevelResult(
          2,
          const LevelProgress(stars: 3, bestScore: 1520),
        )).called(1),
  );

  blocTest<GameCubit, GameState>(
    'ignores the world after the game is over',
    build: build,
    act: (cubit) async {
      await cubit.worldChanged(second: 10, rabbits: 0, foxes: 1);
      await cubit.worldChanged(second: 60, rabbits: 50, foxes: 5);
      cubit.useSeed();
    },
    expect: () => [
      isA<GameState>().having((s) => s.status, 'status', GameStatus.lost),
    ],
  );
}

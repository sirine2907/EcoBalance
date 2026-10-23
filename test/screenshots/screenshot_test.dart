// Renders the app into docs/screenshots for the README.
// Run: flutter test test/screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'dart:convert';
import 'dart:math';

import 'package:ecobalance/app.dart';
import 'package:ecobalance/features/game/data/repositories/progress_repository_impl.dart';
import 'package:ecobalance/features/game/domain/levels.dart';
import 'package:ecobalance/features/game/presentation/pages/game_page.dart';
import 'package:ecobalance/features/simulation/domain/entities/simulation_config.dart';
import 'package:ecobalance/features/simulation/presentation/bloc/simulation_bloc.dart';
import 'package:ecobalance/features/simulation/presentation/widgets/world_canvas.dart';
import 'package:ecobalance/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Without loading real fonts the test renders every letter as a box.
Future<void> loadFonts() async {
  final inter = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait([inter.load(), icons.load()]);
}

// the player already cleared the first two levels
final savedProgress = jsonEncode({
  '1': {'stars': 3, 'bestScore': 2540},
  '2': {'stars': 2, 'bestScore': 1885},
});

Future<void> openApp(
  WidgetTester tester, {
  Size size = const Size(1440, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    ProgressRepositoryImpl.progressKey: savedProgress,
  });
  await di.init(prefs: await SharedPreferences.getInstance());

  await tester.pumpWidget(
    EcoBalanceApp(config: const SimulationConfig(), random: Random(3)),
  );
  await settle(tester);
}

// shared preferences answers outside the fake clock, so give it real time
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
  }
}

Future<void> openSandbox(WidgetTester tester) async {
  await tester.tap(find.text('Sandbox'));
  await tester.pumpAndSettle();
}

Future<void> openLevel(WidgetTester tester, int number) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.push(MaterialPageRoute(
    builder: (_) => GamePage(level: levels[number - 1], random: Random(3)),
  ));
  await tester.pumpAndSettle();
}

/// Runs the world for [seconds] without the timer.
Future<void> runFor(WidgetTester tester, int seconds) async {
  final bloc =
      tester.element(find.byType(WorldCanvas)).read<SimulationBloc>();
  for (var i = 0; i < seconds * 30; i++) {
    bloc.add(const SimulationTicked());
  }
  await settle(tester);
}

Future<void> takeScreenshot(String name) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/screenshots/$name.png'),
  );
}

final windows = TargetPlatformVariant.only(TargetPlatform.windows);

void main() {
  setUpAll(loadFonts);

  testWidgets('home', (tester) async {
    await openApp(tester);
    await takeScreenshot('01_home');
  }, variant: windows);

  testWidgets('levels', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Play levels'));
    await settle(tester);
    await takeScreenshot('02_levels');
  }, variant: windows);

  testWidgets('playing a level', (tester) async {
    await openApp(tester);
    await openLevel(tester, 2);
    await runFor(tester, 25);
    // plant two patches of grass
    await tester.tapAt(tester.getTopLeft(find.byType(WorldCanvas)) +
        const Offset(300, 200));
    await tester.tapAt(tester.getTopLeft(find.byType(WorldCanvas)) +
        const Offset(700, 450));
    await runFor(tester, 5);
    await takeScreenshot('03_game');
  }, variant: windows);

  testWidgets('level complete', (tester) async {
    await openApp(tester);
    await openLevel(tester, 1);
    await runFor(tester, 60);
    await takeScreenshot('04_level_complete');
  }, variant: windows);

  testWidgets('sandbox', (tester) async {
    await openApp(tester);
    await openSandbox(tester);
    await runFor(tester, 45);
    await takeScreenshot('05_sandbox');
  }, variant: windows);

  testWidgets('sense radius', (tester) async {
    await openApp(tester);
    await openSandbox(tester);
    await runFor(tester, 20);
    await tester.tap(find.text('Sense radius'));
    await tester.pumpAndSettle();
    await takeScreenshot('06_sense_radius');
  }, variant: windows);

  testWidgets('statistics', (tester) async {
    await openApp(tester);
    await openSandbox(tester);
    await runFor(tester, 360);
    await tester.tap(find.byTooltip('Statistics'));
    await tester.pumpAndSettle();
    await takeScreenshot('07_statistics');
  }, variant: windows);

  testWidgets('settings', (tester) async {
    await openApp(tester);
    await openSandbox(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await takeScreenshot('08_settings');
  }, variant: windows);

  testWidgets('phone layout', (tester) async {
    await openApp(tester, size: const Size(430, 932));
    await openLevel(tester, 1);
    await runFor(tester, 20);
    await takeScreenshot('09_phone');
  }, variant: windows);
}

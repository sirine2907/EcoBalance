// Renders the app into docs/screenshots for the README.
// Run: flutter test test/screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'dart:math';

import 'package:ecobalance/app.dart';
import 'package:ecobalance/features/simulation/domain/entities/simulation_config.dart';
import 'package:ecobalance/features/simulation/presentation/bloc/simulation_bloc.dart';
import 'package:ecobalance/features/simulation/presentation/pages/simulation_page.dart';
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

Future<void> openApp(
  WidgetTester tester, {
  Size size = const Size(1440, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  await di.init(prefs: await SharedPreferences.getInstance());

  await tester.pumpWidget(
    EcoBalanceApp(config: const SimulationConfig(), random: Random(3)),
  );
  await tester.pumpAndSettle();
}

/// Runs the world for [seconds] without the timer.
Future<void> runFor(WidgetTester tester, int seconds) async {
  final bloc = tester.element(find.byType(SimulationPage)).read<SimulationBloc>();
  for (var i = 0; i < seconds * 30; i++) {
    bloc.add(const SimulationTicked());
  }
  await tester.pumpAndSettle();
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

  testWidgets('simulation', (tester) async {
    await openApp(tester);
    await runFor(tester, 45);
    await takeScreenshot('01_simulation');
  }, variant: windows);

  testWidgets('sense radius', (tester) async {
    await openApp(tester);
    await runFor(tester, 20);
    await tester.tap(find.text('Sense radius'));
    await tester.pumpAndSettle();
    await takeScreenshot('02_sense_radius');
  }, variant: windows);

  testWidgets('statistics', (tester) async {
    await openApp(tester);
    await runFor(tester, 360);
    await tester.tap(find.byTooltip('Statistics'));
    await tester.pumpAndSettle();
    await takeScreenshot('03_statistics');
  }, variant: windows);

  testWidgets('settings', (tester) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await takeScreenshot('04_settings');
  }, variant: windows);

  testWidgets('phone layout', (tester) async {
    await openApp(tester, size: const Size(430, 932));
    await runFor(tester, 30);
    await takeScreenshot('05_phone');
  }, variant: windows);
}

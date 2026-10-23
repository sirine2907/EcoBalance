import 'dart:math';

import 'package:ecobalance/features/simulation/domain/entities/dna.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dna = Dna(speed: 2, senseRadius: 50, size: 1);

  test('mutation rate 0 keeps the genes the same', () {
    final child = dna.mutate(Random(1), 0);

    expect(child, dna);
  });

  test('mutation changes the genes a little', () {
    final child = dna.mutate(Random(1), 0.1);

    expect(child, isNot(dna));
    // 10% of the speed range is 0.35
    expect((child.speed - dna.speed).abs(), lessThanOrEqualTo(0.35));
  });

  test('genes never go outside their range', () {
    final random = Random(7);
    var current = const Dna(
      speed: Dna.maxSpeed,
      senseRadius: Dna.minSense,
      size: Dna.maxSize,
    );

    for (var i = 0; i < 500; i++) {
      current = current.mutate(random, 1);

      expect(current.speed, inInclusiveRange(Dna.minSpeed, Dna.maxSpeed));
      expect(current.senseRadius, inInclusiveRange(Dna.minSense, Dna.maxSense));
      expect(current.size, inInclusiveRange(Dna.minSize, Dna.maxSize));
    }
  });

  test('speed limit caps the speed', () {
    final random = Random(3);
    var current = const Dna(speed: 2.5, senseRadius: 50, size: 1);

    for (var i = 0; i < 200; i++) {
      current = current.mutate(random, 0.5, speedLimit: 2.5);
      expect(current.speed, lessThanOrEqualTo(2.5));
    }
  });
}

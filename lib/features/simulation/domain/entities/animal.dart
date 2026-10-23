import 'dna.dart';

enum Species { rabbit, fox }

/// A rabbit or a fox living in the world.
/// It is mutable because the engine moves it every tick.
class Animal {
  final int id;
  final Species species;
  final Dna dna;

  double x;
  double y;
  double energy;

  /// Direction the animal is walking, in radians.
  double heading;
  int age = 0;
  bool isDead = false;

  /// Ticks left before a fox hunts again after eating.
  int restTicks = 0;

  Animal({
    required this.id,
    required this.species,
    required this.dna,
    required this.x,
    required this.y,
    required this.energy,
    this.heading = 0,
  });

  bool get isRabbit => species == Species.rabbit;

  bool get isFox => species == Species.fox;

  /// Bigger animals can store more energy.
  double get maxEnergy => 100 * dna.size;

  double get radius => (isRabbit ? 5 : 7) * dna.size;
}

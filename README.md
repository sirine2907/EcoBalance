# EcoBalance

A small ecosystem where rabbits and foxes evolve while you watch.

Grass grows on a grid, rabbits eat the grass and foxes eat the rabbits. Every animal has DNA (speed, sense radius and size), and babies get a slightly mutated copy of their parent's genes. Leave it running for a few minutes and you can see the classic predator-prey cycles, and the two species slowly adapting to each other.

Built with **Flutter** for **desktop and mobile**, using **BLoC** and **clean architecture**.

## Screenshots

| Simulation | Sense radius |
|:---:|:---:|
| <img src="docs/screenshots/01_simulation.png" width="420" /> | <img src="docs/screenshots/02_sense_radius.png" width="420" /> |
| **Statistics** | **Settings** |
| <img src="docs/screenshots/03_statistics.png" width="420" /> | <img src="docs/screenshots/04_settings.png" width="420" /> |

<p align="center">
  <img src="docs/screenshots/05_phone.png" width="230" /><br/>
  <b>Phone layout</b>
</p>

## Why I built it

I've always liked the evolution simulator videos where little creatures get faster or smarter over hundreds of generations. I wanted to build one myself, but with two species that push each other instead of one species against the food. It also turned out to be a good exercise in keeping the "game logic" in plain Dart, so it can be tested without any widgets.

## Features

- **Live world** drawn with a `CustomPainter`: grass tiles, rabbits and foxes facing the way they walk.
- **Play / pause / reset** and **speed control** (1x, 2x, 4x).
- **Tap the world to plant grass**, handy when the rabbits are about to starve.
- **Sense radius** toggle to see how far every animal can see.
- **Live stats panel**: population of each species, grass coverage, time, and the average genes.
- **Statistics screen** with charts for rabbits, foxes, grass and average speed over time.
- **Export to CSV** to play with the numbers in Excel or Python.
- **Settings** for starting animals, grass growth, mutation rate and energy costs, saved between launches.
- Responsive layout: side panel on desktop, single column on phones.

## How the simulation works

The world is 800 x 500 units with a 40 x 25 grass grid. It runs at 30 ticks per second, and every tick each animal does this:

1. **Look around.** A rabbit looks for foxes first and runs away. If there's no danger, it walks to the closest grass it can see. A fox looks for the closest rabbit and chases it. If nothing is in sight, they wander.
2. **Move** at the speed in its DNA. Foxes sprint a little faster (x1.3) while they chase.
3. **Eat.** A rabbit standing on grass eats it (+20 energy). A fox touching a rabbit eats it (+55 x rabbit size), then rests for 3 seconds.
4. **Burn energy.** The cost per tick is `0.025 x speed² + 0.05 x size + 0.0015 x sense`. Being fast is expensive.
5. **Have a baby** when its energy is above 80% of its max (max = 100 x size). The parent gives half of its energy to the baby, and the baby's genes are the parent's genes plus a small random change (the mutation rate).
6. **Die** when its energy hits 0 or it gets too old (60 s for rabbits, 90 s for foxes).

Bare cells grow grass back with a small chance every tick.

### The predator-prey cycle

1. Lots of rabbits means foxes eat well and have many babies.
2. Too many foxes eat most of the rabbits.
3. With few rabbits left, foxes starve and their number drops.
4. With fewer foxes around, the rabbits come back, and the loop starts again.

You can see it in the statistics screen: the fox curve follows the rabbit curve with a delay.

### Evolution

No gene is "good" on its own, because everything has a cost. Fast rabbits escape more often but need more grass. A big sense radius finds food sooner but burns energy all the time. Over a few minutes, rabbits usually get faster to escape the foxes, and the foxes follow. You can watch it in the "Average speed" chart.

Some balancing rules keep the world from collapsing too quickly:

- Rabbits notice a fox only when it's close (60% of their sense radius).
- Rabbits can't go faster than 2.5, foxes can go up to 4.
- Foxes become adults later (10 s) than rabbits (2 s).
- There's a population cap (300 rabbits, 40 foxes) so the app stays smooth.

It can still collapse, and that's part of the fun. If the rabbits are dying out, plant some grass. If the foxes are gone, press Reset.

## Architecture

The app is split by feature, and every feature follows the same layers.

```
lib/
├── main.dart                     # loads settings, then runs the app
├── app.dart                      # MaterialApp + top level blocs
├── injection_container.dart      # get_it setup
├── core/
│   └── theme/                    # colors and app theme
└── features/
    ├── simulation/
    │   ├── domain/
    │   │   ├── entities/         # Animal, Dna, Grass, SimulationConfig, StatsPoint
    │   │   └── engine/           # SimulationEngine (pure Dart)
    │   └── presentation/         # SimulationBloc, page, canvas, painter, controls, stats panel
    ├── settings/
    │   ├── domain/               # SettingsRepository, GetConfig, SaveConfig
    │   ├── data/                 # json model + shared_preferences implementation
    │   └── presentation/         # SettingsCubit, settings page
    └── stats/
        ├── domain/               # StatsRepository, ExportStatsCsv
        ├── data/                 # csv builder + file implementation (path_provider)
        └── presentation/         # StatsCubit, stats page, line chart card
```

- **Domain** is plain Dart. The `SimulationEngine` has no Flutter imports and takes an optional `Random`, so tests can use a fixed seed and always get the same world.
- **Data** implements the repositories: settings are saved as JSON in `shared_preferences`, and stats are written as a CSV file in the documents folder.
- **Presentation** has the blocs and the widgets. Widgets only send events and draw the state.

### How the BLoC flow works

```
Timer (every 33 ms) --SimulationTicked--> SimulationBloc --step() x speed--> SimulationEngine
                                                |
WorldCanvas / LiveStatsPanel  <--SimulationState(animals, grass, history, frame)
```

The animals are mutable objects (the engine moves them in place), so the state carries a `frame` counter. It changes on every update, which tells `BlocBuilder` and the painter that it's time to redraw.

When settings are saved, `SettingsCubit` emits the new config, and the simulation page forwards it to the bloc as `SimulationConfigChanged`, which starts a new world.

## Tech stack

| What | Package |
|---|---|
| State management | [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable) |
| Dependency injection | [get_it](https://pub.dev/packages/get_it) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |
| Storage | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| CSV export | [path_provider](https://pub.dev/packages/path_provider) |
| Tests | [bloc_test](https://pub.dev/packages/bloc_test), [mocktail](https://pub.dev/packages/mocktail) |
| Font | Inter (bundled in `assets/fonts`) |

## Run it

You need Flutter 3.38 or newer.

```bash
git clone https://github.com/sirine2907/EcoBalance.git
cd EcoBalance
flutter pub get

flutter run -d windows     # or macos / linux
flutter run -d android     # phone or emulator
```

To build a release for Windows:

```bash
flutter build windows --release
```

## Tests

```bash
flutter test
```

- **Engine tests** with a fixed seed: eating grass, foxes catching rabbits, running away, babies, death by hunger and old age, planting grass, and that the same seed always gives the same world.
- **DNA tests**: mutation stays inside the gene ranges and respects the rabbit speed limit.
- **Bloc tests** (`bloc_test`) for `SimulationBloc`, `SettingsCubit` and `StatsCubit`.
- **Data tests** for the JSON model, the settings repository and the CSV export.

The screenshots above are golden tests. They run the world with a fixed seed and render each screen. To update them:

```bash
flutter test test/screenshots --update-goldens
```

## License

MIT, see [LICENSE](LICENSE).

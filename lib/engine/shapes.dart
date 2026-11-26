/// Polyomino shape library, 90-degree CW rotation, and deterministic seeded RNG
/// used for reproducible Daily Prism Challenges and 24 Quest Stage layouts.
library;

import 'models.dart';

/// Deterministic PRNG (Mulberry32) so identical seeds produce identical boards
/// and piece decks across iOS, Android, and desktop verification.
class SeededRandom {
  SeededRandom(int seed)
    : _state = (seed & 0xFFFFFFFF) == 0 ? 0x6D2B79F5 : (seed & 0xFFFFFFFF);

  int _state;

  /// Returns a double in [0.0, 1.0).
  double nextDouble() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = ((t ^ (t >>> 15)) * (t | 1)) & 0xFFFFFFFF;
    t = (t ^ (t + (((t ^ (t >>> 7)) * (t | 61)) & 0xFFFFFFFF))) & 0xFFFFFFFF;
    final out = (t ^ (t >>> 14)) & 0xFFFFFFFF;
    return out / 4294967296.0;
  }

  /// Returns an integer in [0, max).
  int nextInt(int max) {
    if (max <= 1) return 0;
    return (nextDouble() * max).floor().clamp(0, max - 1);
  }

  /// Stable FNV-1a 32-bit string hash for date keys (e.g. '2026-11-26').
  static int hashString(String input) {
    var hash = 0x811C9DC5;
    for (var i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}

/// Weighted polyomino entry.
class WeightedShape {
  const WeightedShape(this.weight, this.cells);

  final int weight;
  final List<GridPoint> cells;
}

/// Balanced modern polyomino catalog tuned for 8x8 tactical flow.
class ShapeLibrary {
  const ShapeLibrary._();

  static const List<WeightedShape> catalog = <WeightedShape>[
    // Singles & lines
    WeightedShape(12, <GridPoint>[GridPoint(0, 0)]),
    WeightedShape(14, <GridPoint>[GridPoint(0, 0), GridPoint(1, 0)]),
    WeightedShape(14, <GridPoint>[GridPoint(0, 0), GridPoint(0, 1)]),
    WeightedShape(12, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
    ]),
    WeightedShape(12, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(0, 1),
      GridPoint(0, 2),
    ]),
    // Small L corners (3)
    WeightedShape(13, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(0, 1),
    ]),
    WeightedShape(13, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(1, 1),
    ]),
    WeightedShape(13, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
    ]),
    WeightedShape(13, <GridPoint>[
      GridPoint(1, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
    ]),
    // 2x2 square
    WeightedShape(16, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
    ]),
    // Lines of 4 & 5
    WeightedShape(9, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(3, 0),
    ]),
    WeightedShape(9, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(0, 1),
      GridPoint(0, 2),
      GridPoint(0, 3),
    ]),
    WeightedShape(5, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(3, 0),
      GridPoint(4, 0),
    ]),
    WeightedShape(5, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(0, 1),
      GridPoint(0, 2),
      GridPoint(0, 3),
      GridPoint(0, 4),
    ]),
    // T-shapes
    WeightedShape(10, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(1, 1),
    ]),
    WeightedShape(10, <GridPoint>[
      GridPoint(1, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
      GridPoint(2, 1),
    ]),
    WeightedShape(9, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(0, 1),
      GridPoint(0, 2),
      GridPoint(1, 1),
    ]),
    WeightedShape(9, <GridPoint>[
      GridPoint(1, 0),
      GridPoint(1, 1),
      GridPoint(1, 2),
      GridPoint(0, 1),
    ]),
    // S / Z shapes
    WeightedShape(8, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(1, 1),
      GridPoint(2, 1),
    ]),
    WeightedShape(8, <GridPoint>[
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
    ]),
    WeightedShape(8, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
      GridPoint(1, 2),
    ]),
    WeightedShape(8, <GridPoint>[
      GridPoint(1, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
      GridPoint(0, 2),
    ]),
    // Big L shapes (4)
    WeightedShape(9, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(0, 1),
      GridPoint(0, 2),
      GridPoint(1, 2),
    ]),
    WeightedShape(9, <GridPoint>[
      GridPoint(1, 0),
      GridPoint(1, 1),
      GridPoint(1, 2),
      GridPoint(0, 2),
    ]),
    WeightedShape(9, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(0, 1),
    ]),
    WeightedShape(9, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(2, 1),
    ]),
    // 3x2 / 2x3 rectangles
    WeightedShape(6, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
      GridPoint(2, 1),
    ]),
    WeightedShape(6, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
      GridPoint(0, 2),
      GridPoint(1, 2),
    ]),
    // Big 3x3 L corner (5) & 3x3 block (9)
    WeightedShape(5, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(0, 1),
      GridPoint(0, 2),
    ]),
    WeightedShape(4, <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(2, 0),
      GridPoint(0, 1),
      GridPoint(1, 1),
      GridPoint(2, 1),
      GridPoint(0, 2),
      GridPoint(1, 2),
      GridPoint(2, 2),
    ]),
  ];

  static final int totalWeight = catalog.fold<int>(
    0,
    (sum, s) => sum + s.weight,
  );

  static List<GridPoint> pickWeighted(SeededRandom rng) {
    var roll = rng.nextInt(totalWeight);
    for (final shape in catalog) {
      roll -= shape.weight;
      if (roll < 0) {
        return List<GridPoint>.from(shape.cells);
      }
    }
    return const <GridPoint>[GridPoint(0, 0)];
  }

  /// Shifts coordinates so minimum x and y are both 0.
  static List<GridPoint> normalize(List<GridPoint> cells) {
    var minX = 999;
    var minY = 999;
    for (final p in cells) {
      if (p.x < minX) minX = p.x;
      if (p.y < minY) minY = p.y;
    }
    return <GridPoint>[
      for (final p in cells) GridPoint(p.x - minX, p.y - minY),
    ];
  }

  /// Rotates polyomino 90 degrees clockwise preserving cell index correspondence
  /// (so a ★ Prism Core remains attached to its exact logical block).
  static List<GridPoint> rotateCW(List<GridPoint> cells) {
    final rotated = <GridPoint>[for (final p in cells) GridPoint(-p.y, p.x)];
    return normalize(rotated);
  }
}

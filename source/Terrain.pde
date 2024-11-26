class Terrain {
  final float[][] altitudes;  // matrix containing the [0,1]-normalized altitude value at location [x,y]
  final float lacunarity;     // in R
  final float persistence;    // in [0,1]
  final int octaves;          // number of octaves
  final int size;             // width and height of the mesh
  
  Terrain(float lacunarity, float persistence, int octaves, int size) {
    assert lacunarity >= 1 : "[Terrain error] lacunarity must be greater or equal than one";
    assert 0 <= persistence && persistence < 1 : "[Terrain error] persistence must be in the 0-1 range";
    assert octaves >= 1 : "[Terrain error] there must be at least one octave";
    assert size >= 2 : "[Terrain error] terrain size must be greater or equal than one";

    this.lacunarity = lacunarity;
    this.persistence = persistence;
    this.octaves = octaves;
    this.size = size;
    this.altitudes = new float[size][size];

    // Compute terrain
    final float maxAltitude = (1 - pow(persistence, octaves)) / (1 - persistence);
    final float noiseFrequencyScale = Settings.terrainDistance / size;
    for (int n = 0; n < octaves; n++) {
      final float frequency = noiseFrequencyScale * pow(lacunarity, (float) n);
      final float amplitude = pow(persistence, (float) n);
      for (int x = 0; x < size; x++) {
        for (int y = 0; y < size; y++) {
          float z = amplitude * noise(frequency * x, frequency * y);
          z /= maxAltitude; // normalized altitude
          altitudes[x][y] += z;
        }
      }
    }
  }

  float altitudeAt(int x, int y) {
    return altitudes[x][y];
  }
}

enum AltitudeLevel {
  SEA(.35, #1C4D89),
  SAND(.42, #EBD89F),
  GRASS(.50, #679A1E),
  DIRT(.65, #5D4038),
  ROCK(.72, #656565),
  SNOW(1, #FFFFFF);

  float maxAltitude;
  color paint;

  AltitudeLevel(float maxAltitude, color paint) {
    this.paint = paint;
    this.maxAltitude = maxAltitude;
  }
}
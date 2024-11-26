class Scene {
  Terrain terrain;
  PImage noiseMap;
  final ControlPanel controlPanel;

  Scene() {
    controlPanel = new ControlPanel();
  }

  void set3DContext() {
    hint(ENABLE_DEPTH_TEST);
    rotateX(radians(56));
    rotateZ(radians(frameCount / 15.0));
  }

  void updateTerrain() {
    boolean didChange = false;
    for (final Scrollbar scrollbar : controlPanel.scrollbars) {
      didChange = didChange || scrollbar.didChange;
    }
    if (didChange) {
      terrain = new Terrain(
        controlPanel.lacunarity.value,
        controlPanel.persistence.value,
        (int) controlPanel.octaves.value,
        (int) controlPanel.size.value
      );
    }
  }

  void drawTerrain() {
    pushMatrix();
    translate(-Settings.groundSize / 2, -Settings.groundSize / 2, 0);
    stroke(0);
    
    for (int x = 0; x < terrain.size - 1; x++) {
      beginShape(TRIANGLE_STRIP);
      for (int y = 0; y < terrain.size; y++) {
        drawAltitudeVertexAt(x, y);
        drawAltitudeVertexAt(x + 1, y);
      }
      endShape(TRIANGLE_STRIP);
    }

    popMatrix();
  }

  void drawAltitudeVertexAt(int x, int y) {
    final float groundUnit = Settings.groundSize / (terrain.size - 1);
    final float dx = groundUnit * x;
    final float dy = groundUnit * y;
    final float z = max(AltitudeLevel.SEA.maxAltitude, terrain.altitudeAt(x, y));
    final float dz = Settings.peakAltitude * z;
    fill(getAltitudeColor(z));
    vertex(dx, dy, dz);
  }

  color getAltitudeColor(float altitude) {
    for (AltitudeLevel level : AltitudeLevel.values()) {
      if (altitude <= level.maxAltitude) {
        return level.paint;
      }
    }
    return #000000;
  }

  void updateNoiseMap() {
    noiseMap = createImage(terrain.size, terrain.size, RGB);
    noiseMap.loadPixels();
    for (int x = 0; x < terrain.size; x++) {
      for (int y = 0; y < terrain.size; y++) {
        final int index = x * terrain.size + y;
        final float z = terrain.altitudeAt(x, y);
        noiseMap.pixels[index] = color(256 * z);
      }
    }
    noiseMap.updatePixels();
  }

  void drawNoiseMap() {
    image(noiseMap, width - Settings.noiseMapSize - Settings.padding, Settings.padding, Settings.noiseMapSize, Settings.noiseMapSize);
  }

  void drawBox() {
    pushMatrix();

    // Draw bottom
    // fill(Settings.bedrockColor);
    // rect(-Settings.groundSize / 2, -Settings.groundSize / 2, Settings.groundSize, Settings.groundSize);

    // Draw box
    translate(0, 0, Settings.peakAltitude / 2);
    noFill();
    stroke(0);
    box(Settings.groundSize, Settings.groundSize, Settings.peakAltitude);
    popMatrix();
  }

  void drawControlPanel() {
    for (final Scrollbar scrollbar : controlPanel.scrollbars) {
      scrollbar.display();
    }
  }

  void drawMetrics() {
    boxedText("Frame rate: " + frameRate, Settings.padding, height - Settings.padding - Settings.textSize);
  }

  void set2DContext() {
    camera(); 
    noLights();
    hint(DISABLE_DEPTH_TEST);
    noLights();
    textMode(MODEL);
  }
}

class ControlPanel {
  final Scrollbar lacunarity;
  final Scrollbar persistence;
  final Scrollbar octaves;
  final Scrollbar size;
  final Scrollbar[] scrollbars;

  ControlPanel() {
    final float spacing = Settings.padding + Settings.scrollbarHeight + Settings.textSize;
    lacunarity = new Scrollbar(Settings.padding, spacing, "Lacunarity", 1, 10, 2);
    persistence = new Scrollbar(Settings.padding, 2 * spacing, "Persistence", 0, 0.99999, 0.5);
    octaves = new DiscreteScrollbar(Settings.padding, 3 * spacing, "Number of octaves", 1, 5, 2, true);
    size = new DiscreteScrollbar(Settings.padding, 4 * spacing, "Terrain size", 2, 200, 100, false);
    scrollbars = new Scrollbar[]{
      lacunarity,
      persistence,
      octaves,
      size
    };
  }
}

void boxedText(String phrase, float x, float y) {
  pushMatrix();

  // Draw box
  final float boxWidth = textWidth(phrase) + 2 * Settings.textBoxPadding;
  final float boxHeight = Settings.textSize + 2 * Settings.textBoxPadding;
  fill(Settings.textBoxColor, 100);
  noStroke();
  rect(x, y, boxWidth, boxHeight, Settings.textBoxBorderRadius);

  // Draw text
  stroke(0);
  fill(Settings.textColor);
  textSize(Settings.textSize);
  text(phrase, x + Settings.textBoxPadding, y + Settings.textBoxPadding + Settings.textSize);

  popMatrix();
}

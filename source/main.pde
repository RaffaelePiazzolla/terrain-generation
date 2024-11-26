final Scene scene = new Scene();

void setup() {
  fullScreen(P3D);
}

void draw() {
  background(Settings.backgroundColor);
  translate(width / 2, height / 2, 0);

  scene.set3DContext();
  scene.updateTerrain();
  scene.updateNoiseMap();
  scene.drawBox();
  scene.drawTerrain();
  
  scene.set2DContext();
  scene.drawNoiseMap();
  scene.drawControlPanel();
  scene.drawMetrics();
}

void mousePressed() {
  for (final Scrollbar scrollbar : scene.controlPanel.scrollbars) {
    scrollbar.mousePressed();
  }
}

void mouseReleased() {
  for (final Scrollbar scrollbar : scene.controlPanel.scrollbars) {
    scrollbar.mouseReleased();
  }
}

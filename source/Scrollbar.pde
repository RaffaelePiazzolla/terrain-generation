class Scrollbar {
  boolean isMousePressed;
  float sliderX;          // x coordinate of the center pixel of the scrollbar
  final float scrollbarX; // x coordinate of the first pixel of the scrollbar
  final float scrollbarY; // y coordinate of the first pixel of the scrollbar
  final String label;     // label text
  final float from;       // lower bound of the final range used by the user
  final float to;         // upper bound of the final range used by the user
  float value;            // slider value in the [from, to] range
  float previousValue;    // slider value in the [from, to] range from the previous iteration
  boolean didChange;      // tells wether the value changed from the previous iteration
  final float lowerBound; // min sliderX position
  final float upperBound; // max sliderX position
  boolean showCuts;       // show scrollbar cuts

  Scrollbar(float scrollbarX, float scrollbarY, String label, float from, float to, float start) {
    this.lowerBound = scrollbarX + Settings.sliderWidth / 2;
    this.upperBound = scrollbarX + Settings.scrollbarWidth - Settings.sliderWidth / 2;

    this.scrollbarX = scrollbarX;
    this.scrollbarY = scrollbarY;
    this.isMousePressed = false;
    this.sliderX = map(start, from, to, lowerBound, upperBound);
    this.value = start;
    this.label = label;
    this.from = from;
    this.to = to;
    this.didChange = true;
    this.showCuts = false;
  }

  void display() {
    final boolean inWithinX = scrollbarX < mouseX && mouseX < scrollbarX + Settings.scrollbarWidth;
    final boolean isWithinY = scrollbarY < mouseY && mouseY < scrollbarY + Settings.scrollbarHeight;
    if (isMousePressed && inWithinX && isWithinY) {
      sliderX = constrain(mouseX, lowerBound, upperBound);
    }

    value = cast(map(sliderX, lowerBound, upperBound, from, to));
    didChange = value != previousValue;
    previousValue = value;
    
    pushMatrix();

    // Scrollbar
    fill(200);
    rect(scrollbarX, scrollbarY, Settings.scrollbarWidth, Settings.scrollbarHeight);
    // Cuts
    if (this instanceof DiscreteScrollbar && showCuts) {
      for (float i = from; i <= to; i++) {
        final float x = map(i, from, to, lowerBound, upperBound);
        line(x, scrollbarY, x, scrollbarY + Settings.scrollbarHeight);
      }
    }

    // Slider
    fill(100);
    rect(sliderX - Settings.sliderWidth / 2, scrollbarY, Settings.sliderWidth, Settings.scrollbarHeight);
    
    // Label
    fill(Settings.textColor);
    textSize(Settings.textSize);
    text(label + ": " + cast(value), scrollbarX, scrollbarY - 12);
    popMatrix();
  }

  void mousePressed() {
    isMousePressed = true;
  }

  void mouseReleased() {
    isMousePressed = false;
  }

  float cast(float x) {
    return x;
  }
}

class DiscreteScrollbar extends Scrollbar {
  DiscreteScrollbar(float scrollbarX, float scrollbarY, String label, int from, int to, int start, boolean showCuts) {
    super(scrollbarX, scrollbarY, label, (float) from, (float) to, (float) start);
    super.showCuts = showCuts;
  }

  float cast(float x) {
    return (float) Math.floor(x);
  }
}

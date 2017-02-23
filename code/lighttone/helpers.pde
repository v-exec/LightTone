//scan individual pixels in pixel[] array, and convert the RGB return value of each called pixel to 0-255 grayscale
int grayify (int i) {
  int c=pixels[i+212*width];
  int r=(c&0x00FF0000)>>16;
  int g=(c&0x0000FF00)>>8;
  int b=(c&0x000000FF);
  int grey=(r+b+g)/3;
  return grey;
}

//velocity and note mapping
int velocify (int pixel) {
  float velocityflt = map (grayify(pixel), 0, 255, 0, 127);
  int velocity = (int)velocityflt;
  return velocity;
}

int noteify (int pixel) {
  float noteflt = map (pixel, 0, width-1, 60, 83);
  int note = (int)noteflt;
  return note;
}
int scale = 2;
int len = 7;
int loopLen = 300;
int mode = 2;

String rev = "9eecb63";

float angVar = 0, scaleMult = 1, powMult = 1, latLonVar = 0;
float off = 0.0;
float dim;

Wave[] waves;

PShader sh_wav;
PGraphics canvas;
PImage palette;
boolean paint = true;
boolean capture = false;
boolean rand = true;
boolean animate = true;
boolean makeMovie = false;
int movieFrame = 0;
String movieFolder;
int t = 0;
int kto = 0;
int seed;


String out_folder = "C:/Leo/1_work/capturas/processing/s068_waves2/";
String p_folder = "C:/Leo/1_work/capturas/source_images/gradients/simple/";
int p_file = 40;

void setup() {
  size(540, 540, P2D);
  frameRate(30);

  dim = dist(0, 0, width*scale, height*scale);
  
  canvas = createGraphics(width*scale, height*scale, P2D);
  
  palette = createImage(600, 1, RGB);
      
  waves = new Wave[len];
  for(int i=0; i<len; i++) {
    waves[i] = new Wave(i);
  }
  
  sh_wav = loadShader("waves.frag");
  sh_wav.set("size", float(width*scale), float(height*scale), dim);
  sh_wav.set("len", len);
  
  
  canvas.shader(sh_wav);
  
  loadPalette();

}

void loadPalette() {
  PImage loaded = loadImage(p_folder + nf(p_file, 2) + ".jpg");
  palette.copy(loaded, 0, 0, loaded.width, 1, 0, 0, palette.width, 1);
  println("loaded palette", p_file);
  
  sh_wav.set("palette", palette);
}

void draw() {
  
  if(rand){
    seed = int(random(99999));
    randomSeed(seed);
    noiseSeed(seed);
    println("seed", seed);
    
    t = 0;
    
    for(int i=0; i<len; i++) {
      waves[i].reset();
    }
    rand = false;
  }
  
  if(paint) {
    float[] _locs = new float[len*3];
    float[] _waves = new float[len*3];
    float[] _mixes = new float[len*2];
    float[] _pows = new float[len*2];
    
    for(int i=0; i<len; i++) {
      waves[i].update();
      
      _locs[i*3] = waves[i].pos.x;
      _locs[i*3+1] = waves[i].pos.y;
      _locs[i*3+2] = waves[i].scale * scaleMult;
      
      _waves[i*3] = waves[i].force;
      _waves[i*3+1] = waves[i].ang + angVar;
      _waves[i*3+2] = waves[i].petals;
      
      _mixes[i*2] = waves[i].lat_lon + latLonVar;
      _mixes[i*2+1] = waves[i].curved;
      
      _pows[i*2] = waves[i].pwLat * powMult;
      _pows[i*2+1] = waves[i].pwLon * powMult;
    }
    
    sh_wav.set("locs", _locs, 3);
    sh_wav.set("waves", _waves, 3);
    sh_wav.set("mixes", _mixes, 2);
    sh_wav.set("pows", _pows, 2);
    sh_wav.set("mode", mode);
    sh_wav.set("off", off);
    
    canvas.beginDraw();
    canvas.rect(0, 0, width*scale, height*scale); 
    canvas.endDraw();
    
    image(canvas, 0, 0, width, height);
    
    t++;
    paint = false;
  }
  
  if(animate){

    if(makeMovie) {
      canvas.save(out_folder +'/'+ movieFolder +'/'+ nf(movieFrame, 4)  + ".jpg");
      movieFrame ++;
      
      if(movieFrame >= loopLen) {
        makeMovie = false;
        movieFrame = 0;
        println("movie saved in ", out_folder +'/'+ movieFolder);
      }
    }

    paint = true;
  }
  
    
  if(capture){
    canvas.save(out_folder +  makeName()  + ".jpg");
    println("capture saved");
    capture = false;
  }
  
  if(kto > 1) kto--;
  else if(kto == 1) _keyPressed();
  
}

class Wave {
  PVector pos, ori, dest;
  float scale, force, ang, petals;
  float lat_lon, curved;
  float pwLat, pwLon;
  float gen;
  
  color col;
  int ix;
  
  Wave(int i) {
    ix = i;
    pos = new PVector();
    ori = new PVector();
    dest = new PVector();
    gen = random(1);
    //reset();
  }
  
  void reset() {
    pos.set(random(1), random(1));
    ori.set(pos.x, pos.y);
    dest.set(random(1), random(1));
    //pos.set(0.5, 0.5);
    scale = random(0.2, 5);
    force = random(1);
    ang = random(TWO_PI);   
    petals = int(random(3, 9));
    lat_lon = 1;//random(1);
    curved = 1;//random(1);
    pwLat = random(0.2, 5);
    pwLon = 1;//random(0.2, 5);
  }
  
  void update(){
    //force = cos(gen*TWO_PI + t*(TWO_PI/loopLen))*0.5+0.5;
    //pos.x = contrast(noiseCirc(0.5, ix*4), 2);
    //pos.y = contrast(noiseCirc(0.5, 8.5+float(ix*4)), 2);
    float e = IO(float(t%loopLen)/loopLen, 1, false) + gen;
    //pos.x = lerp(ori.x, dest.x, e);
    //pos.y = lerp(ori.y, dest.y, e);
    pos.x = ori.x + dest.x * cos(e * TWO_PI * 2 );
    pos.y = ori.y + dest.x * sin(e * TWO_PI);
    //if(ix == 1) println(float(t%loopLen)/loopLen);
  }

}

void keyPressed(){
  _keyPressed();
  kto = 15;
}

void keyReleased(){
  kto = 0;
}

void _keyPressed(){
  switch(key){
    case 's':
      paint = true;
      capture = true;
      break;
    case ' ':
      animate = !animate;
      break;
    case 'A':
      angVar = max( angVar-0.1, 0 );
      paint = true;
      println("angVar", angVar);
      break;
    case 'a':
      angVar = min( angVar+0.1, TWO_PI );
      paint = true;
      println("angVar", angVar);
      break;
    case 'B':
      scaleMult = max( scaleMult-0.01, 0 );
      paint = true;
      println("scaleMult", scaleMult);
      break;
    case 'b':
      scaleMult = min( scaleMult+0.01, 5 );
      paint = true;
      println("scaleMult", scaleMult);
      break;
    case 'L':
      latLonVar = max( latLonVar-0.01, 0 );
      paint = true;
      println("latLonVar", latLonVar);
      break;
    case 'l':
      latLonVar = min( latLonVar+0.01, 1 );
      paint = true;
      println("latLonVar", latLonVar);
      break;
     case 'W':
      powMult = max( powMult-0.01, -5 );
      paint = true;
      println("powMult", powMult);
      break;
    case 'w':
      powMult = min( powMult+0.01, 5 );
      paint = true;
      println("powMult", powMult);
      break;
    case 'O':
      off = max( off-0.005, 0 );
      paint = true;
      println("off", off);
      break;
    case 'o':
      off = ( off+0.005 ) % 1.;
      paint = true;
      println("off", off);
      break;
    case 'm':
      mode ++; mode %= 5;
      paint = true;
      println("mode", mode);
      break;
    case 'r':
      rand = true;;
      paint = true;
      println("randomize");
      break;
    case 'p':
      p_file ++;
      loadPalette();
      break;
    case 'P':
      p_file --;
      loadPalette();
      break;
    case 'v':
      movieFolder = makeName();
      makeMovie = true;
      movieFrame = 0;
      break;
  }
}

String makeName(){
  String out = "s068_"+ rev +"_seed"+ seed +"_t"+ t +"__";
  out += str(year()).substring(2) + nf(month(), 2) + nf(day(), 2) +".";
  out += nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  //out += "_len"+ len + "_a"+ nf(a, 1, 2) + "_b"+ nf(b, 1, 2) + "_c"+ nf(c, 1, 2);
  //out += "_am"+ amode + "_bm"+ bmode + "_cm"+ cmode + "_mode"+ mode ; 
  //out += "_balance"+ nf(balance, 1, 2) +"_limitMode"+ limitMode +"_limit"+ nf(limit, 1, 2);
  
  return out;
}

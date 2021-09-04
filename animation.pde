float noiseCirc(float r, float z) {
  float a = float(t % loopLen) / float(loopLen) * TWO_PI;
  //println(cos(a));
  return noise(z, r * cos(a), r * sin(a));
}

float contrast(float x, float p) {
  return constrain((x-0.5)*p + 0.5, 0., 1.);
}

float ease(float x, float p, boolean up) {
  if(p<0){
    if(up) return 1 - pow(x, abs(p));
    return 1 - pow(1-x, abs(p));
  }
  if(up) return pow(1-x, abs(p));
  return pow(x, abs(p));
}

float hill(float x, float p, boolean up) {
  if (x < 0.5) {
    x *= 2;
  } else {
    x = 1 - (x-0.5)*2;
  }
  if(p<0){
    if(up) return pow(1-x, abs(p));
    else return 1 - pow(1-x, abs(p));
  } else {
    if(up) return 1 - pow(x, abs(p));
    else return pow(x, abs(p));
  }
}

float IO(float x, float p, boolean up) {
  float o;
  if(x <0.5) {
    x = ease(x*2, p, false) * 0.5;
  } else {
    x = (1- ease(1-(x-0.5)*2, p, false)) * 0.5 + 0.5;
  }
  if(up) x = 1 - x;
  return x;
}

float ease2(String type, float t, float b, float c, float d) {
  float s = 1.70158f;
  
  switch(type) {
    case "set": return b + c;
    
    case "None": return c*t/d + b;
    
    case "In2": return c * (t /= d) * t + b;
    case "Out2": return -c * (t /= d) * (t - 2) + b;
    case "IO2": 
      if ((t /= d / 2) < 1) return c / 2 * t * t + b;
      return -c / 2 * ((--t) * (t - 2) - 1) + b;
      
    case "In3": return c * (t /= d) * t * t + b;
    case "Out3": return c * ((t = t / d - 1) * t * t + 1) + b;
    case "IO3": 
      if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
      return c / 2 * ((t -= 2) * t * t + 2) + b;
      
    case "In4": return c * (t /= d) * t * t * t + b;
    case "Out4": return -c * ((t = t / d - 1) * t * t * t - 1) + b;
    case "IO4": 
      if ((t /= d / 2) < 1) return c / 2 * t * t * t * t + b;
      return -c / 2 * ((t -= 2) * t * t * t - 2) + b;
      
    case "In5": return c * (t /= d) * t * t * t * t + b;
    case "Out5": return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
    case "IO5":
      if ((t /= d / 2) < 1) return c / 2 * t * t * t * t * t + b;
      return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
      
    case "InExp": return (t == 0) ? b : c *  pow(2, 10 * (t / d - 1)) + b;
    case "OutExp": return (t == d) ? b + c : c * (- pow(2, -10 * t / d) + 1) + b;
    case "IOExp":
      if (t == 0) return b;
      if (t == d) return b + c;
      if ((t /= d / 2) < 1) return c / 2 *  pow(2, 10 * (t - 1)) + b;
      return c / 2 * (- pow(2, -10 * --t) + 2) + b;
      
    case "InSin": return -c * cos(t / d * (PI / 2)) + c + b;
    case "OutSin": return c *  sin(t / d * (PI / 2)) + b;
    case "IOSin": return -c / 2 * ( cos(PI * t / d) - 1) + b;
    
    case "InCirc": return -c * ( sqrt(1 - (t /= d) * t) - 1) + b;
    case "OutCirc": return c *  sqrt(1 - (t = t / d - 1) * t) + b;
    case "IOCirc":
      if ((t /= d / 2) < 1) return -c / 2 * ( sqrt(1 - t * t) - 1) + b;
      return c / 2 * ( sqrt(1 - (t -= 2) * t) + 1) + b;
      
    case "InBack": return c * (t /= d) * t * ((s + 1) * t - s) + b;
    case "OutBack": return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
    case "IOBack":
      if ((t /= d / 2) < 1) return c / 2 * (t * t * (((s *= (1.525f)) + 1) * t - s)) + b;
      return c / 2 * ((t -= 2) * t * (((s *= (1.525f)) + 1) * t + s) + 2) + b;
  }
  
  return 0.0;
}

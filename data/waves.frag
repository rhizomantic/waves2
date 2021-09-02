#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER

#define MAX_WAVES 18
#define SQ2 1.414213
#define PI 3.1415926535897932384
#define PI2 6.2831853071795864769

uniform sampler2D texture;
uniform sampler2D palette;
uniform vec3 size;
uniform int len;
uniform vec3 locs[MAX_WAVES];
uniform vec3 waves[MAX_WAVES];
uniform vec2 mixes[MAX_WAVES];
uniform vec2 pows[MAX_WAVES];
uniform int mode;
uniform float off;

// locs[i].x  : posición en x [0.-1.]
// locs[i].y  : posición en y [0.-1.]
// locs[i].z  : escala (multiplicador de distancia) [float]
// waves[i].x : intensidad [0.-1.]
// waves[i].y : ángulo de referencia [float]
// waves[i].z : pétalos (cantidad de meridianos) [int]
// mixes[i].x : mix entre paralelos y meridianos [0.-1.]
// mixes[i].y : mix entre recta y círculo [0.-1.]
// pows[i].x  : pow paralelos [float]
// pows[i].y  : pow meridianos [float]

float swing(float x, float p) {
	return mod(floor(x), 2.) == 0 ?
	( p < 0 ? pow(fract(x), abs(p)) : pow(1.-fract(x), p) ) :
	( p < 0 ? pow(1.-fract(x), abs(p)) : pow(fract(x), p) ) ;
}

float contrast(float x, float p) {
	return clamp((x-0.5)*p + 0.5, 0., 1.);
}

void main(void) {
	vec2 pos = vec2(gl_FragCoord.x/size.x, 1.0 - gl_FragCoord.y/size.y);

	float val = 0., a = 0., d = 0., lat = 0., lon = 0.;
	for(int i=0; i<len; i++) {
		a = waves[i].y - atan(locs[i].y - pos.y, locs[i].x - pos.x);
		d = distance(locs[i].xy, pos.xy);
		//n = d * sin(a) / waves[i].y;
		//n = (d / waves[i].y) * 0.5;// + (d * sin(a) / waves[i].y) * 0.5;
		//val += pow( cos( PI * n ) * 0.5 + 0.5, waves[i].z );
		//val += pow( sin( a * 2. ) * 0.5 + 0.5, waves[i].z ) * pow( cos( PI * n ) * 0.5 + 0.5, waves[i].z );
		//val += d * waves[i].y; // aureolas muy simples
		//val += sin( PI * 2 * d * waves[i].y) * 0.5 + 0.5;

		//n = d * sin(a) * waves[i].y * 2;
		//np = pow(fract(n), waves[i].z);
		//val += mod(floor(n), 2.) == 0. ? 1.-np : np;

		//val += pow(cos( a * 5. ) * 0.5 + 0.5, waves[i].z);
		//val += swing((a/PI) * 5., pows[i].y);


		lat = swing( mix(d*sin(a), d, mixes[i].y) * locs[i].z * 2, pows[i].x);
		//lat = pow(sin(d * PI * locs[i].z), pows[i].x);
		lon = pow(cos(a * waves[i].z)*0.5+0.5, pows[i].y);
		//lon = swing((a/PI) * waves[i].z, pows[i].y);
		val += mix(lat, lon, mixes[i].x) * waves[i].x;

	}

	vec4 res;
	if( mode == 0 ){
		val /= float(len);
	} else if( mode == 1 ){
		val = contrast(val/float(len), 2);
	} else if( mode == 2 ){
		val = mod(floor(val), 2.) == 0. ? fract(val) : 1.-fract(val);
	} else if( mode == 3 ){
		val = cos(PI*val) * 0.5 + 0.5;
	} else if( mode == 4 ){
		val = fract(val);
	}

	res = texture2D( palette, vec2( fract(val+off), 0.5 ) );

	gl_FragColor = res;
}

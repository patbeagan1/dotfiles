void mainImage(out vec4 f,vec2 q){

    vec2 r = iResolution.xy, 
         p = (q-.5*r)/r.y;

    float l=length(p),z=iTime;
	for( int i=0; i<4; i++)
		f[i] = .01/length(abs(fract( q/r + p/l* (sin(z+=.07)+1.) * abs(sin(l*9.-z*2.)) )-.5)) / l;
}

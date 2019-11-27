precision mediump float;

uniform sampler2D u_Texture;

varying vec2 v_TextureCoord_out;
varying vec4 a_Position_out;

const vec3 W = vec3(0.2125, 0.7154, 0.0721);
uniform float saturation;

void main(){
    vec4 color = texture2D(u_Texture, v_TextureCoord_out);
    float lumiance = dot(color.rgb, W);
    vec3 grayScale = vec3(lumiance),
    gl_FragColor = vec4(mix(grayScalem color.rgb,saturation), color.w);
}

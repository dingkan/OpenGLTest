precision mediump float;

uniform sampler2D u_Texture;

varying vec2 v_TextureCoord_out;
varying vec4 a_Position_out;

void main(){
    vec4 color = texture2D(u_Texture, v_TextureCoord_out);
    gl_FragColor = color;
}

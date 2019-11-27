attribute vec4 a_Position;
attribute vec2 a_TextureCoord;

varying vec2 v_TextureCoord_out;
varying vec4 a_Position_out;

void main(){
    gl_Position = a_Position;
    a_Position_out = a_Position;
    v_TextureCoord_out = a_TextureCoord;
}

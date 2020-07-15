// input pixel coords
varying highp vec2 qt_TexCoord0;

// source neuron grid
uniform sampler2D textureMap;

// various props
uniform int cols;
uniform int rows;
uniform float realWidth;
uniform float realHeight;
uniform float cw;
uniform float ch;

void main(void)
{
    // props
    float pad = 3.0;                            // pixel padding between cells
    vec2 s = vec2(realWidth, realHeight);       // 100% size in pixels
    vec2 wh = vec2(cw, ch);                     // container width/height
    vec2 cr = vec2(cols, rows);                 // cols/rows vector

    vec2 diff = wh / s;                         // offset value to map grid to center
    vec2 pxl = diff / wh;                       // pixel unit relative to GLSL's [0, 1] coord system

    // map tex coord to centered grid
    vec2 st = (qt_TexCoord0 * diff) - ((diff - 1.0) / 2.0);
    // retrieve pixel color and upscale
    vec2 fst = floor(st * cr) / cr + (0.5 / cr);

    // set to color
    vec4 c = vec4(1.0, 1.0, 1.0, 1.0) * texture2D(textureMap, fst).rrrr;
    // hide pixels outside drawing zone
    c *= (st.x < 0.0 || st.y < 0.0 || st.x >= 1.0 || st.y >= 1.0) ? 0.0 : 1.0;

    // set padding
    vec2 value = vec2(mod(st.x, pxl.x*cols), mod(st.y, pxl.y*rows));
    c *= value.x > pxl.x*pad && value.x < pxl.x*cols-(pxl.x*(pad+1.0)) ? 1.0 : 0.0;
    c *= value.y > pxl.y*pad && value.y < pxl.y*rows-(pxl.y*(pad+1.0)) ? 1.0 : 0.0;

    // export color
    gl_FragColor = c;
}

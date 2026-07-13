#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
};

// --- 2D Noise functions ---
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x),
               mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = qt_TexCoord0;
    float aspect = resolution.x / resolution.y;
    vec2 pos = vec2(uv.x * aspect, uv.y);

    vec3 bg = mix(vec3(0.043, 0.043, 0.078), vec3(0.086, 0.086, 0.165), uv.y);

    // Violet band
    float v = fbm(vec2(pos.x * 1.2 + time * 0.015, pos.y * 0.8 + time * 0.005));
    float vMask = smoothstep(0.25, 0.6, v) * smoothstep(0.0, 0.35, 1.0 - abs(uv.y - 0.3) * 3.5);
    vec3 violet = vec3(0.659, 0.333, 0.969) * vMask * 0.12;

    // Cyan band
    float c = fbm(vec2(pos.x * 1.5 - time * 0.012, pos.y + time * 0.008));
    float cMask = smoothstep(0.3, 0.6, c) * smoothstep(0.0, 0.3, 1.0 - abs(uv.y - 0.55) * 3.0);
    vec3 cyan = vec3(0.024, 0.714, 0.831) * cMask * 0.10;

    // Rose band
    float r = fbm(vec2(pos.x * 1.8 + time * 0.02, pos.y * 1.2 - time * 0.006));
    float rMask = smoothstep(0.25, 0.55, r) * smoothstep(0.0, 0.25, 1.0 - abs(uv.y - 0.8) * 4.0);
    vec3 rose = vec3(0.957, 0.247, 0.373) * rMask * 0.10;

    vec3 color = bg + violet + cyan + rose;
    fragColor = vec4(color, 1.0) * qt_Opacity;
}

shader_type canvas_item;

uniform int pixelSize = 6;
uniform float col_per_channel = 16.0;
uniform float dithering_intensity = 0.5;
uniform float color_to_palette_blend = 0.0;
uniform int color_palette_size;
uniform sampler2D color_palette;

uniform float brightness = 0.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;
uniform float gamma = 1.0;

const vec3 grayscale_vector = vec3(0.299, 0.587, 0.114);

const mat4 bayer4 = mat4(
	vec4(0.0/16.0,  8.0/16.0,  2.0/16.0,  10.0/16.0),
	vec4(12.0/16.0, 4.0/16.0,  14.0/16.0, 6.0/16.0),
	vec4(3.0/16.0,  11.0/16.0, 1.0/16.0,  9.0/16.0),
	vec4(15.0/16.0, 7.0/16.0,  13.0/16.0, 5.0/16.0)
);
const int dithering_dimension = 4;

float get_mat4_val(mat4 mat, int x, int y) {
	switch (x) {
    case 0:
        switch (y) {
        case 0:
            return mat[0][0];
        case 1:
            return mat[0][1];
        case 2:
            return mat[0][2];
        case 3:
            return mat[0][3];
        }
    case 1:
        switch (y) {
        case 0:
            return mat[1][0];
        case 1:
            return mat[1][1];
        case 2:
            return mat[1][2];
        case 3:
            return mat[1][3];
        }
    case 2:
        switch (y) {
        case 0:
            return mat[2][0];
        case 1:
            return mat[2][1];
        case 2:
            return mat[2][2];
        case 3:
            return mat[2][3];
        }
    case 3:
        switch (y) {
        case 0:
            return mat[2][0];
        case 1:
            return mat[2][1];
        case 2:
            return mat[2][2];
        case 3:
            return mat[2][3];
        }
	}
    return -1.0;
}

float lerp(float a, float b, float t) {
	return a*(1.0-t) + b*(t);
}

vec3 lerpv(vec3 a, vec3 b, float t) {
	return vec3(
		lerp(a.x, b.x, t),
		lerp(a.y, b.y, t),
		lerp(a.z, b.z, t)
	);
}

vec3 post_processing(vec3 col) {
	// contrast
	col = vec3(contrast) * (col - vec3(0.5)) + vec3(0.5);
	col += brightness;
	col = clamp(col, vec3(0.0), vec3(1.0));

	// saturation
    float grayscale = dot(col, grayscale_vector);
    col = lerpv(vec3(grayscale), col, saturation);
    col = clamp(col, vec3(0.0), vec3(1.0));
	
	// gamma correction
	col = pow(col, vec3(gamma));
	
	return col;
}

void fragment() {
	ivec2 size = textureSize(TEXTURE, 0);
	
	int xRes = size.x;
	int yRes = size.y;
	
	float xFactor = float(xRes) / float(pixelSize);
	float yFactor = float(yRes) / float(pixelSize);
	
	float grid_uv_x = round(UV.x * xFactor) / xFactor;
	float grid_uv_y = round(UV.y * yFactor) / yFactor;
	
	vec4 text = texture(TEXTURE, vec2(grid_uv_x, grid_uv_y));
	
	int dithering_x = int(UV.x * float(size.x)) % dithering_dimension;
	int dithering_y = int(UV.y * float(size.y)) % dithering_dimension;
	float dithering_noise = get_mat4_val(bayer4, dithering_x, dithering_y) - 0.5;
	
	vec3 col = text.xyz + vec3(dithering_noise * dithering_intensity);
	col.x = floor(col.x * (col_per_channel-1.0) + 0.5) / (col_per_channel-1.0);
	col.y = floor(col.y * (col_per_channel-1.0) + 0.5) / (col_per_channel-1.0);
	col.z = floor(col.z * (col_per_channel-1.0) + 0.5) / (col_per_channel-1.0);
	
	float grayscale = dot(text.xyz, grayscale_vector);
	grayscale += dithering_noise;
    float grayscale_flattened = floor(
		grayscale * (float(color_palette_size)-1.0) + 0.5) / (float(color_palette_size)-1.0);
	vec3 color_palette_color = texture(color_palette, vec2(grayscale_flattened, 0.0)).xyz;
    
	COLOR.xyz = post_processing(lerpv(col, color_palette_color, color_to_palette_blend));
	COLOR.w = text.a;
}

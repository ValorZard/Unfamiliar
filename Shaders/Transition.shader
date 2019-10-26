shader_type canvas_item;

uniform float cutoff : hint_range(0f, 1f);
uniform sampler2D mask : hint_albedo;

void fragment() {
	float value = texture(mask, UV).r;
	COLOR = value < cutoff ? vec4(COLOR.rgb, 0) : vec4(COLOR.rgb, 1);
}

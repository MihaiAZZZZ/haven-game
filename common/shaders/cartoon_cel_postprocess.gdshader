shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float warmth : hint_range(0.0, 1.0, 0.05) = 0.15;
uniform float saturation : hint_range(0.8, 1.5, 0.05) = 1.1;
uniform float brightness : hint_range(0.8, 1.3, 0.05) = 1.02;
uniform float contrast : hint_range(0.8, 1.4, 0.05) = 1.04;
uniform float vignette_strength : hint_range(0.0, 1.0, 0.05) = 0.25;
uniform vec4 vignette_color : source_color = vec4(0.1, 0.08, 0.14, 1.0);

void fragment() {
	vec4 base = texture(screen_texture, SCREEN_UV);
	vec3 col = base.rgb;

	col = (col - 0.5) * contrast + 0.5;

	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, saturation);

	vec3 warm_tint = vec3(1.04, 1.0, 0.94);
	col = mix(col, col * warm_tint, warmth);
	col *= brightness;

	vec2 center_diff = SCREEN_UV - vec2(0.5);
	float dist = length(center_diff);
	float vig = smoothstep(0.42, 0.88, dist) * vignette_strength;
	col = mix(col, vignette_color.rgb, vig);

	COLOR = vec4(clamp(col, 0.0, 1.0), base.a);
}

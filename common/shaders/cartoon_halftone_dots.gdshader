shader_type canvas_item;

uniform vec4 dot_color : source_color = vec4(0.12, 0.08, 0.2, 0.4);
uniform float dot_density : hint_range(10.0, 150.0, 5.0) = 60.0;
uniform float dot_size_max : hint_range(0.1, 0.8, 0.05) = 0.45;
uniform float shadow_threshold : hint_range(0.1, 0.9, 0.05) = 0.55;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float luma = dot(base.rgb, vec3(0.299, 0.587, 0.114));

	vec2 st = UV * dot_density;
	mat2 rot = mat2(vec2(0.7071, -0.7071), vec2(0.7071, 0.7071));
	st = rot * st;

	vec2 grid_uv = fract(st) - vec2(0.5);
	float dist = length(grid_uv);

	float dot_radius = (1.0 - smoothstep(0.1, shadow_threshold, luma)) * dot_size_max;

	if (dist < dot_radius && base.a > 0.1) {
		base.rgb = mix(base.rgb, dot_color.rgb, dot_color.a);
	}

	COLOR = base;
}

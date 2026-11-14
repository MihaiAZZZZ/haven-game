shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.08, 0.06, 0.14, 1.0);
uniform float outline_thickness : hint_range(0.0, 10.0, 0.5) = 3.0;
uniform bool enable_wobble = false;
uniform float wobble_speed : hint_range(1.0, 20.0, 1.0) = 8.0;

void fragment() {
	vec2 uv = UV;

	if (enable_wobble) {
		float step_t = floor(TIME * wobble_speed) / wobble_speed;
		uv.x += sin(uv.y * 30.0 + step_t * 20.0) * (outline_thickness * TEXTURE_PIXEL_SIZE.x * 0.3);
	}

	vec4 base = texture(TEXTURE, uv);

	if (base.a > 0.6) {
		COLOR = base;
		return;
	}

	vec2 size = TEXTURE_PIXEL_SIZE * outline_thickness;
	float max_alpha = 0.0;

	for (float x = -1.0; x <= 1.0; x += 1.0) {
		for (float y = -1.0; y <= 1.0; y += 1.0) {
			if (x == 0.0 && y == 0.0) continue;
			float a = texture(TEXTURE, uv + vec2(x * size.x, y * size.y)).a;
			max_alpha = max(max_alpha, a);
		}
	}

	if (max_alpha > 0.1) {
		COLOR = outline_color;
	} else {
		COLOR = vec4(0.0);
	}
}

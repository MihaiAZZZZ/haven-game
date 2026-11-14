extends Area2D
class_name LighthouseBrazier

## Cozy Cartoon Brazier at the top of Elena's lighthouse.

signal brazier_lit()

var is_lit: bool = false
var _time: float = 0.0

@onready var prompt: Label = %Prompt

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if is_lit:
		return
	if body is GhostPlayer:
		light_brazier()

func light_brazier() -> void:
	if is_lit:
		return
	is_lit = true
	AudioSynth.play_chime(1.5)
	brazier_lit.emit()
	if prompt:
		prompt.visible = false

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	
	# Metal brazier bowl
	var bowl_pts = PackedVector2Array([
		Vector2(-24, -14),
		Vector2(24, -14),
		Vector2(14, 10),
		Vector2(-14, 10)
	])
	draw_colored_polygon(bowl_pts, Color(0.32, 0.35, 0.42))
	draw_polyline(bowl_pts, ink, 3.0)
	# Pedestal
	draw_rect(Rect2(-8, 10, 16, 16), ink)
	draw_rect(Rect2(-6, 10, 12, 16), Color(0.28, 0.3, 0.38))
	draw_rect(Rect2(-18, 26, 36, 8), ink)
	draw_rect(Rect2(-16, 26, 32, 6), Color(0.22, 0.25, 0.32))
	
	if is_lit:
		# Warm cozy golden beacon flame!
		var pulse = 1.0 + 0.15 * sin(_time * 5.0)
		draw_circle(Vector2(0, -20), 22.0 * pulse, Color(0.98, 0.82, 0.35, 0.55))
		draw_circle(Vector2(0, -20), 12.0, Color.WHITE)
		
		# Sweeping lighthouse light cone (warm golden cream)
		var beam_angle = sin(_time * 1.4) * 0.45 - 0.25
		var beam_len = 520.0
		var beam_pts = PackedVector2Array([
			Vector2(0, -20),
			Vector2(cos(beam_angle - 0.22) * beam_len, sin(beam_angle - 0.22) * beam_len),
			Vector2(cos(beam_angle + 0.22) * beam_len, sin(beam_angle + 0.22) * beam_len)
		])
		draw_colored_polygon(beam_pts, Color(1.0, 0.95, 0.8, 0.2))

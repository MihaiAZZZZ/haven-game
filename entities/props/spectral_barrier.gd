extends StaticBody2D
class_name SpectralBarrier

## SpectralBarrier: A barrier that only blocks Manifested ghosts.
## Phased ghosts (collision_mask does not include bit 3 / value 4) pass through!

@export var barrier_size: Vector2 = Vector2(24, 120)
@export var barrier_color: Color = Color(0.75, 0.58, 0.88, 0.85) # Cozy soft lavender

var _time: float = 0.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 0
	
	var col = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not col:
		col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = barrier_size
		col.shape = shape
		add_child(col)
	elif col.shape is RectangleShape2D:
		(col.shape as RectangleShape2D).size = barrier_size

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var half_w = barrier_size.x * 0.5
	var half_h = barrier_size.y * 0.5
	var rect = Rect2(-half_w, -half_h, barrier_size.x, barrier_size.y)
	
	# Glow backing
	var alpha_pulse = 0.35 + 0.15 * sin(_time * 3.5)
	var glow_col = Color(barrier_color.r, barrier_color.g, barrier_color.b, alpha_pulse)
	draw_rect(rect, glow_col)
	
	# Borders in warm ink
	draw_rect(rect, Color(0.14, 0.1, 0.16), false, 2.0)
	draw_rect(rect.grow(-2.0), barrier_color, false, 2.0)
	
	# Ethereal horizontal pixel scanlines
	var line_spacing = 16.0
	var offset = fmod(_time * 24.0, line_spacing)
	var y = -half_h + offset
	while y < half_h:
		var line_alpha = 0.4 + 0.4 * sin((y + half_h) / barrier_size.y * PI)
		draw_rect(Rect2(-half_w + 3.0, y, barrier_size.x - 6.0, 2.0), Color(1, 1, 1, line_alpha * 0.7))
		y += line_spacing

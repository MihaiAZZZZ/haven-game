extends Area2D
class_name WindCurrentArea

@export var wind_velocity: Vector2 = Vector2(280.0, 0.0)
@export var area_size: Vector2 = Vector2(300, 100)

var _time: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	var col = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col and col.shape is RectangleShape2D:
		(col.shape as RectangleShape2D).size = area_size

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			body.velocity += wind_velocity * delta * 2.5

func _draw() -> void:
	var half_w = area_size.x * 0.5
	var half_h = area_size.y * 0.5

	draw_rect(Rect2(-half_w, -half_h, area_size.x, area_size.y), Color(0.8, 0.85, 0.92, 0.06))

	var streaks = 6
	for i in range(streaks):
		var y = -half_h + (float(i) / streaks) * area_size.y + 8.0
		var progress = fmod(_time * 1.4 + float(i) * 0.35, 1.0)
		var x = -half_w + progress * area_size.x
		var len = 42.0
		var alpha = sin(progress * PI) * 0.45
		draw_line(Vector2(x, y), Vector2(x + len, y), Color(0.9, 0.92, 0.96, alpha), 2.0)

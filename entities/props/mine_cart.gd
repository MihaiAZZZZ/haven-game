extends CharacterBody2D
class_name MineCart

## MineCart: Heavy mining cart pushed by physical ghost onto track destination.

signal reached_target()

@export var track_limit_left: float = 200.0
@export var track_limit_right: float = 600.0
@export var target_x: float = 520.0

var _is_locked: bool = false
var _time: float = 0.0

func _ready() -> void:
	collision_layer = 1 | 4
	collision_mask = 1 | 2 # Collides with floor and player

func _physics_process(delta: float) -> void:
	if _is_locked:
		velocity = Vector2.ZERO
		return
		
	# Apply gravity
	if not is_on_floor():
		velocity.y += 980.0 * delta
		
	# Friction on rails
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	
	move_and_slide()
	
	# Clamp to rails
	global_position.x = clamp(global_position.x, track_limit_left, track_limit_right)
	
	# Check if reached target position
	if abs(global_position.x - target_x) < 20.0 and not _is_locked:
		_is_locked = true
		global_position.x = target_x
		velocity = Vector2.ZERO
		AudioSynth.play_switch()
		reached_target.emit()
		
	queue_redraw()

func push(force: float) -> void:
	if not _is_locked:
		velocity.x += force

func _draw() -> void:
	# Draw Mine Cart
	var body_col = Color(0.35, 0.25, 0.18) if not _is_locked else Color(0.2, 0.6, 0.4)
	# Wheels
	draw_circle(Vector2(-20, 10), 8.0, Color(0.15, 0.15, 0.15))
	draw_circle(Vector2(20, 10), 8.0, Color(0.15, 0.15, 0.15))
	draw_circle(Vector2(-20, 10), 4.0, Color(0.5, 0.5, 0.5))
	draw_circle(Vector2(20, 10), 4.0, Color(0.5, 0.5, 0.5))
	
	# Cart tub
	var tub_pts = PackedVector2Array([
		Vector2(-32, -18),
		Vector2(32, -18),
		Vector2(24, 8),
		Vector2(-24, 8)
	])
	draw_colored_polygon(tub_pts, body_col)
	draw_polyline(tub_pts, Color(0.6, 0.5, 0.35), 2.0)
	
	# Ore crystals inside
	draw_circle(Vector2(-10, -18), 6.0, Color(0.3, 0.8, 0.9))
	draw_circle(Vector2(6, -20), 7.0, Color(0.9, 0.7, 0.2))
	draw_circle(Vector2(16, -16), 5.0, Color(0.8, 0.3, 0.7))

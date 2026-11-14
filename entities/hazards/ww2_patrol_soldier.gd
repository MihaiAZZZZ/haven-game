extends Area2D
class_name WW2PatrolSoldier

signal player_detected()

@export var patrol_left_x: float = 180.0
@export var patrol_right_x: float = 540.0
@export var move_speed: float = 55.0
@export var start_facing_right: bool = true

var _facing_right: bool = true
var _time: float = 0.0
var _is_alerted: bool = false
var _player_inside: GhostPlayer = null
var _turn_timer: float = 0.0

@onready var col_shape: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	_facing_right = start_facing_right

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_collision_polygon()

func _physics_process(delta: float) -> void:
	_time += delta

	if _is_alerted:
		if int(_time * 10.0) % 3 == 0:
			_facing_right = (int(_time * 10.0) / 3) % 2 == 0
			_update_collision_polygon()
	elif _turn_timer > 0.0:
		_turn_timer -= delta
	else:
		if _facing_right:
			position.x += move_speed * delta
			if position.x >= patrol_right_x:
				position.x = patrol_right_x
				_facing_right = false
				_turn_timer = 0.5
				_update_collision_polygon()
		else:
			position.x -= move_speed * delta
			if position.x <= patrol_left_x:
				position.x = patrol_left_x
				_facing_right = true
				_turn_timer = 0.5
				_update_collision_polygon()

	queue_redraw()

	if _player_inside and is_instance_valid(_player_inside):
		if not _player_inside.is_phased and not _is_alerted:
			_trigger_alert()

func _update_collision_polygon() -> void:
	if not col_shape:
		return
	var dir = 1.0 if _facing_right else -1.0

	var points = PackedVector2Array([
		Vector2(-12.0 * dir, -48.0),
		Vector2(12.0 * dir, -48.0),
		Vector2(110.0 * dir, -40.0),
		Vector2(120.0 * dir, 0.0),
		Vector2(12.0 * dir, 0.0),
		Vector2(-12.0 * dir, 0.0)
	])
	col_shape.polygon = points

func _on_body_entered(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_inside = body
		if not body.is_phased and not _is_alerted:
			_trigger_alert()

func _on_body_exited(body: Node2D) -> void:
	if body == _player_inside:
		_player_inside = null

func panic() -> void:
	_is_alerted = true
	queue_redraw()

func _trigger_alert() -> void:
	if _is_alerted:
		return
	_is_alerted = true
	AudioSynth.play_alarm()
	player_detected.emit()

func _draw() -> void:
	var ink = Color(0.1, 0.08, 0.12, 1.0)
	var dir = 1.0 if _facing_right else -1.0
	var p = 2.0

	var beam_col = Color(1.0, 0.25, 0.25, 0.4) if _is_alerted else Color(1.0, 0.95, 0.65, 0.22)
	var beam_core = Color(1.0, 0.4, 0.4, 0.6) if _is_alerted else Color(1.0, 1.0, 0.85, 0.35)

	var flashlight_hand = Vector2(8.0 * dir, -26.0)
	var beam_end_top = Vector2(110.0 * dir, -38.0)
	var beam_end_bot = Vector2(120.0 * dir, 0.0)

	draw_colored_polygon(PackedVector2Array([flashlight_hand, beam_end_top, beam_end_bot]), beam_col)
	draw_line(flashlight_hand, (beam_end_top + beam_end_bot) * 0.5, beam_core, 2.0)

	var walk_cycle = int(fmod(_time * 7.0, 4.0)) if _turn_timer <= 0.0 else 0
	var leg_offset_1 = 0.0
	var leg_offset_2 = 0.0
	match walk_cycle:
		0: leg_offset_1 = 3.0; leg_offset_2 = -3.0
		1: leg_offset_1 = 0.0; leg_offset_2 = 0.0
		2: leg_offset_1 = -3.0; leg_offset_2 = 3.0
		3: leg_offset_1 = 0.0; leg_offset_2 = 0.0

	var boot_col = Color(0.12, 0.11, 0.14)
	draw_rect(Rect2(-7.0 * p + leg_offset_1 * dir, -12.0 * p, 4.0 * p, 12.0 * p), boot_col)
	draw_rect(Rect2(2.0 * p + leg_offset_2 * dir, -12.0 * p, 4.0 * p, 12.0 * p), boot_col)

	var coat_col = Color(0.24, 0.28, 0.26)
	var coat_shadow = Color(0.16, 0.18, 0.17)
	draw_rect(Rect2(-8.0 * p, -24.0 * p, 16.0 * p, 14.0 * p), coat_col)
	draw_rect(Rect2(-8.0 * p, -14.0 * p, 16.0 * p, 4.0 * p), coat_shadow)
	draw_rect(Rect2(-8.0 * p, -24.0 * p, 16.0 * p, 14.0 * p), ink, false, p)

	draw_rect(Rect2(-8.0 * p, -17.0 * p, 16.0 * p, 2.0 * p), Color(0.25, 0.15, 0.1))
	draw_rect(Rect2(-p, -17.0 * p, 2.0 * p, 2.0 * p), Color(0.85, 0.75, 0.35))

	var skin_col = Color(0.88, 0.72, 0.6)
	var helmet_col = Color(0.3, 0.34, 0.33)
	var helmet_rim = Color(0.18, 0.2, 0.19)
	var helmet_highlight = Color(0.48, 0.54, 0.52)

	draw_rect(Rect2(-5.0 * p, -28.0 * p, 10.0 * p, 5.0 * p), skin_col)
	var eye_x = 1.0 * dir if _facing_right else -3.0 * p
	draw_rect(Rect2(eye_x, -26.0 * p, 2.0 * p, 2.0 * p), ink)

	draw_rect(Rect2(-7.0 * p, -33.0 * p, 14.0 * p, 6.0 * p), helmet_col)
	draw_rect(Rect2(-6.0 * p, -34.0 * p, 12.0 * p, 2.0 * p), helmet_highlight)
	draw_rect(Rect2(-9.0 * p, -29.0 * p, 18.0 * p, 2.0 * p), helmet_rim)
	draw_rect(Rect2(-9.0 * p, -34.0 * p, 18.0 * p, 7.0 * p), ink, false, p)

	var arm_col = coat_col
	draw_rect(Rect2(4.0 * dir - 2.0 * p, -24.0 * p, 4.0 * p, 6.0 * p), arm_col)
	draw_rect(Rect2(flashlight_hand.x - p, flashlight_hand.y - p, 4.0 * p, 3.0 * p), Color(0.15, 0.15, 0.18))
	draw_rect(Rect2(flashlight_hand.x + 2.0 * dir, flashlight_hand.y - 2.0 * p, 2.0 * p, 4.0 * p), Color(1.0, 0.95, 0.5))

	if _is_alerted:
		draw_rect(Rect2(-3.0 * p, -42.0 * p, 6.0 * p, 7.0 * p), Color(0.95, 0.2, 0.2))
		draw_rect(Rect2(-p, -40.0 * p, 2.0 * p, 3.0 * p), Color.WHITE)
		draw_rect(Rect2(-p, -36.0 * p, 2.0 * p, 1.0 * p), Color.WHITE)
		draw_rect(Rect2(-3.0 * p, -42.0 * p, 6.0 * p, 7.0 * p), ink, false, p)

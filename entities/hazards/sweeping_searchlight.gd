extends Area2D
class_name SweepingSearchlight

## SweepingSearchlight: WWII military warehouse surveillance searchlight.
## Sweeps a beam of light across platforms and floors.
## In physical mode, entering the light trips the alarm!
## In Ghost Mode (Phased), Corin is an ethereal wisp and slips through undetected!

signal player_detected()

@export var sweep_angle: float = 35.0 # Degrees left/right from base
@export var sweep_speed: float = 1.1
@export var base_angle: float = 90.0 # 90 deg = straight down
@export var beam_length: float = 380.0
@export var beam_spread: float = 55.0 # Half-width at beam end

var _time: float = 0.0
var _current_angle: float = 90.0
var _is_alerted: bool = false
var _player_inside: GhostPlayer = null

@onready var col_polygon: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_current_angle = base_angle
	_update_beam_geometry()

func _physics_process(delta: float) -> void:
	_time += delta
	if not _is_alerted:
		# Smooth sinusoidal back-and-forth sweep
		var offset = sin(_time * sweep_speed) * sweep_angle
		_current_angle = base_angle + offset
	else:
		# Rapid frantic jitter when alerted
		_current_angle = base_angle + sin(_time * 18.0) * 8.0
		
	_update_beam_geometry()
	queue_redraw()
	
	# Check if player inside has manifested physically
	if _player_inside and is_instance_valid(_player_inside):
		if not _player_inside.is_phased and not _is_alerted:
			_trigger_alert()

func _update_beam_geometry() -> void:
	var rad = deg_to_rad(_current_angle)
	var dir = Vector2(cos(rad), sin(rad))
	var normal = Vector2(-dir.y, dir.x)
	
	var apex = Vector2.ZERO
	var end_center = dir * beam_length
	var end_left = end_center - normal * beam_spread
	var end_right = end_center + normal * beam_spread
	
	if col_polygon:
		col_polygon.polygon = PackedVector2Array([apex, end_left, end_right])

func _on_body_entered(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_inside = body
		if not body.is_phased and not _is_alerted:
			_trigger_alert()

func _on_body_exited(body: Node2D) -> void:
	if body == _player_inside:
		_player_inside = null

func _trigger_alert() -> void:
	_is_alerted = true
	AudioSynth.play_alarm()
	player_detected.emit()

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	var iron = Color(0.32, 0.30, 0.38, 1.0)
	var rad = deg_to_rad(_current_angle)
	var dir = Vector2(cos(rad), sin(rad))
	var normal = Vector2(-dir.y, dir.x)
	
	var apex = Vector2.ZERO
	var end_center = dir * beam_length
	var end_left = end_center - normal * beam_spread
	var end_right = end_center + normal * beam_spread
	
	# 1. Light Cone
	var beam_col: Color
	if _is_alerted:
		var flash = 0.5 + 0.35 * sin(_time * 16.0)
		beam_col = Color(1.0, 0.2, 0.2, flash)
	else:
		beam_col = Color(1.0, 0.94, 0.65, 0.26)
		
	var pts = PackedVector2Array([apex, end_left, end_right])
	draw_colored_polygon(pts, beam_col)
	
	# Beam edge highlights
	draw_line(apex, end_left, Color(beam_col.r, beam_col.g, beam_col.b, 0.5), 1.5)
	draw_line(apex, end_right, Color(beam_col.r, beam_col.g, beam_col.b, 0.5), 1.5)
	
	# 2. Spotlight Cast-Iron Housing (Industrial Swivel Fixture)
	# Fixture base
	draw_rect(Rect2(-12, -8, 24, 6), ink)
	draw_rect(Rect2(-10, -7, 20, 4), iron)
	
	# Rotated lamp cone
	var lamp_tip = dir * 14.0
	var lamp_left = -normal * 12.0
	var lamp_right = normal * 12.0
	var lamp_pts = PackedVector2Array([Vector2.ZERO, lamp_left, lamp_tip, lamp_right])
	draw_colored_polygon(lamp_pts, iron)
	draw_polyline(lamp_pts, ink, 2.0)
	
	# Bright lens
	var lens_col = Color(1.0, 0.3, 0.3) if _is_alerted else Color(1.0, 0.98, 0.8)
	draw_line(lamp_left, lamp_right, lens_col, 3.0)

extends Area2D
class_name InteractiveSwitch

## InteractiveSwitch: Physical mechanism (lever, gear crank, pressure plate).
## Requires physical (manifested) ghost presence. Clean, emoji-free prompts.

signal toggled(is_active: bool)

enum SwitchType { LEVER, PRESSURE_PLATE, GEAR_CRANK }

@export var switch_type: SwitchType = SwitchType.LEVER
@export var is_active: bool = false
@export var is_reusable: bool = true
@export var prompt_text: String = "Activeaza Mecanismul"

var _player_inside: GhostPlayer = null
var _time: float = 0.0

@onready var prompt_label: Label = %PromptLabel

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_prompt()

func _process(delta: float) -> void:
	_time += delta
	_update_prompt()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if _player_inside and not is_active:
		if event.is_action_pressed("interact"):
			if not _player_inside.is_phased:
				trigger_switch()
			else:
				_flash_prompt_warning()

func _on_body_entered(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_inside = body
		if switch_type == SwitchType.PRESSURE_PLATE and not body.is_phased:
			trigger_switch()

func _on_body_exited(body: Node2D) -> void:
	if body == _player_inside:
		_player_inside = null

func trigger_switch() -> void:
	is_active = not is_active
	AudioSynth.play_switch()
	toggled.emit(is_active)
	
	var tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.15, 0.85), 0.1)
	tw.tween_property(self, "scale", Vector2.ONE, 0.25)
	
	_update_prompt()

func _flash_prompt_warning() -> void:
	if prompt_label:
		prompt_label.text = "[Shift] De-fazeaza pentru atingere"
		prompt_label.modulate = Color(0.95, 0.35, 0.35)
		var tw = create_tween()
		tw.tween_property(prompt_label, "modulate", Color(0.14, 0.1, 0.16), 0.6)

func _update_prompt() -> void:
	if prompt_label:
		if _player_inside and not is_active:
			prompt_label.visible = true
			if _player_inside.is_phased:
				prompt_label.text = "[E] Necesita forma fizica"
			else:
				prompt_label.text = "[E] " + prompt_text
		else:
			prompt_label.visible = false

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	var base_col = Color(0.48, 0.38, 0.3) # Warm wood/metal
	var active_col = Color(0.88, 0.72, 0.28) if is_active else Color(0.65, 0.35, 0.28)
	var p = 2.0 # Pixel scale
	
	if switch_type == SwitchType.LEVER:
		# Pixel base box
		draw_rect(Rect2(-16, -6, 32, 12), ink)
		draw_rect(Rect2(-14, -4, 28, 8), base_col)
		var angle = -0.55 if not is_active else 0.55
		var arm_end = Vector2(sin(angle) * 22, -cos(angle) * 22)
		draw_line(Vector2(0, 0), arm_end, ink, 4.0)
		draw_line(Vector2(0, 0), arm_end, Color(0.85, 0.82, 0.78), 2.0)
		# Pixel square knob
		draw_rect(Rect2(arm_end.x - 6, arm_end.y - 6, 12, 12), ink)
		draw_rect(Rect2(arm_end.x - 4, arm_end.y - 4, 8, 8), active_col)
	elif switch_type == SwitchType.GEAR_CRANK:
		var r = 16.0
		# Stepped pixel gear
		draw_rect(Rect2(-r - 4, -r - 4, (r + 4) * 2, (r + 4) * 2), ink)
		draw_rect(Rect2(-r, -r, r * 2, r * 2), Color(0.72, 0.54, 0.24))
		draw_rect(Rect2(-8, -8, 16, 16), ink)
		draw_rect(Rect2(-5, -5, 10, 10), active_col)
	else:
		var plate_h = 4.0 if is_active else 9.0
		draw_rect(Rect2(-24, -plate_h, 48, plate_h), ink)
		draw_rect(Rect2(-22, -plate_h + 2, 44, plate_h - 2), active_col)
		draw_rect(Rect2(-28, 0, 56, 6), ink)
		draw_rect(Rect2(-26, 1, 52, 4), base_col)

extends CharacterBody2D
class_name GhostPlayer

signal phased_changed(is_phased: bool)

@export_group("Movement")
@export var move_speed: float = 230.0
@export var acceleration: float = 1400.0
@export var friction: float = 1200.0
@export var air_acceleration: float = 1100.0
@export var air_friction: float = 400.0

@export_group("Jump & Float (Normal Mode)")
@export var jump_height: float = 95.0
@export var jump_time_to_peak: float = 0.36
@export var jump_time_to_descent: float = 0.32
@export var variable_jump: bool = true
@export var float_gravity_mult: float = 0.35
@export var coyote_time: float = 0.14
@export var jump_buffer: float = 0.16
@export var normal_max_fall_speed: float = 650.0

@export_group("Ghost Mode (Phased) Physics")
@export var phased_jump_height: float = 160.0
@export var phased_jump_time_to_peak: float = 0.42
@export var phased_fall_gravity_mult: float = 0.18
@export var phased_max_fall_speed: float = 115.0

var jump_velocity: float = 0.0
var jump_gravity: float = 0.0
var fall_gravity: float = 0.0
var phased_jump_velocity: float = 0.0
var phased_jump_gravity: float = 0.0

var is_phased: bool = false
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _drop_through_timer: float = 0.0
var _is_jumping: bool = false
var _facing_direction: float = 1.0

var _float_time: float = 0.0
var _squash_stretch: Vector2 = Vector2.ONE
var _carried_item: Node2D = null

@onready var trail_particles: CPUParticles2D = %TrailParticles
@onready var aura_light: PointLight2D = %AuraLight
@onready var visual_root: Node2D = %VisualRoot

func _ready() -> void:
	_recalculate_kinematics()
	collision_layer = 2
	_update_collision_mask()

func _update_collision_mask() -> void:
	var mask: int = 1
	if not is_phased:
		mask |= 4
	if _drop_through_timer <= 0.0:
		mask |= 16
	collision_mask = mask

func _recalculate_kinematics() -> void:
	jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
	jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
	fall_gravity = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

	phased_jump_velocity = ((2.0 * phased_jump_height) / phased_jump_time_to_peak) * -1.0
	phased_jump_gravity = ((-2.0 * phased_jump_height) / (phased_jump_time_to_peak * phased_jump_time_to_peak)) * -1.0

func _physics_process(delta: float) -> void:
	_float_time += delta * 4.0
	if _drop_through_timer > 0.0:
		_drop_through_timer -= delta
		if _drop_through_timer <= 0.0:
			_update_collision_mask()

	_handle_phase_input()
	_handle_jump_logic(delta)
	_handle_movement(delta)
	move_and_slide()
	_update_visuals(delta)

func _handle_phase_input() -> void:
	if Input.is_action_just_pressed("phase"):
		toggle_phase()

func toggle_phase() -> void:
	set_phased(not is_phased)

func set_phased(phased: bool) -> void:
	if is_phased == phased:
		return
	is_phased = phased
	_update_collision_mask()

	if is_phased:
		AudioSynth.play_phase(true)
	else:
		AudioSynth.play_phase(false)

	phased_changed.emit(is_phased)

func _handle_jump_logic(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
		if _is_jumping:
			_is_jumping = false
			_apply_squash(Vector2(1.25, 0.78))
	else:
		_coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("move_down") and is_on_floor():
			_drop_through_timer = 0.22
			_update_collision_mask()
			velocity.y = 70.0
			_jump_buffer_timer = 0.0
			_coyote_timer = 0.0
			return
		else:
			_jump_buffer_timer = jump_buffer
	else:
		_jump_buffer_timer -= delta

	if _jump_buffer_timer > 0.0 and (_coyote_timer > 0.0 or is_on_floor()):
		velocity.y = phased_jump_velocity if is_phased else jump_velocity
		_is_jumping = true
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_apply_squash(Vector2(0.7, 1.45) if is_phased else Vector2(0.75, 1.35))
		AudioSynth.play_jump()

	if variable_jump and Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

	var current_gravity: float
	if velocity.y < 0.0:
		current_gravity = phased_jump_gravity if is_phased else jump_gravity
	else:
		if is_phased:
			current_gravity = fall_gravity * phased_fall_gravity_mult
			if Input.is_action_pressed("jump"):
				current_gravity *= 0.75
		elif Input.is_action_pressed("jump"):
			current_gravity = fall_gravity * float_gravity_mult
		else:
			current_gravity = fall_gravity

	velocity.y += current_gravity * delta

	if is_phased:
		var target_terminal = phased_max_fall_speed
		if Input.is_action_pressed("jump"):
			target_terminal *= 0.75
		if velocity.y > target_terminal:
			velocity.y = move_toward(velocity.y, target_terminal, 850.0 * delta)
	elif velocity.y > normal_max_fall_speed:
		velocity.y = normal_max_fall_speed

func _handle_movement(delta: float) -> void:
	var input_x = Input.get_axis("move_left", "move_right")
	var target_speed = input_x * move_speed

	if input_x != 0.0:
		_facing_direction = sign(input_x)

	var is_grounded = is_on_floor()
	var accel = acceleration if is_grounded else air_acceleration
	var fric = friction if is_grounded else air_friction

	if is_phased and not is_grounded:
		accel = air_acceleration * 1.2
		fric = air_friction * 0.7

	if input_x != 0.0:
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

func _apply_squash(target: Vector2) -> void:
	_squash_stretch = target
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_squash_stretch", Vector2.ONE, 0.25)

func _update_visuals(delta: float) -> void:
	if visual_root:
		var bob_offset = sin(_float_time) * (4.0 if not is_phased else 7.0)
		visual_root.position.y = bob_offset
		visual_root.scale.x = lerp(visual_root.scale.x, _facing_direction * _squash_stretch.x, 20.0 * delta)
		visual_root.scale.y = lerp(visual_root.scale.y, _squash_stretch.y, 20.0 * delta)

		if is_phased and not is_on_floor():
			var tilt_angle = sin(_float_time * 0.8) * 0.08
			if velocity.x != 0.0:
				tilt_angle += sign(velocity.x) * 0.08
			visual_root.rotation = lerp(visual_root.rotation, tilt_angle, 10.0 * delta)
		else:
			visual_root.rotation = lerp(visual_root.rotation, 0.0, 15.0 * delta)

		var target_color = Color(0.7, 0.95, 1.0, 0.6) if is_phased else Color(0.95, 1.0, 1.0, 0.95)
		visual_root.modulate = visual_root.modulate.lerp(target_color, 12.0 * delta)

	if trail_particles:
		trail_particles.emitting = abs(velocity.x) > 20.0 or abs(velocity.y) > 20.0 or is_phased
		if is_phased:
			trail_particles.color = Color(0.35, 0.9, 1.0, 0.7)
		else:
			trail_particles.color = Color(0.9, 0.95, 1.0, 0.5)

func carry_item(item: Node2D) -> void:
	_carried_item = item
	if item.get_parent():
		item.get_parent().remove_child(item)
	visual_root.add_child(item)
	item.position = Vector2(0, -32)

func drop_item() -> Node2D:
	if _carried_item == null:
		return null
	var item = _carried_item
	visual_root.remove_child(item)
	_carried_item = null
	return item

func has_carried_item() -> bool:
	return _carried_item != null

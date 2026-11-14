extends Area2D
class_name GhostMother

signal dialogue_started()
signal dialogue_finished()

var dialogue_pages: Array[String] = [
	"Corin, sufletul meu drag... Ai gasit prima bucata din Colier! Simteam ca nu ai uitat de noi.",
	"A doua bucata din colier, amuleta mea de aur, am ascuns-o sus printre grinzile inalte ale casei...",
	"Foloseste-ti plutirea spectrala pentru a urca pe rafturi si adu piesa din colier, puiule!"
]

var _current_page: int = 0
var _is_dialogue_open: bool = false
var _player_in_range: bool = false
var _time: float = 0.0

@onready var prompt_container: Node2D = %PromptContainer
@onready var dialogue_box: CanvasLayer = %DialogueBox
@onready var dialogue_text: Label = %DialogueText
@onready var continue_prompt: Label = %ContinuePrompt
@onready var speaker_name_label: Label = %SpeakerNameLabel

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if prompt_container:
		prompt_container.visible = false
	if dialogue_box:
		dialogue_box.visible = false

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return

	if event.is_action_pressed("interact") and not event.is_echo():
		if _is_dialogue_open:
			_advance_dialogue()
		else:
			_start_dialogue()
		get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_in_range = true
		if prompt_container and not _is_dialogue_open:
			prompt_container.visible = true
			prompt_container.scale = Vector2.ZERO
			var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(prompt_container, "scale", Vector2.ONE, 0.2)

func _on_body_exited(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_in_range = false
		if prompt_container:
			prompt_container.visible = false
		if _is_dialogue_open:
			_close_dialogue()

func _start_dialogue() -> void:
	_is_dialogue_open = true
	_current_page = 0
	if prompt_container:
		prompt_container.visible = false

	AudioSynth.play_chime(1.1)
	dialogue_started.emit()
	_update_dialogue_display()

	if dialogue_box:
		dialogue_box.visible = true

func _advance_dialogue() -> void:
	_current_page += 1
	AudioSynth.play_click()

	if _current_page >= dialogue_pages.size():
		_close_dialogue()
		dialogue_finished.emit()
	else:
		_update_dialogue_display()

func _close_dialogue() -> void:
	_is_dialogue_open = false
	if dialogue_box:
		dialogue_box.visible = false
	if _player_in_range and prompt_container:
		prompt_container.visible = true

func _update_dialogue_display() -> void:
	if not dialogue_text or not continue_prompt:
		return

	dialogue_text.text = dialogue_pages[_current_page]
	if _current_page >= dialogue_pages.size() - 1:
		continue_prompt.text = "[E] Incepe Cautarea"
	else:
		continue_prompt.text = "[E] Continua"

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	var p = 2.5

	var bob_y = sin(_time * 2.8) * 4.0
	var ox = -10.0 * p
	var oy = -28.0 * p + bob_y

	var col_fill = Color(0.96, 0.92, 0.98, 0.95)
	var col_shad = Color(0.82, 0.76, 0.90, 0.95)
	var blush_col = Color(0.96, 0.65, 0.72, 1.0)

	var aura_size = 28.0 * p + sin(_time * 3.5) * 4.0
	draw_rect(Rect2(-aura_size * 0.5, oy + 8.0 * p, aura_size, aura_size), Color(0.85, 0.75, 1.0, 0.18))

	draw_rect(Rect2(ox + 4 * p, oy, 12 * p, 4 * p), ink)
	draw_rect(Rect2(ox + 2 * p, oy + 3 * p, 16 * p, 12 * p), ink)
	draw_rect(Rect2(ox + 5 * p, oy + 1 * p, 10 * p, 3 * p), col_fill)
	draw_rect(Rect2(ox + 3 * p, oy + 4 * p, 14 * p, 10 * p), col_fill)

	draw_rect(Rect2(ox + 2 * p, oy + 12 * p, 4 * p, 6 * p), col_shad)
	draw_rect(Rect2(ox + 14 * p, oy + 12 * p, 4 * p, 6 * p), col_shad)

	draw_rect(Rect2(ox + 3 * p, oy + 14 * p, 14 * p, 9 * p), ink)
	draw_rect(Rect2(ox + 4 * p, oy + 14 * p, 12 * p, 8 * p), col_fill)
	draw_rect(Rect2(ox + 4 * p, oy + 18 * p, 12 * p, 4 * p), col_shad)

	var hem_offset = int(sin(_time * 4.0) * 1.5) * p
	draw_rect(Rect2(ox + 3 * p, oy + 22 * p + hem_offset, 14 * p, 3 * p), ink)
	draw_rect(Rect2(ox + 4 * p, oy + 22 * p + hem_offset, 12 * p, 2 * p), col_fill)

	var eye_y = oy + 7 * p
	draw_rect(Rect2(ox + 6 * p, eye_y, 2 * p, 3 * p), Color.WHITE)
	draw_rect(Rect2(ox + 6 * p, eye_y + 1 * p, 2 * p, 2 * p), ink)
	draw_rect(Rect2(ox + 5 * p, eye_y - 1 * p, 3 * p, 1 * p), ink)
	draw_rect(Rect2(ox + 12 * p, eye_y, 2 * p, 3 * p), Color.WHITE)
	draw_rect(Rect2(ox + 12 * p, eye_y + 1 * p, 2 * p, 2 * p), ink)
	draw_rect(Rect2(ox + 12 * p, eye_y - 1 * p, 3 * p, 1 * p), ink)

	draw_rect(Rect2(ox + 4 * p, oy + 10 * p, 2 * p, 1 * p), blush_col)
	draw_rect(Rect2(ox + 14 * p, oy + 10 * p, 2 * p, 1 * p), blush_col)

	draw_rect(Rect2(ox + 9 * p, oy + 11 * p, 2 * p, 1 * p), ink)

	for i in range(3):
		var t = fmod(_time * 2.0 + i * 0.9, 1.0)
		var sx = ox + (sin(i * 3.0 + _time * 2.0) * 14.0 + 10.0) * p
		var sy = oy + (24.0 - t * 26.0) * p
		draw_rect(Rect2(sx, sy, p, p), Color(0.9, 0.75, 1.0, 1.0 - t))

extends Area2D
class_name GhostOrigin

signal dialogue_started()
signal dialogue_finished()

var dialogue_pages: Array[String] = [
	"Corin, micul meu suflet călător... Ai refăcut firul amintirilor noastre și ai adus cele trei bucăți ale colierului.",
	"Mulți din familie au crezut că o forță malefică ne-a blestemat neamul... Dar adevărul este mult mai dureros. Eu am fost cea care a făcut-o.",
	"L-am vrăjit acum un veac din pură dragoste. Voiam cu disperare să protejez toate femeile și copiii acestei familii de durere și moarte...",
	"Dar magia a lovit înapoi teribil. În loc să vă ocrotească, dragostea mea v-a ferecat sufletele în această lume, prinzându-ne în regrete și risipind colierul prin timp.",
	"Doar tu poți repara greșeala mea. Așază cele 3 piese pe Altarul Originii pentru a uni colierul o ultimă dată și a risipi vraja!"
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
	position.y += sin(_time * 2.4) * 0.35
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
	if not dialogue_text:
		return

	dialogue_text.text = dialogue_pages[_current_page]

	if continue_prompt:
		if _current_page == dialogue_pages.size() - 1:
			continue_prompt.text = "[E] Închide dialogul și asamblează colierul"
		else:
			continue_prompt.text = "[E] Continuă (" + str(_current_page + 1) + "/" + str(dialogue_pages.size()) + ")"

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	var p = 2.0
	var pulse = 1.0 + 0.08 * sin(_time * 3.5)

	var aura_size = 28.0 * pulse
	draw_rect(Rect2(-aura_size * 0.5, -aura_size * 0.5 - 20.0, aura_size, aura_size * 1.3), Color(0.78, 0.65, 0.95, 0.22))
	draw_rect(Rect2(-aura_size * 0.35, -aura_size * 0.35 - 20.0, aura_size * 0.7, aura_size), Color(0.98, 0.85, 0.40, 0.18))

	draw_rect(Rect2(-8, -44, 16, 10), ink)
	draw_rect(Rect2(-6, -42, 12, 6), Color(0.85, 0.82, 0.92))
	draw_rect(Rect2(-4, -46, 8, 3), Color(0.98, 0.85, 0.35))

	draw_rect(Rect2(-12, -34, 24, 22), ink)
	draw_rect(Rect2(-10, -32, 20, 18), Color(0.96, 0.94, 0.98))

	draw_rect(Rect2(-6, -26, 4, 5), ink)
	draw_rect(Rect2(2, -26, 4, 5), ink)
	draw_rect(Rect2(-5, -25, 2, 2), Color.WHITE)
	draw_rect(Rect2(3, -25, 2, 2), Color.WHITE)

	draw_rect(Rect2(-8, -20, 4, 2), Color(0.95, 0.65, 0.75, 0.8))
	draw_rect(Rect2(4, -20, 4, 2), Color(0.95, 0.65, 0.75, 0.8))

	draw_rect(Rect2(-4, -13, 8, 6), ink)
	draw_rect(Rect2(-3, -12, 6, 4), Color(0.98, 0.82, 0.30))
	draw_rect(Rect2(-1, -11, 2, 2), Color(0.95, 0.25, 0.35))

	draw_rect(Rect2(-16, -10, 32, 26), ink)
	draw_rect(Rect2(-14, -8, 28, 22), Color(0.90, 0.86, 0.96))

	for i in range(5):
		var fx = -14 + i * 6
		var fy = 14 + int(sin(_time * 4.0 + i) * 2.0)
		draw_rect(Rect2(fx, fy, 4, 6), ink)
		draw_rect(Rect2(fx + 1, fy + 1, 2, 4), Color(0.96, 0.94, 0.98))

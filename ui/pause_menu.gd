extends CanvasLayer
class_name PauseMenu

signal resumed()

@onready var modal_panel: PanelContainer = %ModalPanel
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var tree_hub_button: Button = %TreeHubButton

var is_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 150
	visible = false

	if resume_button:
		resume_button.pressed.connect(resume_game)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if tree_hub_button:
		tree_hub_button.pressed.connect(_on_tree_hub_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			toggle_pause()
			get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	visible = true
	AudioSynth.play_click()

	_update_menu_context()

	if modal_panel:
		modal_panel.scale = Vector2(0.9, 0.9)
		modal_panel.modulate.a = 0.0
		var tw = create_tween().set_parallel(true).set_ignore_time_scale(true)
		tw.tween_property(modal_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(modal_panel, "modulate:a", 1.0, 0.15)

func _update_menu_context() -> void:
	var current_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	var is_at_tree_hub = (current_path == GameManager.TREE_HUB_SCENE)

	if tree_hub_button:
		tree_hub_button.visible = true
		tree_hub_button.text = "Inapoi la Arbore"

	if restart_button:
		if is_at_tree_hub:
			restart_button.text = "Restart"
		else:
			restart_button.text = "Reincearca Nivelul"

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	visible = false
	AudioSynth.play_click()
	resumed.emit()

func _on_restart_pressed() -> void:
	AudioSynth.play_click()
	resume_game()
	get_tree().reload_current_scene()

func _on_tree_hub_pressed() -> void:
	AudioSynth.play_click()
	resume_game()
	GameManager.go_to_tree_hub()

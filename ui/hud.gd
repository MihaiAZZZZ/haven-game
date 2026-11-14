extends CanvasLayer
class_name HUD

## Minimalist HUD: Only a small transparent pause button in the corner.

@onready var pause_button: Button = %PauseButton

var pause_menu: CanvasLayer = null

func _ready() -> void:
	layer = 50
	if get_parent():
		pause_menu = get_parent().get_node_or_null("PauseMenu") as CanvasLayer
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

func _on_pause_pressed() -> void:
	if pause_menu:
		pause_menu.toggle_pause()
	else:
		var pm = get_tree().root.find_child("PauseMenu", true, false) as PauseMenu
		if pm:
			pm.toggle_pause()

# Safe no-ops for existing level scripts
func setup_level(_title: String, _objective: String) -> void:
	pass

func update_objective(_objective: String) -> void:
	pass

func set_phased_state(_is_phased: bool) -> void:
	pass

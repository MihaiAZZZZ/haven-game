extends CanvasLayer
class_name MemoryCompleteDialog

## Clean, minimalist completion modal when an ancestor's memory is healed.

@onready var ancestor_name_label: Label = %AncestorNameLabel
@onready var unlock_notice_label: Label = %UnlockNoticeLabel
@onready var continue_button: Button = %ContinueButton
@onready var modal_panel: PanelContainer = %ModalPanel

var _ancestor_id: String = ""

func _ready() -> void:
	layer = 120
	visible = false
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)

func show_completion(ancestor_id: String) -> void:
	_ancestor_id = ancestor_id
	var ancestor = GameManager.get_ancestor(ancestor_id)
	if not ancestor:
		return
		
	GameManager.mark_memory_solved(ancestor_id)
	AudioSynth.play_fanfare()
	
	if ancestor_name_label:
		ancestor_name_label.text = ancestor.name + " (" + ancestor.relation + ")"
		
	if unlock_notice_label:
		if GameManager.are_all_memories_solved():
			unlock_notice_label.text = "Colierul este întregit! Toate amintirile au fost vindecate."
			unlock_notice_label.modulate = Color(0.98, 0.85, 0.35)
		else:
			var piece_num = 1
			if ancestor_id == "corin":
				piece_num = 1
			elif ancestor_id == "mama":
				piece_num = 2
			elif ancestor_id == "bunica":
				piece_num = 3
			unlock_notice_label.text = "Piesa " + str(piece_num) + " din colier a fost recuperată!"
			unlock_notice_label.modulate = Color(0.45, 0.85, 0.58)
			
	visible = true
	modal_panel.scale = Vector2(0.85, 0.85)
	modal_panel.modulate.a = 0.0
	
	var tw = create_tween().set_parallel(true).set_ignore_time_scale(true)
	tw.tween_property(modal_panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(modal_panel, "modulate:a", 1.0, 0.2)

func _on_continue_pressed() -> void:
	AudioSynth.play_click()
	GameManager.go_to_tree_hub()

extends MemoryBase

## Level 3: Sanctuarul Originii (Străbunica Victoria)
## Setting: Mystical ancient Gothic sanctuary with stained glass rose window and ancestral altar.
## Lore Twist: The curse was created out of deep love to protect the family women, but backfired.
## Climax: Speak with the Original Owner, complete the final assembly puzzle on the Altar,
## and experience the emotional cutscene where the curse breaks and all souls ascend to Haven.

@onready var origin_matriarch: Area2D = %GhostOrigin
@onready var ancestral_altar: Area2D = %AncestralAltar
@onready var cutscene_layer: CanvasLayer = %CutsceneLayer
@onready var cutscene_panel: PanelContainer = %CutscenePanel
@onready var cutscene_speaker: Label = %CutsceneSpeaker
@onready var cutscene_text: Label = %CutsceneText
@onready var cutscene_prompt: Label = %CutscenePrompt
@onready var cutscene_spirits: Node2D = %CutsceneSpirits

var _cutscene_step: int = 0
var _cutscene_active: bool = false
var _spirits_alpha: float = 0.0

var cutscene_lines: Array[Dictionary] = [
	{
		"speaker": "Străbunica Victoria",
		"color": Color(0.98, 0.85, 0.35),
		"text": "Privește colierul cum strălucește din nou întreg! Blestemul iubirii este în sfârșit rupt... Vraja s-a risipit, iar lanțurile regretelor s-au sfărâmat."
	},
	{
		"speaker": "Mama (Maria)",
		"color": Color(0.45, 0.85, 0.55),
		"text": "Corin, micul meu suflet viteaz... Ai străbătut veacurile pentru noi. Ai vindecat toate durerile noastre. Nu mai există frică, nici suferință."
	},
	{
		"speaker": "Bunica Elena",
		"color": Color(0.95, 0.40, 0.50),
		"text": "Ai adus lumina înapoi în neamul nostru, puiule. Privește porțile cerului cum se deschid larg. În sfârșit, putem merge acasă... În Rai."
	},
	{
		"speaker": "Corin (Tu)",
		"color": Color(0.40, 0.90, 1.0),
		"text": "Colierul ne-a adus din nou împreună. Ne-am găsit rădăcinile... Acum putem zbura."
	}
]

func _setup_memory() -> void:
	ancestor_id = "originea"
	memory_title = "Amintirea 3: Originea (Străbunica Victoria)"
	initial_objective = "Vorbeste cu Strabunica Victoria pentru a afla taina colierului"
	
	if relic:
		relic.visible = false
		relic.set_deferred("monitoring", false)
		
	if origin_matriarch:
		origin_matriarch.dialogue_finished.connect(_on_matriarch_dialogue_finished)
		
	if ancestral_altar:
		ancestral_altar.piece_placed.connect(_on_altar_piece_placed)
		ancestral_altar.puzzle_completed.connect(_on_altar_puzzle_completed)
		
	if cutscene_layer:
		cutscene_layer.visible = false
	if cutscene_spirits:
		cutscene_spirits.modulate.a = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not _cutscene_active:
		return
	if (event.is_action_pressed("interact") or event.is_action_pressed("jump") or (event is InputEventMouseButton and event.pressed)) and not event.is_echo():
		_advance_cutscene()
		get_viewport().set_input_as_handled()

func _on_matriarch_dialogue_finished() -> void:
	if hud:
		hud.update_objective("Apropie-te de Altarul Originii si asaza cele 3 piese din Colier!")
	if ancestral_altar:
		ancestral_altar.activate_altar()

func _on_altar_piece_placed(index: int, piece_name: String) -> void:
	if hud:
		var placed = index + 1
		hud.update_objective("Ai asezat " + piece_name + " (" + str(placed) + "/3 piese unite)!")

func _on_altar_puzzle_completed() -> void:
	if hud:
		hud.update_objective("Colierul este asamblat! Blestemul iubirii a fost rupt!")
		
	# Freeze player during the final cutscene
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
		
	# Trigger Grand Finale Cutscene
	_start_final_cutscene()

func _start_final_cutscene() -> void:
	_cutscene_active = true
	_cutscene_step = 0
	
	if cutscene_layer:
		cutscene_layer.visible = true
	if cutscene_panel:
		cutscene_panel.modulate.a = 0.0
		var tw = create_tween().set_parallel(true)
		tw.tween_property(cutscene_panel, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	if cutscene_spirits:
		var sp_tw = create_tween()
		sp_tw.tween_property(cutscene_spirits, "modulate:a", 1.0, 1.0)
		
	AudioSynth.play_fanfare()
	_update_cutscene_line()

func _advance_cutscene() -> void:
	_cutscene_step += 1
	AudioSynth.play_click()
	
	if _cutscene_step >= cutscene_lines.size():
		_end_final_cutscene()
	else:
		_update_cutscene_line()

func _update_cutscene_line() -> void:
	if not cutscene_speaker or not cutscene_text:
		return
		
	var line = cutscene_lines[_cutscene_step]
	cutscene_speaker.text = line["speaker"]
	cutscene_speaker.add_theme_color_override("font_color", line["color"])
	cutscene_text.text = line["text"]
	
	if cutscene_prompt:
		if _cutscene_step == cutscene_lines.size() - 1:
			cutscene_prompt.text = "[E / Space] Încheie și Eliberează Sufletele"
		else:
			cutscene_prompt.text = "[E / Space] Continuă (" + str(_cutscene_step + 1) + "/" + str(cutscene_lines.size()) + ")"
			
	AudioSynth.play_chime(1.1 + _cutscene_step * 0.1)

func _end_final_cutscene() -> void:
	_cutscene_active = false
	if cutscene_layer:
		cutscene_layer.visible = false
	AudioSynth.play_ascension()
	
	# Mark Originea memory as completely solved in GameManager
	GameManager.mark_memory_solved("originea")
	
	if complete_dialog:
		complete_dialog.show_completion("originea")

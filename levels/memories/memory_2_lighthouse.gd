extends MemoryBase

@onready var mother_npc: Area2D = %GhostMother

func _setup_memory() -> void:
	ancestor_id = "mama"
	memory_title = "Amintirea 1: Cufarul Mamei"
	initial_objective = "Vorbeste cu Mama pentru a afla povestea cufarului"

	if relic:
		relic.relic_type = MemoryPickup.RelicType.NECKLACE
		relic.relic_name = "Piesa 2 din Colier: Amuleta Mamei"
		relic.relic_color = Color(0.98, 0.85, 0.32)
		relic.visible = false
		relic.set_deferred("monitoring", false)

	if mother_npc:
		mother_npc.dialogue_finished.connect(_on_mother_dialogue_finished)

func _on_mother_dialogue_finished() -> void:
	if hud:
		hud.update_objective("Gaseste Amuleta Mamei din Colier ascunsa sus printre grinzi!")

	if relic:
		relic.visible = true
		relic.position.y = 210.0
		relic.scale = Vector2.ZERO
		relic.set_deferred("monitoring", true)
		AudioSynth.play_fanfare()

		var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(relic, "scale", Vector2.ONE, 0.7)
		tw.tween_property(relic, "position:y", 160.0, 0.7)

func _on_relic_collected() -> void:
	if hud:
		hud.update_objective("Ai recuperat Piesa din Colier a Mamei!")
	if complete_dialog:
		complete_dialog.show_completion("mama")

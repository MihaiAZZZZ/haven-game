extends MemoryBase

## Level 0: Camera cu Ceasuri (Corin - Amintirea Fantomei)
## Setting: An antique clock-filled room in the ancestral house.
## Core mechanic: Vertical climbing, ghost high jump & float, and searching drawers/cupboards
## Goal: Find the lost Ancestral Necklace (Colierul Mamei) hidden in the high attic wardrobe.

var _drawers: Array[InteractiveDrawer] = []
var _searched_count: int = 0
var _necklace_found: bool = false
var _has_brass_key: bool = false

@onready var attic_wardrobe: InteractiveDrawer = %Drawer5_AtticWardrobe
@onready var tutorial_bar: Control = %TutorialBar

func _setup_memory() -> void:
	ancestor_id = "corin"
	memory_title = "Amintirea 0: Camera cu Ceasuri"
	initial_objective = "Cauta cheia mica de alama pentru a descuia dulapul din mansarda!"
	
	if tutorial_bar:
		var tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_interval(12.0)
		tw.tween_property(tutorial_bar, "modulate:a", 0.0, 1.2)
		tw.tween_callback(func():
			if is_instance_valid(tutorial_bar):
				tutorial_bar.visible = false
		)
	
	if relic:
		relic.visible = false
		relic.set_deferred("monitoring", false)
		relic.relic_type = MemoryPickup.RelicType.NECKLACE
		relic.relic_name = "Piesa 1 din Colier: Baza cu Lant"
		relic.relic_color = Color(0.98, 0.82, 0.3)
		
	# Find and connect all interactive drawers in the room
	_drawers.clear()
	for child in get_children():
		if child is InteractiveDrawer:
			_drawers.append(child)
			child.drawer_searched.connect(_on_drawer_searched)
			child.key_found.connect(_on_key_found)
		elif child.has_node("InteractiveDrawer"):
			var d = child.get_node("InteractiveDrawer") as InteractiveDrawer
			if d:
				_drawers.append(d)
				d.drawer_searched.connect(_on_drawer_searched)
				d.key_found.connect(_on_key_found)

func _on_key_found(_drawer: InteractiveDrawer, key_id: String) -> void:
	if key_id == "brass_key":
		_has_brass_key = true
		AudioSynth.play_fanfare()
		if tutorial_bar and tutorial_bar.visible:
			create_tween().tween_property(tutorial_bar, "modulate:a", 0.0, 0.5)
		if hud:
			hud.update_objective("Ai gasit Cheia de Alama! Urca in mansarda si descuie dulapul!")
		if attic_wardrobe:
			attic_wardrobe.unlock()

func _on_drawer_searched(drawer: InteractiveDrawer, found_necklace: bool) -> void:
	_searched_count += 1
	
	if found_necklace and not _necklace_found:
		_necklace_found = true
		_reveal_necklace(drawer)
	else:
		if not _necklace_found:
			if hud:
				if _has_brass_key:
					hud.update_objective("Urca in mansarda si descuie dulapul cel mare!")
				else:
					hud.update_objective("Cauta cheia de alama (" + str(_searched_count) + "/5 piese cercetate)")

func _reveal_necklace(drawer: InteractiveDrawer) -> void:
	AudioSynth.play_chime(1.4)
	if hud:
		hud.update_objective("Ai gasit Colierul! Culege Colierul Stramosesc!")
		
	if relic:
		relic.global_position = drawer.global_position + Vector2(0, -30)
		relic.visible = true
		relic.scale = Vector2.ZERO
		relic.set_deferred("monitoring", true)
		
		# Delightful bounce animation as the necklace pops out of the drawer
		var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(relic, "scale", Vector2.ONE, 0.5)
		tw.tween_property(relic, "position:y", relic.position.y - 45.0, 0.6)

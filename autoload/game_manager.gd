extends Node

signal ancestor_unlocked(ancestor_id: String)
signal memory_completed(ancestor_id: String)
signal tree_updated()
signal ascension_ready()

var ancestors: Dictionary = {}
var current_ancestor_id: String = ""
var last_completed_ancestor_id: String = ""

const TREE_HUB_SCENE: String = "res://levels/tree_hub/family_tree_view.tscn"
const ASCENSION_SCENE: String = "res://levels/haven_ascension/haven_ascension.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input_actions()
	_init_ancestors()

func _setup_input_actions() -> void:
	_register_action("move_left", [KEY_A, KEY_LEFT])
	_register_action("move_right", [KEY_D, KEY_RIGHT])
	_register_action("move_up", [KEY_W, KEY_UP])
	_register_action("move_down", [KEY_S, KEY_DOWN])
	_register_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_register_action("phase", [KEY_SHIFT, KEY_J, KEY_Z])
	_register_action("interact", [KEY_E, KEY_ENTER])
	_register_action("reset_level", [KEY_R])
	_register_action("menu", [KEY_ESCAPE])

func _register_action(action_name: String, keycodes: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for key in keycodes:
		var ev = InputEventKey.new()
		ev.physical_keycode = key
		InputMap.action_add_event(action_name, ev)

func _init_ancestors() -> void:
	var corin = AncestorData.new()
	corin.id = "corin"
	corin.name = "Corin"
	corin.title = "Sufletul Rătăcitor"
	corin.relation = "Tu"
	corin.generation = 0
	corin.tree_position = Vector2(640, 160)
	corin.unlocked = true
	corin.solved = false
	corin.level_scene_path = "res://levels/memories/memory_1_clockmaker.tscn"
	corin.memory_title = "Amintirea 0: Camera cu Ceasuri"
	corin.memory_description = "Găsește cheia mică de alamă pe birou și descuie dulapul din mansardă pentru a recupera prima piesă din colier."
	corin.memory_quote = "\"Prima piesă din colier este aici... Simt legătura familiei trezindu-se.\""
	corin.color_tint = Color(0.4, 0.9, 1.0)
	ancestors["corin"] = corin

	var mama = AncestorData.new()
	mama.id = "mama"
	mama.name = "Maria"
	mama.title = "Mama Iubitoare"
	mama.relation = "Mama"
	mama.generation = 1
	mama.parent_id = "corin"
	mama.tree_position = Vector2(380, 310)
	mama.level_scene_path = "res://levels/memories/memory_2_lighthouse.tscn"
	mama.memory_title = "Amintirea 1: Cufărul Mamei"
	mama.memory_description = "Înfruntă curenții de aer din mansardă și recuperează Amuleta de Aur a Mamei (Piesa 2 din colier)."
	mama.memory_quote = "\"Ai adus a doua piesă a colierului, Corin. Mai lipsește doar piesa ascunsă de Bunica.\""
	mama.unlocked = false
	mama.solved = false
	mama.color_tint = Color(0.95, 0.75, 0.3)
	ancestors["mama"] = mama

	var bunica = AncestorData.new()
	bunica.id = "bunica"
	bunica.name = "Elena"
	bunica.title = "Bunica Vegheatoare"
	bunica.relation = "Bunica"
	bunica.generation = 2
	bunica.parent_id = "mama"
	bunica.tree_position = Vector2(900, 310)
	bunica.level_scene_path = "res://levels/memories/memory_3_miner.tscn"
	bunica.memory_title = "Amintirea 2: Depozitul din WW2"
	bunica.memory_description = "Infiltrează-te în depozitul militar din WW2 în 35 de secunde, evită proiectoarele și recuperează Medalionul cu Rubin."
	bunica.memory_quote = "\"Ai adus a treia piesă! Posesorul originar al colierului te așteaptă la Sanctuarul Străvechi.\""
	bunica.unlocked = false
	bunica.solved = false
	bunica.color_tint = Color(0.85, 0.45, 0.75)
	ancestors["bunica"] = bunica

	var originea = AncestorData.new()
	originea.id = "originea"
	originea.name = "Victoria"
	originea.title = "Posesorul Originar"
	originea.relation = "Străbunica"
	originea.generation = 3
	originea.parent_id = "bunica"
	originea.tree_position = Vector2(640, 480)
	originea.level_scene_path = "res://levels/memories/memory_4_origin.tscn"
	originea.memory_title = "Amintirea 3: Originea Străveche"
	originea.memory_description = "Află taina colierului vrăjit din dragoste, așază piesele pe Altarul Strămoșesc și rupe blestemul neamului."
	originea.memory_quote = "\"Blestemul a fost rupt din iubire... Acum putem merge împreună în Rai.\""
	originea.unlocked = false
	originea.solved = false
	originea.color_tint = Color(0.98, 0.85, 0.35)
	ancestors["originea"] = originea

func get_ancestor(id: String) -> AncestorData:
	return ancestors.get(id, null)

func are_all_memories_solved() -> bool:
	for a_id in ["corin", "mama", "bunica", "originea"]:
		if not ancestors.has(a_id) or not ancestors[a_id].solved:
			return false
	return true

func mark_memory_solved(ancestor_id: String) -> void:
	if not ancestors.has(ancestor_id):
		return

	var a: AncestorData = ancestors[ancestor_id]
	a.solved = true
	last_completed_ancestor_id = ancestor_id

	if ancestor_id == "corin":
		if ancestors.has("mama"):
			ancestors["mama"].unlocked = true
			ancestor_unlocked.emit("mama")
	elif ancestor_id == "mama":
		if ancestors.has("bunica"):
			ancestors["bunica"].unlocked = true
			ancestor_unlocked.emit("bunica")
	elif ancestor_id == "bunica":
		if ancestors.has("originea"):
			ancestors["originea"].unlocked = true
			ancestor_unlocked.emit("originea")
	elif ancestor_id == "originea":
		ascension_ready.emit()

	memory_completed.emit(ancestor_id)
	tree_updated.emit()

func go_to_tree_hub() -> void:
	get_tree().change_scene_to_file(TREE_HUB_SCENE)

func reload_current_memory() -> void:
	get_tree().reload_current_scene()

func go_to_memory(ancestor_id: String) -> void:
	if not ancestors.has(ancestor_id):
		return
	var a: AncestorData = ancestors[ancestor_id]
	if not a.unlocked or a.level_scene_path.is_empty():
		return
	current_ancestor_id = ancestor_id
	get_tree().change_scene_to_file(a.level_scene_path)

func go_to_ascension() -> void:
	get_tree().change_scene_to_file(ASCENSION_SCENE)

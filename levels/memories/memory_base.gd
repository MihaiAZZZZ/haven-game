extends Node2D
class_name MemoryBase

## MemoryBase: Base controller for ancestral puzzle memories.

@export var ancestor_id: String = ""
@export var memory_title: String = "Amintire Strămoșească"
@export var initial_objective: String = "Rezolvă enigma"

@onready var player: GhostPlayer = %GhostPlayer
@onready var hud: HUD = %HUD
@onready var complete_dialog: MemoryCompleteDialog = %MemoryCompleteDialog
@onready var relic: MemoryPickup = %MemoryPickup

func _ready() -> void:
	if hud:
		hud.setup_level(memory_title, initial_objective)
		if player:
			hud.set_phased_state(player.is_phased)
			player.phased_changed.connect(hud.set_phased_state)
			
	if relic:
		relic.collected.connect(_on_relic_collected)
		
	_setup_memory()

func _setup_memory() -> void:
	# Subclasses override this
	pass

func _on_relic_collected() -> void:
	if complete_dialog:
		complete_dialog.show_completion(ancestor_id)

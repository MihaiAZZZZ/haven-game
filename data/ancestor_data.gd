extends Resource
class_name AncestorData

@export var id: String = ""
@export var name: String = ""
@export var title: String = ""
@export var generation: int = 1
@export var relation: String = ""
@export var memory_title: String = ""
@export_multiline var memory_description: String = ""
@export_multiline var memory_quote: String = ""
@export_file("*.tscn") var level_scene_path: String = ""
@export var parent_id: String = ""
@export var tree_position: Vector2 = Vector2.ZERO
@export var unlocked: bool = false
@export var solved: bool = false
@export var color_tint: Color = Color(0.4, 0.8, 1.0)

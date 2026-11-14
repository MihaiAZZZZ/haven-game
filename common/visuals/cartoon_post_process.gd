extends CanvasLayer
class_name CartoonPostProcess

## CartoonPostProcess: Cozy storybook color and warmth grade
## Runs under the UI (layer 5) so UI text and HUD elements remain crisp and clean.

@onready var filter_rect: ColorRect = %FilterRect

@export_range(0.0, 1.0, 0.05) var warmth: float = 0.25:
	set(val):
		warmth = val
		_update_shader()

@export_range(0.8, 1.5, 0.05) var saturation: float = 1.15:
	set(val):
		saturation = val
		_update_shader()

@export_range(0.0, 1.0, 0.05) var vignette: float = 0.35:
	set(val):
		vignette = val
		_update_shader()

func _ready() -> void:
	layer = 5 # Ensure it stays BELOW the UI (HUD is layer 50)
	_update_shader()

func _update_shader() -> void:
	if not filter_rect or not filter_rect.material:
		return
	var mat = filter_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("warmth", warmth)
		mat.set_shader_parameter("saturation", saturation)
		mat.set_shader_parameter("vignette_strength", vignette)

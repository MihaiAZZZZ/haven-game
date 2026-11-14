extends SceneTree

func _init() -> void:
	var shaders = [
		"res://common/shaders/cartoon_cel_postprocess.gdshader",
		"res://common/shaders/cartoon_sprite_outline.gdshader",
		"res://common/shaders/cartoon_halftone_dots.gdshader"
	]
	
	for path in shaders:
		var s = load(path) as Shader
		if s:
			print("Compiled OK: ", path)
		else:
			printerr("Failed to load: ", path)
			quit(1)
			return
			
	print("All shaders compiled successfully!")
	quit(0)

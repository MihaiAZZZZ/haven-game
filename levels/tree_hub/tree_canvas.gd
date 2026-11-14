extends Control

func _draw() -> void:
	var tree_view = get_parent()
	if tree_view and tree_view.has_method("draw_family_tree"):
		tree_view.draw_family_tree(self)

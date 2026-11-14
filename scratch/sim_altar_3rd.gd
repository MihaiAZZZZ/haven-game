extends SceneTree

func _init() -> void:
	print("--- SIMULATING LEVEL 3 ALTAR PIECES ---")
	var scene = load("res://levels/memories/memory_4_origin.tscn")
	if not scene:
		printerr("Failed to load scene")
		quit(1)
		return
		
	var inst = scene.instantiate()
	root.add_child(inst)
	
	# Wait 2 frames
	await process_frame
	await process_frame
	
	var altar = inst.get_node("%AncestralAltar")
	if not altar:
		printerr("No altar found")
		quit(1)
		return
		
	print("Activating altar...")
	altar.activate_altar()
	await process_frame
	
	print("Placing Piece 1...")
	altar._place_next_piece()
	await process_frame
	
	print("Placing Piece 2...")
	altar._place_next_piece()
	await process_frame
	
	print("Placing Piece 3 (The problematic one)...")
	altar._place_next_piece()
	await process_frame
	await process_frame
	
	print("If you see this, Piece 3 was placed without immediate error!")
	quit(0)

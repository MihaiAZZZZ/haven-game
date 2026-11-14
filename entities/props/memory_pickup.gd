extends Area2D
class_name MemoryPickup

## MemoryPickup: Key ancestral relic that resolves an ancestor's trauma.
## Renders authentic pixel art relics (Pocket Watch, Flame, Golden Canary, Heaven Portal).

signal collected()

enum RelicType { POCKET_WATCH, LIGHTHOUSE_FLAME, GOLDEN_CANARY, HEAVEN_PORTAL, NECKLACE, GOLDEN_KEY, NECKLACE_GEM }

@export var relic_type: RelicType = RelicType.POCKET_WATCH
@export var relic_name: String = "Amintire Stramoseasca"
@export var relic_color: Color = Color(0.95, 0.78, 0.28)

var _time: float = 0.0
var _is_collected: bool = false

@onready var light: PointLight2D = %Light2D
@onready var label: Label = %Label

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	if label:
		label.text = relic_name

func _process(delta: float) -> void:
	_time += delta
	# 1-pixel stepped bobbing
	position.y += sin(_time * 3.0) * 0.35
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if _is_collected:
		return
	if body is GhostPlayer:
		_is_collected = true
		AudioSynth.play_chime(1.2)
		collected.emit()
		_play_collect_animation()

func _play_collect_animation() -> void:
	set_deferred("monitoring", false)
	AudioSynth.play_fanfare()
	
	# Create a floating notification label that rises with the item
	var pop_lbl = Label.new()
	pop_lbl.text = "[ " + relic_name.to_upper() + " ]"
	pop_lbl.position = Vector2(-120, -38)
	pop_lbl.custom_minimum_size = Vector2(240, 20)
	pop_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pop_lbl.add_theme_color_override("font_color", Color(1.0, 0.94, 0.5, 1.0))
	pop_lbl.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.16, 1.0))
	pop_lbl.add_theme_constant_override("outline_size", 4)
	pop_lbl.add_theme_font_size_override("font_size", 12)
	add_child(pop_lbl)
	
	# Dramatic upward float and scale up animation so player clearly sees it even without reading
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "position:y", position.y - 80.0, 0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.8, 1.8), 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(self, "modulate:a", 0.0, 0.4)
	tw.chain().tween_callback(queue_free)

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	var p = 2.0 # Pixel unit
	var pulse = 1.0 + 0.08 * sin(_time * 4.0)
	
	# Pixel aura / halo
	var halo_size = 22.0 * pulse
	draw_rect(Rect2(-halo_size * 0.5, -halo_size * 0.5, halo_size, halo_size), Color(relic_color.r, relic_color.g, relic_color.b, 0.25))
	
	match relic_type:
		RelicType.POCKET_WATCH:
			# Pixel Golden Watch (Stepped circle)
			draw_rect(Rect2(-14, -14, 28, 28), ink)
			draw_rect(Rect2(-12, -12, 24, 24), Color(0.95, 0.78, 0.28))
			draw_rect(Rect2(-8, -8, 16, 16), Color(0.96, 0.94, 0.86))
			# Hands
			draw_rect(Rect2(0, -6, 2, 7), ink)
			draw_rect(Rect2(0, 0, 6, 2), ink)
			# Top loop
			draw_rect(Rect2(-4, -18, 8, 4), ink)
			draw_rect(Rect2(-2, -16, 4, 2), Color(0.95, 0.78, 0.28))
			
		RelicType.LIGHTHOUSE_FLAME:
			# Pixel Fire
			var h = 18.0 * pulse
			draw_rect(Rect2(-8, -h, 16, h), ink)
			draw_rect(Rect2(-6, -h + 2, 12, h - 2), Color(0.96, 0.65, 0.22))
			draw_rect(Rect2(-3, -h + 6, 6, h - 8), Color(1.0, 0.92, 0.5))
			draw_rect(Rect2(-1, -h + 8, 2, 4), Color.WHITE)
			
		RelicType.GOLDEN_CANARY:
			# Pixel Golden Bird
			draw_rect(Rect2(-8, -6, 16, 12), ink)
			draw_rect(Rect2(-6, -4, 12, 8), Color(0.95, 0.78, 0.28))
			# Head & Beak
			draw_rect(Rect2(6, -9, 8, 8), ink)
			draw_rect(Rect2(7, -8, 6, 6), Color(0.98, 0.85, 0.35))
			draw_rect(Rect2(12, -6, 4, 3), Color(0.92, 0.45, 0.2)) # Orange beak
			draw_rect(Rect2(9, -7, 2, 2), ink) # Eye
			# Fluttering pixel wing
			var wing_y = int(sin(_time * 12.0) * 2.0) * 2
			draw_rect(Rect2(-4, -6 + wing_y, 8, 4), Color(0.85, 0.65, 0.2))
			
		RelicType.HEAVEN_PORTAL:
			# Stepped Pixel Portal Rings
			draw_rect(Rect2(-16, -16, 32, 32), ink)
			draw_rect(Rect2(-13, -13, 26, 26), Color(0.96, 0.9, 0.75))
			draw_rect(Rect2(-9, -9, 18, 18), ink)
			draw_rect(Rect2(-7, -7, 14, 14), Color.WHITE)
			
		RelicType.NECKLACE:
			# Pixel Colierul Stramosesc (Golden chain with radiant spectral gem)
			var gold = Color(0.98, 0.82, 0.3)
			var gold_dark = Color(0.82, 0.62, 0.18)
			var gem = Color(0.35, 0.92, 1.0)
			var gem_bright = Color(0.85, 0.98, 1.0)
			
			# Upper chain links (draped U-shape)
			var chain_pts = [
				Vector2(-10, -12), Vector2(-8, -8), Vector2(-5, -4),
				Vector2(5, -4), Vector2(8, -8), Vector2(10, -12)
			]
			for pt in chain_pts:
				draw_rect(Rect2(pt.x - 1, pt.y - 1, 3, 3), ink)
				draw_rect(Rect2(pt.x, pt.y, 2, 2), gold)
				
			# Pendant bail loop
			draw_rect(Rect2(-3, -3, 6, 4), ink)
			draw_rect(Rect2(-2, -2, 4, 2), gold_dark)
			
			# Outer gold filigree pendant casing
			draw_rect(Rect2(-8, 1, 16, 16), ink)
			draw_rect(Rect2(-6, 3, 12, 12), gold)
			
			# Inner glowing spectral diamond gem
			draw_rect(Rect2(-4, 5, 8, 8), ink)
			draw_rect(Rect2(-3, 6, 6, 6), gem)
			draw_rect(Rect2(-2, 7, 2, 2), gem_bright)
			
			# Sparkle glint on top-right
			if int(_time * 4.0) % 2 == 0:
				draw_rect(Rect2(7, 0, 3, 3), Color.WHITE)
				
		RelicType.GOLDEN_KEY:
			# Ornate Pixel Golden Chest Key
			var gold = Color(0.98, 0.85, 0.32)
			var gold_dark = Color(0.82, 0.65, 0.2)
			var gold_bright = Color(1.0, 0.95, 0.6)
			
			# Key Bow (Heart / Oval ring at top)
			draw_rect(Rect2(-10, -16, 20, 14), ink)
			draw_rect(Rect2(-8, -14, 16, 10), gold)
			draw_rect(Rect2(-4, -12, 8, 6), ink)
			draw_rect(Rect2(-3, -11, 6, 4), Color(0.18, 0.14, 0.22)) # Hollow hole
			draw_rect(Rect2(-6, -14, 3, 2), gold_bright) # Highlight
			
			# Key Stem (Vertical shaft)
			draw_rect(Rect2(-3, -2, 6, 22), ink)
			draw_rect(Rect2(-1, -1, 2, 20), gold)
			draw_rect(Rect2(-2, -1, 1, 20), gold_bright)
			
			# Key Bits / Teeth (Bottom right notches)
			draw_rect(Rect2(3, 8, 8, 5), ink)
			draw_rect(Rect2(3, 9, 6, 3), gold)
			draw_rect(Rect2(3, 15, 10, 5), ink)
			draw_rect(Rect2(3, 16, 8, 3), gold)
			
			# Sparkle glint
			if int(_time * 5.0) % 2 == 0:
				draw_rect(Rect2(6, -15, 3, 3), Color.WHITE)
				
		RelicType.NECKLACE_GEM:
			# Ornate Antique Ruby Necklace Piece - The Grand Ruby Medallion
			var gold = Color(0.96, 0.82, 0.3)
			var gold_dark = Color(0.78, 0.58, 0.16)
			var ruby = Color(0.95, 0.28, 0.38)
			var ruby_bright = Color(1.0, 0.65, 0.75)
			var ruby_dark = Color(0.65, 0.15, 0.25)
			
			# Golden necklace chain links at top
			var chain_pts = [
				Vector2(-10, -18), Vector2(-7, -13), Vector2(-4, -9),
				Vector2(4, -9), Vector2(7, -13), Vector2(10, -18)
			]
			for pt in chain_pts:
				draw_rect(Rect2(pt.x - 1, pt.y - 1, 3, 3), ink)
				draw_rect(Rect2(pt.x, pt.y, 2, 2), gold)
				
			# Bail connector
			draw_rect(Rect2(-3, -8, 6, 4), ink)
			draw_rect(Rect2(-2, -7, 4, 2), gold_dark)
			
			# Outer golden filigree pendant setting
			draw_rect(Rect2(-12, -4, 24, 24), ink)
			draw_rect(Rect2(-10, -2, 20, 20), gold)
			
			# Faceted teardrop/cushion ruby core
			draw_rect(Rect2(-7, 1, 14, 14), ink)
			draw_rect(Rect2(-6, 2, 12, 12), ruby)
			draw_rect(Rect2(-6, 8, 12, 6), ruby_dark)
			draw_rect(Rect2(-4, 4, 4, 4), ruby_bright)
			
			# Golden filigree corner notches
			draw_rect(Rect2(-9, -1, 2, 2), ink)
			draw_rect(Rect2(7, -1, 2, 2), ink)
			draw_rect(Rect2(-9, 15, 2, 2), ink)
			draw_rect(Rect2(7, 15, 2, 2), ink)
			
			# Radiating sparkle
			if int(_time * 4.0) % 2 == 0:
				draw_rect(Rect2(9, 0, 3, 3), Color.WHITE)

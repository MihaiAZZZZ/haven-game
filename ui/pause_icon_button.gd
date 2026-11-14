extends Button
class_name PauseIconButton

## Pixel Art Transparent Pause Button rendering two crisp pixel bars.

@export var bar_width: float = 6.0
@export var bar_height: float = 20.0
@export var bar_gap: float = 8.0
@export var bar_color: Color = Color(0.96, 0.94, 0.88, 0.85)
@export var bar_hover_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var ink_outline_color: Color = Color(0.11, 0.08, 0.15, 1.0)

func _ready() -> void:
	flat = true
	focus_mode = FOCUS_NONE
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)

func _draw() -> void:
	var center = (size * 0.5).floor()
	var half_h = floor(bar_height * 0.5)
	var x1 = floor(center.x - (bar_gap * 0.5) - bar_width)
	var x2 = floor(center.x + (bar_gap * 0.5))
	var y_top = center.y - half_h
	
	var col = bar_hover_color if is_hovered() else bar_color
	if is_pressed():
		col = Color(0.95, 0.78, 0.28, 1.0)
		
	# 1-pixel dark backing rectangle for crisp pixel contrast
	var border = 2.0
	draw_rect(Rect2(x1 - border, y_top - border, bar_width + border * 2.0, bar_height + border * 2.0), ink_outline_color)
	draw_rect(Rect2(x2 - border, y_top - border, bar_width + border * 2.0, bar_height + border * 2.0), ink_outline_color)
	
	# Main pixel pause bars
	draw_rect(Rect2(x1, y_top, bar_width, bar_height), col)
	draw_rect(Rect2(x2, y_top, bar_width, bar_height), col)

extends Node2D

var selected = []  # Array of currently selected units.
var drag_start = Vector2.ZERO  # Location where drag began.
var selecting = false  # start drag select.
var select_rect = RectangleShape2D.new()  # Collision shape for drag box.
		
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				for item in selected:
					item.collider.selected = false
				selected = []
				drag_start = event.position
				selecting = true
			else:
				selecting = false
				var drag_end = event.position
				# Extents are measured from center.
				select_rect.extents = (drag_end - drag_start) / 2
				var space = get_world_2d().direct_space_state
				var query = Physics2DShapeQueryParameters.new()
				query.set_shape(select_rect)
				query.transform = Transform2D(0, (drag_end + drag_start) / 2)
				# Result is an array of dictionaries. Each has a "collider" key.
				selected = space.intersect_shape(query)
				for item in selected:
					item.collider.selected = true
				update()
		# If there is a selection, give it the target.
		elif event.button_index == BUTTON_RIGHT:
			for item in selected:
				item.collider.target = event.position

	elif event is InputEventMouseMotion:
		# Draw the box while dragging.
		update()
				
func _draw():
	if selecting:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),Color(.5, .5, .5), false)

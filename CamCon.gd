extends Spatial

const MOVE_MARGIN = 10
const MOVE_SPEED = 30

const ray_length = 100
onready var camera = $Camera
onready var control = $Control

const UNIT_COLLISION_MASK = 1
const GROUND_COLLISION_MASK = 2

var selected_units = []

func _process(delta: float) -> void:
	var viewport = get_viewport()
	var m_pos = viewport.get_mouse_position()

	if Input.is_action_just_pressed("ui_right"):
		move_selected_units(m_pos)
	elif Input.is_action_just_pressed("ui_left"):
		control.m_pos_p = m_pos
		control.m_pos = m_pos
		control.is_show = true
	elif Input.is_action_just_released("ui_left"):
		select_units(control.m_pos_p, m_pos)
		control.is_show = false
	else:
		if Input.is_action_pressed("ui_left"):
			#select_units(control.m_pos_p, m_pos)
			control.m_pos = m_pos
		calc_move(viewport.size, m_pos, delta)

func calc_move(v_size: Vector2, m_pos: Vector2, delta: float) -> void:
	var is_view_move = false
	var move_vec = Vector3()
	if m_pos.x < MOVE_MARGIN:
		move_vec.x -= 1
		is_view_move = true
	elif m_pos.x > v_size.x - MOVE_MARGIN:
		move_vec.x += 1
		is_view_move = true
	if m_pos.y < MOVE_MARGIN:
		move_vec.z -= 1
		is_view_move = true
	elif m_pos.y > v_size.y - MOVE_MARGIN:
		move_vec.z += 1
		is_view_move = true
	if is_view_move:
		move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation_degrees.y)
		global_translate(move_vec * delta * MOVE_SPEED)

func move_selected_units(m_pos: Vector2) -> void:
	if selected_units.size() > 0:
		var result = raycast_from_mouse(m_pos, GROUND_COLLISION_MASK)
		if result:
			var position = result.position
			var pos = Vector2(position.x, position.z)
			for unit in selected_units:
				unit.target = pos

func select_units(m_pos_p, m_pos):
	var new_selected_units = []
	if m_pos.distance_squared_to(m_pos_p) < 16:
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(m_pos_p, m_pos)
	selected_units = new_selected_units

func get_unit_under_mouse(m_pos):
	var result = raycast_from_mouse(m_pos, UNIT_COLLISION_MASK)
	if result and result.collider:
		return result.collider

func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("units"):
		if box.has_point(camera.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = camera.project_ray_origin(m_pos)
	var ray_end = ray_start + camera.project_ray_normal(m_pos) * ray_length
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)

extends KinematicBody2D

var DEBUG_DRAW = true

export var speed: float = 400  # Unit2D speed.

var target_radius: float = 100  # Stop when this close to target.
var keep_radius: float = 100  # Stop when this close to target.

var body_radius: float = 0
var move_keep_radius: float = 0
var rest_keep_radius: float = 0

var to_target: bool = false
var target: Vector2 = Vector2.ZERO setget set_target

var going_velocity: Vector2 = Vector2.ZERO
var avoid_velocity: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

var keep_dis: bool = false
var no_avoid: bool = false

func _ready() -> void:
	body_radius = $Shape.shape.radius
	move_keep_radius = $MoveSpace/Shape.shape.radius
	rest_keep_radius = $RestSpace/Shape.shape.radius
	target_radius = rest_keep_radius
	keep_radius = move_keep_radius

func _physics_process(delta) -> void:
	move_process(delta)
	update()

func move_process(delta: float) -> void:
	if to_target:
		var dis = position.distance_to(target)
		if dis < target_radius:
			to_target = false
			keep_dis = false
			going_velocity = Vector2.ZERO
		else:
			going_velocity = position.direction_to(target)
			if dis < keep_radius:
				keep_dis = false
			else:
				var ng = get_going_velocity()
				if ng.length() > 0:
					var nng = (going_velocity + ng).normalized()
					var f = nng.dot(going_velocity)
					if f >= 0:
						going_velocity = nng
					else:
						going_velocity = nng + going_velocity * (-f)
						
	if no_avoid:
		avoid_velocity = Vector2.ZERO
	else:
		avoid_velocity = get_avoid_velocity()
	velocity = going_velocity + avoid_velocity
	if to_target:
		velocity = velocity.normalized()
	var v_len = velocity.length()
	if v_len > 1.01:
		velocity = velocity.normalized()
	if v_len > 0:
		var collision = move_and_collide(velocity * speed * delta)
		if collision:
			if to_target and collision.collider and collision.collider.target == target and !collision.collider.to_target:
				keep_dis = false
				to_target = false
				going_velocity = Vector2.ZERO

func get_going_velocity() -> Vector2:
	return cal_avoid($MoveSpace.get_overlapping_bodies(), move_keep_radius, true)

func get_avoid_velocity() -> Vector2:
	return cal_avoid($RestSpace.get_overlapping_bodies(), rest_keep_radius)

func cal_avoid(neighbors: Array, space_radius: float, is_move_space: bool = false) -> Vector2:
	var result = Vector2.ZERO
	var keep_distance = space_radius - body_radius
	for n in neighbors:
		if is_move_space and not n.keep_dis:
			continue
		var distance: float = n.position.distance_to(position)
		if distance == 0:
			continue
		var factor: float = 1
		if not n.to_target and not n.no_avoid:
			factor = 0.5
		factor *= 1 - (distance - body_radius - n.body_radius) / keep_distance
		if factor > 0:
			result += n.position.direction_to(position) * factor
	return result

func set_target(value):
	target = value
	keep_dis = true
	to_target = true

func _draw():
	# Draws some debug vectors.
	if !DEBUG_DRAW:
		return
	draw_circle(Vector2.ZERO, body_radius, Color(1, 0, 1, 0.4))
	draw_circle(Vector2.ZERO, move_keep_radius, Color(1, 1, 0, 0.04))
	draw_circle(Vector2.ZERO, rest_keep_radius, Color(1, 1, 0, 0.2))
	draw_line(Vector2.ZERO, going_velocity.rotated(-rotation)*speed, Color(0, 0, 1), 2)
	draw_line(Vector2.ZERO, avoid_velocity.rotated(-rotation)*speed, Color(1, 0, 0), 4)
	draw_line(Vector2.ZERO, velocity.rotated(-rotation)*speed, Color(0, 1, 0), 4)


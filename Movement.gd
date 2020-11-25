extends KinematicBody2D

var DEBUG_DRAW = true

export var speed: float = 100  # Movement speed.

var target_radius: float = 100  # Stop when this close to target.

var body_radius: float = 0
var move_keep_radius: float = 0
var rest_keep_radius: float = 0

var to_target: bool = false
var target: Vector2 = Vector2.ZERO setget set_target

var going_velocity: Vector2 = Vector2.ZERO
var avoid_velocity: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

var no_avoid: bool = false

func _ready() -> void:
	body_radius = $Shape.shape.radius
	move_keep_radius = $MoveSpace/Shape.shape.radius
	rest_keep_radius = $RestSpace/Shape.shape.radius
	target_radius = rest_keep_radius * 1.2

func _physics_process(_delta) -> void:
	if to_target:
		if position.distance_to(target) < target_radius:
			to_target = false
			going_velocity = Vector2.ZERO
		else:
			going_velocity = get_going_velocity()
	if no_avoid:
		avoid_velocity = Vector2.ZERO
	else:
		avoid_velocity = get_avoid_velocity()
	velocity = (going_velocity + avoid_velocity).normalized()
	if velocity.length() > 0:
		move_and_slide(velocity * speed)
	update()

func get_going_velocity() -> Vector2:
	return position.direction_to(target)

func get_avoid_velocity() -> Vector2:
	var result = Vector2.ZERO
	var keep_distance: float = 0
	var neighbors = []
	if to_target:
		neighbors = $MoveSpace.get_overlapping_bodies()
		keep_distance = move_keep_radius - body_radius
	else:
		neighbors = $RestSpace.get_overlapping_bodies()
		keep_distance = rest_keep_radius - body_radius
	if keep_distance > 0:
		for n in neighbors:
			var distance: float = n.position.distance_to(position)
			if distance > 0:
				var n_body_radius = body_radius #todo
				var factor = 1 - (distance - body_radius - n_body_radius) / keep_distance
				if factor > 0:
					var direction = n.position.direction_to(position)
					result += direction * factor
	return result

func set_target(value):
	target = value
	to_target = true

func _draw():
	# Draws some debug vectors.
	if !DEBUG_DRAW:
		return
	draw_circle(Vector2.ZERO, body_radius, Color(1, 0, 1, 0.4))
	draw_circle(Vector2.ZERO, move_keep_radius, Color(1, 1, 0, 0.04))
	draw_circle(Vector2.ZERO, rest_keep_radius, Color(1, 1, 0, 0.2))
	draw_line(Vector2.ZERO, avoid_velocity.rotated(-rotation)*speed, Color(1, 0, 0), 4)
	draw_line(Vector2.ZERO, velocity.rotated(-rotation)*speed, Color(0, 1, 0), 2)


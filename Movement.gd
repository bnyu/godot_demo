extends KinematicBody2D

var DEBUG_DRAW = true

export var speed = 400  # Movement speed.
var av = Vector2.ZERO  # Avoidance vector.
var avoid_weight = 10  # How strongly to avoid other units.
var target_radius = 100  # Stop when this close to target.
var target = null setget set_target  # Set this to move.
var selected = false  # Is this unit selected?
var velocity = Vector2.ZERO


func _physics_process(delta):
	velocity = Vector2.ZERO
	if target:
		# If there's a target, move toward it.
		velocity = position.direction_to(target)
		if position.distance_to(target) < target_radius:
			target = null
	# Find avoidance vector and add to velocity.
	av = avoid() * avoid_weight
	velocity = (velocity + av).normalized()
	if velocity.length() > 0:
		# Rotate body to point in movement direction.
		rotation = velocity.angle()
	move_and_slide(velocity * speed)
	update()
		
func set_target(value):
	target = value

func avoid():
	# Calculates avoidance vector based on nearby units.
	var result = Vector2.ZERO
	var neighbors = $Space.get_overlapping_bodies()
	if !neighbors:
		return result
	for n in neighbors:
		result += n.position.direction_to(position) * (1/(1+n.position.distance_to(position)))
	return result
	
func _draw():
	# Draws some debug vectors.
	if !DEBUG_DRAW:
		return
	draw_circle(Vector2.ZERO, $Body.shape.radius,
				Color(1, 0, 1, 0.4))
	draw_circle(Vector2.ZERO, $Space/SpaceShape.shape.radius,
				Color(1, 1, 0, 0.2))
	draw_line(Vector2.ZERO, av.rotated(-rotation)*speed, Color(1, 0, 0), 4)
	draw_line(Vector2.ZERO, velocity.rotated(-rotation)*speed, Color(0, 1, 0), 2)


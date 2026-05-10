extends CharacterBody2D

@export var speed = 500
var direction = Vector2.ZERO

func _physics_process(delta):
	var d = direction
	if d.length() > 0.001:
		d = d.normalized()
	velocity = d * speed
	move_and_slide()

	if velocity.length() > 0:
		rotation = velocity.angle()

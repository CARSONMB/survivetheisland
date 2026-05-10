extends Area2D

@export var heal_amount = 30

func _ready():
	add_to_group("item")

func _on_body_entered(hit_body):
	if hit_body == null or not is_instance_valid(hit_body):
		return
	if hit_body.is_in_group("player"):
		if hit_body.has_method("heal"):
			hit_body.heal(heal_amount)
		Globals.PlayPowerup()
		queue_free()

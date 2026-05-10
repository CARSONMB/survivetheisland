extends Area2D

@export var ammo_amount = 30

func _ready():
	add_to_group("item")

func _on_body_entered(player_body):
	if player_body == null or not is_instance_valid(player_body):
		return
	if player_body.is_in_group("player"):
		if player_body.gun != null and is_instance_valid(player_body.gun) and player_body.gun.has_method("addAmmo"):
			player_body.gun.addAmmo(ammo_amount)
			Globals.PlayPowerup()
		queue_free()

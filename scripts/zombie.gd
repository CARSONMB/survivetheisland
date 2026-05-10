extends CharacterBody2D

signal died

@export var speed = 100
@export var hp = 3
@export var max_hp = 3
@export var damage = 10
@export var player_sprite_offset = 90.0

var player = null
var can_hit_player = true

func _ready():
	add_to_group("enemy")

	player = get_tree().get_first_node_in_group("player")

	RefreshHPBar()

	print("Zombie spawned:", name)

func _physics_process(_delta):
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if player != null:
		var direction_to_player = player.global_position - global_position
		if direction_to_player.length() > 0.01:
			direction_to_player = direction_to_player.normalized()
		rotation = direction_to_player.angle() + deg_to_rad(player_sprite_offset)
		velocity = direction_to_player * speed
		move_and_slide()

func _on_body_entered(colliding_body):
	if colliding_body == null or not is_instance_valid(colliding_body):
		return

	if colliding_body.is_in_group("player") and can_hit_player == true:
		colliding_body.take_damage(damage)

		can_hit_player = false
		var wait_timer = get_tree().create_timer(1.0)
		wait_timer.timeout.connect(hit_cooldown_done)
		return

	if colliding_body.is_in_group("bullet"):
		applyDamage(1)
		colliding_body.queue_free()

func hit_cooldown_done():
	can_hit_player = true

func setMaxHp(new_max: int, heal_full: bool = true) -> void:
	max_hp = max(1, int(new_max))
	if heal_full == true:
		hp = max_hp
	RefreshHPBar()

func applyDamage(amount = 1):
	hp = hp - amount
	print("Zombie HP:", hp)
	RefreshHPBar()
	if hp <= 0:
		die()

func die():
	print("Zombie died:", name)
	died.emit()
	queue_free()

func RefreshHPBar() -> void:
	if has_node("HealthBar"):
		$HealthBar.max_value = max_hp
		$HealthBar.value = clamp(hp, 0, max_hp)

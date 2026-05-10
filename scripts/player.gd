extends CharacterBody2D

@export var speed = 200
@export var max_health = 100
@export var max_health_per_level: int = 15
@export var heal_on_level_up: int = 25
@export var face_cursor_sprite_offset_degrees: float = 90.0

var hp = 0
var gun = null
var gun_icon = null

func _ready():
	add_to_group("player")

	hp = max_health
	if Globals != null:
		Globals.leveled_up.connect(player_level_up)

func player_level_up(new_level: int) -> void:
	max_health = max_health + max_health_per_level
	hp = min(hp + heal_on_level_up, max_health)
	if not is_inside_tree():
		return
	var scene_tree = get_tree()
	if scene_tree == null:
		return
	scene_tree.call_group("ui", "refresh_player_stats")

func _physics_process(delta):
	var left_pressed = Input.is_action_pressed("left")
	var right_pressed = Input.is_action_pressed("right")
	var up_pressed = Input.is_action_pressed("up")
	var down_pressed = Input.is_action_pressed("down")

	var move_vector = Vector2.ZERO
	if left_pressed:
		move_vector.x = move_vector.x - 1
	if right_pressed:
		move_vector.x = move_vector.x + 1
	if up_pressed:
		move_vector.y = move_vector.y - 1
	if down_pressed:
		move_vector.y = move_vector.y + 1

	if move_vector.x != 0 or move_vector.y != 0:
		move_vector = move_vector.normalized()
	velocity = move_vector * speed

	var mouse_pos = get_global_mouse_position()
	var mouse_offset = mouse_pos - global_position
	if mouse_offset.length() > 0.0001:
		rotation = mouse_offset.angle() + deg_to_rad(face_cursor_sprite_offset_degrees)

	if Input.is_action_just_pressed("pickup"):
		try_pickup()
	if Input.is_action_just_pressed("drop"):
		DropGun()

	move_and_slide()

func try_pickup():
	if gun != null:
		return

	if not has_node("PickupArea"):
		return
	var pickup_area = $PickupArea
	var overlapping_bodies = pickup_area.get_overlapping_bodies()
	for overlapping_body in overlapping_bodies:
		if overlapping_body != null and is_instance_valid(overlapping_body):
			if overlapping_body.is_in_group("gun"):
				equipGun(overlapping_body)
				return

func equipGun(new_gun):
	self.gun = new_gun
	gun_icon = new_gun.weapon_icon_texture
	new_gun.pick_up(self)
	Globals.PlayPowerup()

	new_gun.rotation = 0

func DropGun():
	if gun:
		gun.drop()
		gun = null
		gun_icon = null

func take_damage(amount):
	if amount > 0:
		Globals.play_hurt()
	hp = hp - amount
	hp = clamp(hp, 0, max_health)

	if is_inside_tree():
		get_tree().call_group("ui", "update_health_external", hp, max_health)

	if hp <= 0:
		die()

func heal(amount: int):
	hp = hp + amount
	hp = clamp(hp, 0, max_health)
	if is_inside_tree():
		get_tree().call_group("ui", "update_health_external", hp, max_health)

func die():
	print("Player died")
	queue_free()

extends StaticBody2D

const GROUND_COLLISION_LAYER = 8

@export var weapon_icon_texture: Texture2D
@export var bullet_scene: PackedScene

@export var fire_rate = 0.15
@export var fire_type = "auto"

@export var mag_size = 12
@export var ammo = 12
@export var reserve_ammo = 120
@export var reload_time = 1.0

var player = null
var can_shoot = true
var reloading = false

func _ready():
	add_to_group("gun")
	collision_layer = GROUND_COLLISION_LAYER
	collision_mask = 0

func _process(delta):
	if player == null:
		return

	if Input.is_action_just_pressed("reload"):
		do_reload()

	if fire_type == "auto":
		if Input.is_action_pressed("shoot"):
			try_shoot()
	else:
		if Input.is_action_just_pressed("shoot"):
			try_shoot()

func pick_up(p):
	if p == null:
		return
	player = p
	if get_parent():
		get_parent().remove_child(self)
	player.add_child(self)
	collision_layer = 0
	collision_mask = 0
	if has_node("Area2D"):
		$Area2D.collision_layer = 0
		$Area2D.collision_mask = 0
	if player.has_node("GunHoldPoint"):
		global_position = player.get_node("GunHoldPoint").global_position
	else:
		global_position = player.global_position + Vector2(20, 0)

func drop():
	if player == null:
		return
	var world = get_tree().current_scene
	var drop_pos = player.global_position + Vector2(30, 0)
	player.remove_child(self)
	world.add_child(self)
	global_position = drop_pos
	collision_layer = GROUND_COLLISION_LAYER
	collision_mask = 0
	player = null

func try_shoot():
	if reloading == true:
		return
	if can_shoot == false:
		return
	if ammo <= 0:
		if reserve_ammo > 0:
			do_reload()
		return
	shoot()
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func shoot():
	if bullet_scene == null:
		return
	if not has_node("muzzle"):
		return
	if ammo <= 0:
		return
	ammo = ammo - 1
	var bullet = bullet_scene.instantiate()
	var muzzle_pos = $muzzle.global_position
	bullet.global_position = muzzle_pos
	var dir = get_global_mouse_position() - muzzle_pos
	if dir.length() > 0.001:
		dir = dir.normalized()
	bullet.direction = dir
	get_tree().current_scene.add_child(bullet)
	Globals.playShootSound()

func do_reload():
	if reloading == true:
		return
	if ammo >= mag_size:
		return
	if reserve_ammo <= 0:
		return

	reloading = true
	await get_tree().create_timer(reload_time).timeout

	var bullets_needed = mag_size - ammo
	var bullets_to_load = min(bullets_needed, reserve_ammo)
	ammo = ammo + bullets_to_load
	reserve_ammo = reserve_ammo - bullets_to_load
	reloading = false
	Globals.play_click()

func addAmmo(amount: int):
	reserve_ammo = reserve_ammo + amount

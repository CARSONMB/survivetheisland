extends Node2D

signal waveStarted(which_wave)

var score = 0
var game_over = false

var wave = 1
var zombies_to_spawn = 0
var zombies_alive = 0
var wave_running = false

@export var zombie_scene: PackedScene
@export var boss_scene: PackedScene
@export var hp_scene: PackedScene
@export var ammo_scene: PackedScene
@export var base_zombies_per_wave = 8
@export var spawn_delay = 0.5
@export var hp_per_wave = 0.25
@export var item_delay = 12.0
@export var drop_ammo_chance = 0.25
@export var drop_hp_chance = 0.08

func _ready():
	_spawn_items_forever()

func _process(delta):
	if game_over == false:
		score = score + delta
		Globals.runTime = Globals.runTime + delta
	Globals.score = int(score)

	if game_over == true:
		return

	if has_node("UI/MainHud/WaveLabel"):
		$UI/MainHud/WaveLabel.text = "Wave: " + str(wave)

	var player_node = get_tree().get_first_node_in_group("player")
	if player_node == null:
		game_over = true
		Globals.game_over = true
		Globals.save_high_score_if_beaten()
		return

	if wave_running == false:
		start_wave()

func start_wave():
	wave_running = true
	waveStarted.emit(wave)
	if wave % 5 == 0 and boss_scene != null:
		zombies_to_spawn = 1
		zombies_alive = 1
		SpawnBoss()
	else:
		zombies_to_spawn = base_zombies_per_wave + (wave * 4)
		zombies_alive = zombies_to_spawn
		spawnWave()

func spawnWave():
	var spawn_index = 0
	while spawn_index < zombies_to_spawn:
		await get_tree().create_timer(spawn_index * spawn_delay).timeout
		spawn_zombie()
		spawn_index = spawn_index + 1

func SpawnBoss():
	var boss_node = boss_scene.instantiate()
	add_child(boss_node)
	boss_node.global_position = Vector2(randf_range(-300, 300), randf_range(-220, 220))
	if boss_node.has_signal("died"):
		boss_node.died.connect(_on_enemy_died_signal.bind(boss_node))
	else:
		boss_node.tree_exited.connect(_on_zombie_tree_exited)

	if boss_node.has_method("setMaxHp"):
		var base_hp_value = int(boss_node.max_hp)
		var health_multiplier = 1.0 + float(wave - 1) * float(hp_per_wave)
		var scaled_hp = int(round(base_hp_value * health_multiplier))
		boss_node.setMaxHp(scaled_hp, true)

func spawn_zombie():
	if zombie_scene == null:
		return
	var zombie_node = zombie_scene.instantiate()
	add_child(zombie_node)
	zombie_node.global_position = Vector2(randf_range(-400, 400), randf_range(-300, 300))
	if zombie_node.has_signal("died"):
		zombie_node.died.connect(_on_enemy_died_signal.bind(zombie_node))
	else:
		zombie_node.tree_exited.connect(_on_zombie_tree_exited)

	if zombie_node.has_method("setMaxHp"):
		var base_hp_value = int(zombie_node.max_hp)
		var health_multiplier = 1.0 + float(wave - 1) * float(hp_per_wave)
		var scaled_hp = int(round(base_hp_value * health_multiplier))
		zombie_node.setMaxHp(scaled_hp, true)

func _on_enemy_died_signal(enemy_node):
	on_enemy_died(enemy_node.global_position, enemy_node)

func _on_zombie_tree_exited():
	on_enemy_died()

func on_enemy_died(drop_position: Vector2 = Vector2.ZERO, enemy_node = null):
	zombies_alive = zombies_alive - 1
	score = score + 100
	Globals.addXP(30)
	Globals.bump_kill_counter()
	TryDropLoot(drop_position, enemy_node)
	if zombies_alive <= 0:
		wave = wave + 1
		wave_running = false

func TryDropLoot(drop_position: Vector2, enemy_node = null):
	if ammo_scene == null and hp_scene == null:
		return
	if drop_position == Vector2.ZERO:
		return
	if enemy_node != null and is_instance_valid(enemy_node):
		if enemy_node.has_meta("dropped"):
			return
		enemy_node.set_meta("dropped", true)

	if ammo_scene != null and randf() < drop_ammo_chance:
		var ammo_pickup = ammo_scene.instantiate()
		add_child(ammo_pickup)
		ammo_pickup.global_position = drop_position
		return

	if hp_scene != null and randf() < drop_hp_chance:
		var health_pickup = hp_scene.instantiate()
		add_child(health_pickup)
		health_pickup.global_position = drop_position

func _spawn_items_forever():
	while true:
		await get_tree().create_timer(item_delay).timeout
		if game_over == true:
			continue

		var player_node = get_tree().get_first_node_in_group("player")
		if player_node == null or not is_instance_valid(player_node):
			continue

		if hp_scene != null and randf() < 0.6:
			var health_pickup = hp_scene.instantiate()
			add_child(health_pickup)
			health_pickup.global_position = player_node.global_position + Vector2(randf_range(-250, 250), randf_range(-180, 180))
		elif ammo_scene != null:
			var ammo_pickup = ammo_scene.instantiate()
			add_child(ammo_pickup)
			ammo_pickup.global_position = player_node.global_position + Vector2(randf_range(-250, 250), randf_range(-180, 180))

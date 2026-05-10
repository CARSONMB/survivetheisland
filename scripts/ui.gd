extends Control

var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func hasTimerLabel() -> bool:
	return get_node_or_null("%TimerLabel") != null

func _process(_delta):
	if hasTimerLabel() == false:
		return

	if Globals.game_over == true:
		%ScoreLabel.text = "GAME OVER! Score: " + str(Globals.score)
		%TimerLabel.text = FormatTimerText(Globals.runTime)
		return

	%TimerLabel.text = FormatTimerText(Globals.runTime)

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	%ScoreLabel.text = "Score: " + str(Globals.score)

	var xp_needed = Globals.xp_for_next_level()
	%XPLabel.text = str(Globals.xp) + " / " + str(xp_needed)
	%XPBar.max_value = float(xp_needed)
	%XPBar.value = float(Globals.xp)
	%LevelLabel.text = str(Globals.level)

	if player != null and is_instance_valid(player):
		%HealthBar.max_value = player.max_health
		%HealthBar.value = player.hp
		var low_health_cutoff = player.max_health * 0.3
		if player.hp < low_health_cutoff:
			%HealthBar.modulate = Color(1.0, 0.45, 0.45)
		else:
			%HealthBar.modulate = Color.WHITE

		if player.gun_icon:
			$WeaponSlot/WeaponIcon.visible = true
			$WeaponSlot/WeaponIcon.texture = player.gun_icon

			var player_gun = player.gun
			if player_gun != null and is_instance_valid(player_gun):
				var ammo_in_mag = player_gun.get("ammo")
				var ammo_in_bag = player_gun.get("reserve_ammo")
				if ammo_in_mag != null and ammo_in_bag != null:
					$WeaponSlot/AmmoLabel.text = str(ammo_in_mag) + " / " + str(ammo_in_bag)
				else:
					$WeaponSlot/AmmoLabel.text = ""
			else:
				$WeaponSlot/AmmoLabel.text = ""
		else:
			$WeaponSlot/WeaponIcon.visible = false
			$WeaponSlot/AmmoLabel.text = ""
	else:
		$WeaponSlot/WeaponIcon.visible = false
		$WeaponSlot/AmmoLabel.text = ""

func FormatTimerText(total_seconds_float: float) -> String:
	var total_milliseconds = int(floor(total_seconds_float * 1000.0 + 0.0001))
	var milliseconds_part = total_milliseconds % 1000
	var total_whole_seconds = total_milliseconds / 1000
	var seconds_part = total_whole_seconds % 60
	var minutes_part = (total_whole_seconds / 60) % 60
	var hours_part = total_whole_seconds / 3600
	return "%02d:%02d:%02d.%03d" % [hours_part, minutes_part, seconds_part, milliseconds_part]

func update_health_external(new_health: int, new_max: int = -1):
	if hasTimerLabel() == false:
		return
	%HealthBar.value = new_health
	if new_max >= 0:
		%HealthBar.max_value = new_max
		var low_cutoff = new_max * 0.3
		if new_health < low_cutoff:
			%HealthBar.modulate = Color(1.0, 0.45, 0.45)
		else:
			%HealthBar.modulate = Color.WHITE

func refresh_player_stats():
	if hasTimerLabel() == false:
		return

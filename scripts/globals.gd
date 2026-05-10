extends Node

signal leveled_up(new_level)

const HS_FILE = "user://highscore.txt"
const STREAM_SHOOT = preload("res://sounds/shoot.wav")
const STREAM_HURT = preload("res://sounds/hurt.wav")
const STREAM_POWERUP = preload("res://sounds/powerup.wav")
const STREAM_CLICK = preload("res://sounds/click.wav")

var xp = 0
var level = 1
var score = 0
var killcount = 0
var game_over = false
var runTime = 0.0
var high_score = 0

var music_on = true
var sfx_on = true

var audio_shoot: AudioStreamPlayer
var audio_hurt: AudioStreamPlayer
var audio_powerup: AudioStreamPlayer
var audio_click: AudioStreamPlayer

func _ready():
	audio_shoot = AudioStreamPlayer.new()
	audio_shoot.stream = STREAM_SHOOT
	audio_shoot.max_polyphony = 8
	add_child(audio_shoot)

	audio_hurt = AudioStreamPlayer.new()
	audio_hurt.stream = STREAM_HURT
	audio_hurt.max_polyphony = 3
	add_child(audio_hurt)

	audio_powerup = AudioStreamPlayer.new()
	audio_powerup.stream = STREAM_POWERUP
	audio_powerup.max_polyphony = 3
	add_child(audio_powerup)

	audio_click = AudioStreamPlayer.new()
	audio_click.stream = STREAM_CLICK
	audio_click.max_polyphony = 4
	add_child(audio_click)

	if FileAccess.file_exists(HS_FILE):
		var read_file = FileAccess.open(HS_FILE, FileAccess.READ)
		if read_file != null:
			var text_inside = read_file.get_as_text().strip_edges()
			read_file.close()
			if text_inside.is_valid_int():
				high_score = int(text_inside)

func xp_for_next_level():
	return 50 + (level - 1) * 25

func addXP(amount):
	xp = xp + amount
	while xp >= xp_for_next_level():
		xp = xp - xp_for_next_level()
		level = level + 1
		print("LEVEL UP", level)
		leveled_up.emit(level)
		PlayPowerup()

func bump_kill_counter():
	killcount = killcount + 1

func reset():
	xp = 0
	level = 1
	score = 0
	killcount = 0
	game_over = false
	runTime = 0.0

func save_high_score_if_beaten():
	if score > high_score:
		high_score = score
		var write_file = FileAccess.open(HS_FILE, FileAccess.WRITE)
		if write_file != null:
			write_file.store_string(str(high_score))
			write_file.close()

func playShootSound():
	if sfx_on and audio_shoot != null:
		audio_shoot.play()

func play_hurt():
	if sfx_on and audio_hurt != null:
		audio_hurt.play()

func PlayPowerup():
	if sfx_on and audio_powerup != null:
		audio_powerup.play()

func play_click():
	if sfx_on and audio_click != null:
		audio_click.play()

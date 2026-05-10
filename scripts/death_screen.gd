extends Control

func _ready():
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE
	$Button.pressed.connect(_on_restart_pressed)
	$Button2.pressed.connect(_on_exit_pressed)

func _on_restart_pressed():
	Globals.play_click()
	Globals.reset()
	get_tree().reload_current_scene()

func _on_exit_pressed():
	Globals.play_click()
	get_tree().quit()

func _process(_delta):
	if Globals.game_over == true:
		visible = true
		mouse_filter = MOUSE_FILTER_STOP
	else:
		visible = false
		mouse_filter = MOUSE_FILTER_IGNORE

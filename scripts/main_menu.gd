extends Control

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	var high_score_label = get_node_or_null("HighScoreLabel")
	if high_score_label != null:
		high_score_label.text = "High Score: " + str(Globals.high_score)
	$Button.pressed.connect(_on_play_pressed)
	$Button2.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	Globals.play_click()
	Globals.reset()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_pressed():
	Globals.play_click()
	get_tree().quit()

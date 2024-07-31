extends Control
@onready var play = $TextureRect/MarginContainer/VBoxContainer/VBoxContainer2/Play/NinePatchRect/Label
@onready var settings = $TextureRect/MarginContainer/VBoxContainer/VBoxContainer2/Settings/NinePatchRect/Label
@onready var quit = $TextureRect/MarginContainer/VBoxContainer/VBoxContainer2/Quit/NinePatchRect/Label
@onready var settings_menu = $TextureRect/InputSettings

func _ready():
	play.text = "play"
	settings.text = "settings"
	quit.text = "quit"
	settings_menu.close()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/dungeon/level_manager.tscn")


func _on_settings_pressed():
	if settings_menu.isOpen:
			settings_menu.close()
	else:
		settings_menu.open()


func _on_quit_pressed():
	get_tree().quit()


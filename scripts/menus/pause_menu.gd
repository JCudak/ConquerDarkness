extends Control


@onready var settings = $"../InputSettings"
@onready var canvas_layer = $".."

func resume():
	get_tree().paused = false
	
	visible = false
	$AnimationPlayer.play_backwards("pause_blur_animation")
	
func pause():
	get_tree().paused = true
	
	visible = true
	$AnimationPlayer.play("pause_blur_animation")
	
func testInput():
	if Input.is_action_just_pressed("pause") and visible == false:
		pause()
	elif Input.is_action_just_pressed("pause") and visible == true:
		if !canvas_layer.is_map_open:
			resume()
		else:
			visible = false
			$AnimationPlayer.play_backwards("pause_blur_animation")
			
		settings.close()

# buttons

func _on_resume_pressed():
	resume()


func _on_settings_pressed():
	if settings.isOpen:
			settings.close()
	else:
		settings.open()


func _on_quit_pressed():
	get_tree().quit()


@onready var resume_button_label = $NinePatchRect/GridContainer/Resume/NinePatchRect/Label
@onready var settings_button_label = $NinePatchRect/GridContainer/Settings/NinePatchRect/Label
@onready var quit_button_label = $NinePatchRect/GridContainer/Quit/NinePatchRect/Label

@onready var resume_button = $NinePatchRect/GridContainer/Resume
@onready var settings_button= $NinePatchRect/GridContainer/Settings
@onready var quit_button = $NinePatchRect/GridContainer/Quit

func _ready():
	resume_button_label.text = "Resume"
	settings_button_label.text = "Settings"
	quit_button_label.text = "Quit"
	
	resume_button.self_modulate = Color("ffffff00")
	settings_button.self_modulate = Color("ffffff00")
	quit_button.self_modulate = Color("ffffff00")
	
	visible = false
	
	$AnimationPlayer.play("RESET")


func _process(delta):
	testInput()
	

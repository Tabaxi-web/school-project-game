extends Node2D

@export var wave_number_label: Label
@export var upgrade_label: Label
var wave_number: int
var wait_time := 2.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# A bunch of visual stuff. 
	wave_number = Globals.wave - 1
	wave_number_label.text = str(wave_number)
	await get_tree().create_timer(wait_time).timeout
	wave_number = Globals.wave
	wave_number_label.text = str(wave_number)
	if Globals.wave % Globals.upgrade_screen_how_often == 0:
		upgrade_label.visible = true
	await get_tree().create_timer(wait_time).timeout
	# Send the player to a scene, depending
	if Globals.wave % Globals.upgrade_screen_how_often == 0:
		get_tree().change_scene_to_file("res://scenes/upgrade_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")

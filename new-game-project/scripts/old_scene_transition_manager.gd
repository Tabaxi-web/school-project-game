extends Node2D

@export var old_wave_label: Label
@export var new_wave_label: Label
@export var upgrade_label: Label
@export var old_pos: Control
@export var current_pos: Control
@export var future_pos: Control
var wave_number: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	wave_number = Globals.wave - 1
	if Globals.wave % Globals.upgrade_screen_how_often == 0:
		upgrade_label.visible = true
	
	old_wave_label.text = "-" + str(Globals.wave - 1)
	new_wave_label.text = "-" + str(Globals.wave)
	old_wave_label.global_position = current_pos.global_position
	new_wave_label.global_position = future_pos.global_position
	await get_tree().create_timer(1.5).timeout
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(old_wave_label, "global_position", old_pos.global_position, 2.0).from_current()
	tween.tween_property(new_wave_label, "global_position", current_pos.global_position, 2.0).from_current()
	print(str(current_pos.global_position))
	await tween.finished
	wave_number = Globals.wave
	await get_tree().create_timer(1.5).timeout
	if Globals.wave % Globals.upgrade_screen_how_often == 0:
		get_tree().change_scene_to_file("res://scenes/upgrade_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")

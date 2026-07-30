extends Node2D
@export var hover_sound: AudioStream
@export var select_sound: AudioStream
# Simple as main menu manager. Nothing complicated here.
func _on_play_button_down() -> void:
	_select_sound()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_quit_button_down() -> void:
	_select_sound()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _ready() -> void:
	Globals.reset_all_globals()


func _on_options_button_button_down() -> void:
	_select_sound()

func _on_button_hover() -> void:
	# Plays a sound when the player hovers.
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = hover_sound
	player.play()
	await player.finished
	player.queue_free()

func _select_sound() -> void:
	# ditto for the click
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = select_sound
	player.play()
	await player.finished
	player.queue_free()

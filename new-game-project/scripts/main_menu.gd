extends Node2D
@export var hover_sound: AudioStream
@export var select_sound: AudioStream
@export var options_menu: Control
@export var master_slider: HSlider
@export var music_slider: HSlider
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
	#initialise the volume sliders to the master volume :=ed in the globals script.
	master_slider.value = Globals.master_volume
	music_slider.value = Globals.music_volume


func _on_options_button_button_down() -> void:
	_select_sound()
	options_menu.visible = true

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


func _on_return_button_pressed() -> void:
	_select_sound()
	options_menu.visible = false

# Use one signal that resets both volume values, for brevity.
func _on_slider_drag_ended(_value_changed: bool) -> void:
	Globals.master_volume = master_slider.value
	Globals.music_volume = music_slider.value

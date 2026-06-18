extends Node2D

# Simple as main menu manager. Nothing complicated here.
func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
func _on_quit_button_down() -> void:
	get_tree().quit()

func _ready() -> void:
	Globals.reset_all_globals()

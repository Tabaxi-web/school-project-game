extends Node2D


func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_options_button_down() -> void:
	pass # Replace with function body.


func _on_quit_button_down() -> void:
	get_tree().quit()

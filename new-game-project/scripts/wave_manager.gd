extends Node2D

var wave: int
var wave_enemies_amount: int
var enemies: Array
var enemies_left: int
var percent_enemies_left: float
var intermission := false
var in_wave := false
@export var enemy_scene: PackedScene
@export var playable_area: Control
@export var area_headway: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wave = 1
# For this function to work the playable area MUST be centred at (0,0)
func get_point_in_playable_area(area: Control, headway: float) -> Vector2:
	var new_vector = Vector2(0,0)
	new_vector.x = randf_range(-headway, headway) * (area.size.x/2)
	new_vector.y = randf_range(-headway, headway) * (area.size.y/2)
	return new_vector
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for enemy in enemies:
		if enemy == null:
			enemies.erase(enemy)
	if not intermission and not in_wave:
		wave_enemies_amount = wave * 10
		for i in range(wave_enemies_amount):
			var enemy = enemy_scene.instantiate()
			enemy.position = get_point_in_playable_area(playable_area, area_headway)
			enemies.append(enemy)
			add_sibling(enemy)
		in_wave = true
	enemies_left = len(enemies)
	if enemies_left < 1:
		wave += 1
		in_wave = false
	percent_enemies_left = (float(enemies_left) / float(wave_enemies_amount))

extends Node2D

var wave_enemies_amount: int
var enemies: Array
var enemies_left: int
var percent_enemies_left: float
var intermission := false
var in_wave := false
@export var enemy_scene: PackedScene
@export var ranged_enemy_scene: PackedScene
@export var playable_area: Control
@export var area_headway: float
@export var ranged_enemy_chance := 0.4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# For this function to work the playable area MUST be centred at (0,0)
func get_point_in_playable_area(area: Control, headway: float) -> Vector2:
	var new_vector = Vector2(0,0)
	new_vector.x = randf_range(-headway, headway) * (area.size.x/2)
	new_vector.y = randf_range(-headway, headway) * (area.size.y/2)
	return new_vector
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Important note. Waves are handled by the Globals autoload singleton. This just handles
# the spawning of enemies.
func _process(delta: float) -> void:
	for enemy in enemies:
		if enemy == null:
			enemies.erase(enemy)
	if not in_wave:
		wave_enemies_amount = ((Globals.wave - 1) * 7) + 2
		for i in range(wave_enemies_amount):
			if randf() < ranged_enemy_chance:
				var enemy = ranged_enemy_scene.instantiate()
				enemy.position = get_point_in_playable_area(playable_area, area_headway)
				enemies.append(enemy)
				add_sibling(enemy)
			else:
				var enemy = enemy_scene.instantiate()
				enemy.position = get_point_in_playable_area(playable_area, area_headway)
				enemies.append(enemy)
				add_sibling(enemy)
		in_wave = true
	enemies_left = len(enemies)
	if enemies_left < 1:
		in_wave = false
		Globals.intermission()
	percent_enemies_left = (float(enemies_left) / float(wave_enemies_amount))

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
@export var wave_scaling_coefficient := 5
@export var wave_scaling_bonus := 2
@export var wave_health_scaling := 100
@export var time_between_enemies_min := 2.0
@export var time_between_enemies_max := 3.5
@export var wave_time_between_enemies_coefficient := 0.1
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
			enemies_left -= 1
	if not in_wave:
		in_wave = true
		wave_enemies_amount = ((Globals.wave - 1) * wave_scaling_coefficient) + wave_scaling_bonus
		enemies_left = wave_enemies_amount
		time_between_enemies_max -= (wave_time_between_enemies_coefficient * Globals.wave)
		time_between_enemies_min -= (wave_time_between_enemies_coefficient * Globals.wave)
		for i in range(wave_enemies_amount):
			if randf() < ranged_enemy_chance:
				var enemy = ranged_enemy_scene.instantiate()
				enemy.position = get_point_in_playable_area(playable_area, area_headway)
				enemy.max_health = enemy.max_health + (Globals.wave - 1) * wave_health_scaling
				enemies.append(enemy)
				add_sibling(enemy)
			else:
				var enemy = enemy_scene.instantiate()
				enemy.position = get_point_in_playable_area(playable_area, area_headway)
				enemies.append(enemy)
				add_sibling(enemy)
			await get_tree().create_timer(randf_range(time_between_enemies_min, time_between_enemies_max)).timeout
		
	if enemies_left < 1:
		in_wave = false
		Globals.next_wave()
	percent_enemies_left = (float(enemies_left) / float(wave_enemies_amount))

extends Node2D

var wave_enemies_amount: int ## Amount of enemies in this wave.
var enemies: Array ## Array of enemy instances
var enemies_left: int ## How many enemies left in the wave
var percent_enemies_left: float ## percernt of that
var intermission := true # If true, don't run wave logic
var in_wave := false # If true, run wave logic
@export var enemy_scene: PackedScene ## Scene of the enemy.
@export var ranged_enemy_scene: PackedScene ## Scene of the ranged enemy.
@export var summoner_enemy_scene: PackedScene ## Scene of the summoner enemy.
@export var playable_area: Control ## Control which holds the bounds of the playable area
@export var area_headway: float ## how far away from the edges of the area to spawn the enemies.
@export var ranged_enemy_chance := 0.4 ## Chance for a ranged enemy
@export var summoner_enemy_chance := 0.1 ## ditto for summoner enemies.
@export var wave_scaling_coefficient := 5 ## Amount of enemies per new wave, coeffcient
@export var wave_scaling_bonus := 2 ## ^ plus this amount.
@export var wave_health_scaling := 100 ## How much more hp to give the enemies per wave
@export var time_between_enemies_min := 2.0
@export var time_between_enemies_max := 3.5
@export var wave_time_between_enemies_coefficient := 0.1 ## How much to decrease the time between enemies per wave
@export var player: Node2D ## The player
@export var wave_title_label: Label ## The wave titlecard
@export var upgrade_scene: PackedScene ## Upgrade screen to spawn.
@export var round_ui: CanvasLayer ## UI to show in the round
@export var wave_title_impact_time: float ## Time to wait for the wave title to show
@export var boss_enemy_scene: PackedScene ## boss enemy
@export var boss_wave := 13 ## which wave is the boss wave?
@export var boss_music: AudioStream ## Music to play for boss wave.
@export var music_player_node_name := "MusicPlayer" ## Music player name childed to the player
@export var win_screen_name := "res://scenes/win_screen.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.start_wave.connect(_begin_wave)
	Globals.upgrade_screen.connect(_upgrade_screen_make)
	Globals.reset_all_globals()
	_begin_wave()


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
		# if the enemy is leaving an empty space in the enemies array after it dies, remove it.
		if enemy == null:
			enemies.erase(enemy)
			enemies_left -= 1
	
	if not in_wave and not intermission: # Start the wave if it hasn't started yet.
		in_wave = true
		if not Globals.wave == boss_wave: # If not a boss wave...
			# Determine the wave enemies amount and initialise other spawning vars.
			wave_enemies_amount = ((Globals.wave - 1) * wave_scaling_coefficient) + wave_scaling_bonus
			enemies_left = wave_enemies_amount
			time_between_enemies_max -= (wave_time_between_enemies_coefficient * Globals.wave)
			time_between_enemies_min -= (wave_time_between_enemies_coefficient * Globals.wave)
			for i in range(wave_enemies_amount): # for all the enemy slots in the wave...
				if randf() < ranged_enemy_chance: # maybe do ranged.
					var enemy = ranged_enemy_scene.instantiate()
					enemy.position = get_point_in_playable_area(playable_area, area_headway)
					enemy.max_health = enemy.max_health + (Globals.wave) * wave_health_scaling
					enemies.append(enemy)
					add_sibling(enemy)
				elif randf() < summoner_enemy_chance: #  Maybe do summoner.
					var enemy = summoner_enemy_scene.instantiate()
					enemy.position = get_point_in_playable_area(playable_area, area_headway)
					enemy.max_health = enemy.max_health + (Globals.wave) * wave_health_scaling
					enemies.append(enemy)
					add_sibling(enemy)
				else: # Otherwise melee.
					var enemy = enemy_scene.instantiate()
					enemy.position = get_point_in_playable_area(playable_area, area_headway)
					enemies.append(enemy)
					add_sibling(enemy)
				# Wait a little between enemies.
				if is_inside_tree():
					await get_tree().create_timer(randf_range(time_between_enemies_min, time_between_enemies_max)).timeout
		else:
			# Boss wave! Spawn the boss in.
			var music_player: AudioStreamPlayer2D
			music_player = player.get_node(music_player_node_name)
			music_player.stream = boss_music
			music_player.play()
			var enemy = boss_enemy_scene.instantiate()
			enemy.position = Vector2.ZERO
			enemies.append(enemy)
			add_sibling(enemy)
			enemies_left = 1
		
	if enemies_left < 1 and not intermission:
		intermission = true
		in_wave = false
		player.frozen = true
		Globals.next_wave()
	percent_enemies_left = (float(enemies_left) / float(wave_enemies_amount))


func _begin_wave() -> void:
	
	# IF the player has cleared the boss wave, do a title card and send them to the screen
	if Globals.wave == boss_wave + 1:
		wave_title_label.visible = true
		wave_title_label.text = "YOU  "
		await get_tree().create_timer(wave_title_impact_time).timeout
		wave_title_label.text = "YOU WIN!"
		await get_tree().create_timer(wave_title_impact_time).timeout
		wave_title_label.visible = false
		get_tree().change_scene_to_file(win_screen_name)
		return
	
	# Otherwise, do a cool impact gamejuicey thing with the wave title.
	wave_title_label.visible = true
	wave_title_label.text = "WAVE  "
	await get_tree().create_timer(wave_title_impact_time).timeout
	wave_title_label.text = "WAVE " + str(Globals.wave)
	await get_tree().create_timer(wave_title_impact_time).timeout
	wave_title_label.visible = false
	round_ui.visible = true
	intermission = false
	player.frozen = false
	# If the player is out of bounds, teleport them into bounds.
	if not playable_area.get_rect().has_point(player.position):
		player.position = Vector2.ZERO

func _upgrade_screen_make() -> void:
	round_ui.visible = false
	wave_title_label.visible = true
	wave_title_label.text = "UPGRADE"
	await get_tree().create_timer(wave_title_impact_time).timeout
	wave_title_label.visible = false
	round_ui.get_parent().add_child(upgrade_scene.instantiate())

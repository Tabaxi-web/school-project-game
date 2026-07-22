extends CharacterBody2D

# -- MOVEMENT VARS --
@export_category("Movement")
@export var camera_wrapper: Node2D ## The Wrapper of the camera, which follows the player.
@export var camera: Camera2D ## Camera itself for shake effects.
@export var max_speed := 500.0 ## The length of velocity is limited to this value.
@export var acceleration := 3000.0 ## Controls the acceleration of the player.
@export var friction := 30 ## Velocity is multiplied by (1 - this * delta). The higher, the more friction.

# -- GAMEPLAY VARS --
@export_category("Gameplay")
@export var max_health := 100.0 ## The max health of the player.
@export var wave_manager: Node2D ## The wave manager. Player talks to it for the UI.
@export var dash_cooldown := 3.0
@export var dash_timer: Timer
@export var dash_strength := 500
@export var dash_decay_strength := 1
@export var dash_reload := false
var dash_direction: Vector2
var dash_power_left := 0
var health: float
var dash_on_cooldown := false

# -- GUN VARS --
@export_category("Gun")
@export var max_ammo := 10 ## Max ammo. Self Explainatory.
@export var automatic := true ## Whether the player can hold down shoot to keep shooting, or if they need to repeat inputs.
var shooting := false # If the player is shooting
var reloading := false # If the player is reloading
var ammo: int # The player's current ammo.
@export var fire_delay := 0.5 ## Controls the fire rate of the player's gun.
@export var bullets_per_shot := 5 ## Pellets per shot; good for shotguns.
@export var bullet_velocity := 1000 ## Velocity of the player's bullets.
@export var spread := PI / 8 ## The spread (inaccuracy) of the player's gun, in radians.
@export var reload_time := 2.0 ## Time it takes the player to reload.
@export var bullet_damage := 30.0 ## Damage of the player's bullets.
@export var crit_chance := 0.01
@export var crit_damage := 3
@export var homing_bullets := false
@export var damage_falloff := 0.01 #falloff of the player's bullets
# -- UI VARS --
@export_category("User Interface")
@export var bullet_cooldown_timer: Timer ## Timer that controls the player's fire rate.
@export var reload_timer: Timer ## Timer that controls the player's reload.
@export var health_label: Label ## Health bar - uses strings, not progress bar
@export var ammo_label: Label ## Ditto for ammo
@export var wave_timer_label: Label ## Ditto for wave timer
@export var bullet_scene: PackedScene ## Bullet scene to instantiate
@onready var pivot := $Pivot # Pivot that the player's sprite rotates around
@export var reloading_ui: Control ## UI for reloading.
@export var dashing_ui: Control
func _retro_bar_render(number: float, maximum: float, length: int) -> String: #this is for the retro health bar system. It's int based currently.
	var temp_string := "" #the return value
	var ratio = number / maximum # calculates the ratio between the max and value
	var real_number = round(ratio * length) # Figures out how many bars should be filled in
	for i in range(length):
		if i < real_number:
			temp_string += "■"
		else:
			temp_string += "□"
	return temp_string


func _ready() -> void:
	# Init gameplay variables.
	for upgrade in Globals.upgrades:
		_check_upgrades(upgrade)
	for upgrade in Globals.rare_upgrades:
		_check_upgrades(upgrade)
	bullets_per_shot = clampi(bullets_per_shot, 1, 50)
	health = max_health
	ammo = max_ammo
	bullet_cooldown_timer.wait_time = fire_delay
	reload_timer.wait_time = reload_time
	dash_timer.wait_time = dash_cooldown
	# Do basic upgrades first.
	
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Camera logic. Note the camera and player start CENTERED at 0,0.
	camera_wrapper.position = position
	#movement
	var direction: Vector2
	direction.x = Input.get_axis("movement_left", "movement_right")
	direction.y = Input.get_axis("movement_up", "movement_down")
	direction = direction.normalized() # Normalise!!

	if direction != Vector2.ZERO:
		# Move if the player is pressing a key.
		velocity += direction * acceleration * delta
	else:
		# Otherwise slow the player down.
		velocity *= 1 - (friction * delta)
	if Input.is_action_just_pressed("movement_dash") and not dash_on_cooldown and not direction == Vector2.ZERO:
		dash_timer.start()
		dash_on_cooldown = true
		dashing_ui.visible = true
		dash_power_left = dash_strength
		if dash_reload:
			ammo = clamp(ammo + max_ammo / 2, 0, max_ammo)
	if dash_power_left > 0:
		dash_power_left -= delta * dash_decay_strength
		
	dash_power_left = clampf(dash_power_left, 0, INF)
	if not dash_on_cooldown:
		dash_direction = direction
	velocity += dash_power_left * dash_direction
	velocity = velocity.limit_length(max_speed + dash_power_left) # Limit the player's speed.
	pivot.look_at(get_global_mouse_position())
	move_and_slide() # Note to self: put movement logic BEFORE move_and_slide(). You dumbass.
	
	#health and ammo ui updating 
	health_label.text = "Health: " + _retro_bar_render(health, max_health, 10)\
	+ " (" + str(health) + "/" + str(max_health) + ")"
	ammo_label.text = "Ammo: " + _retro_bar_render(ammo, max_ammo, 10)\
	+ " (" + str(ammo) + "/" + str(max_ammo) + ")"
	wave_timer_label.text = _retro_bar_render(wave_manager.enemies_left, wave_manager.wave_enemies_amount, 50)
	
	# Death Handling.
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	# Shooting!
	# If automatic and pressed, or semi and just pressed, and not shooting, and ammo left:
	if ((Input.is_action_pressed("shoot") and automatic)\
	or (Input.is_action_just_pressed("shoot") and not automatic))\
	and not shooting\
	and not reloading\
	and ammo >= 1:
		ammo -= 1
		bullet_cooldown_timer.start()
		shooting = true
		print("shooting")
		for i in range(bullets_per_shot):
			var new_bullet = bullet_scene.instantiate()
			new_bullet.position = position
			# Bullet Velocity is randomised based on both spread and itself!
			if not homing_bullets:
				new_bullet.speed = (bullet_velocity + (randf_range(-1, 1) * spread * (bullet_velocity / 5.0)))
			else:
				new_bullet.speed = bullet_velocity
			new_bullet.damage = bullet_damage
			new_bullet.crit_chance = crit_chance
			new_bullet.crit_damage = crit_damage
			new_bullet.homing = homing_bullets
			new_bullet.damage_falloff_coefficient = damage_falloff
			new_bullet.rotation = (pivot.rotation + (randf_range(-1, 1) * (spread/2)))
			add_sibling(new_bullet)
	
	# Otherwise the same logic for auto and semi, but reloading, if the player has <1 ammo left.
	elif ((ammo < 1\
	and ((Input.is_action_just_pressed("shoot") and not automatic) or\
	(Input.is_action_pressed("shoot") and automatic)))\
	or Input.is_action_just_pressed("reload"))\
	and not reloading\
	and not shooting:
		reloading = true
		reload_timer.start()
		reloading_ui.visible = true
		
		await reload_timer.timeout
		reloading_ui.visible = false
		reloading = false
		ammo = max_ammo
	
	# Fancy reload animation bar refill. This is cosmetic as you can't shoot while reloading.
	if reloading:
		@warning_ignore("narrowing_conversion")
		ammo = (max_ammo * (1 - (reload_timer.time_left / reload_time)))
# Stop shooting when done shooting.
func _on_bullet_cooldown_timeout() -> void:
	shooting = false
func take_damage(damage: float) -> void:
	camera.shake(0.4)
	health -= damage


func _check_upgrades(upgrade) -> void:
	if upgrade["name"] == "Hollow Point I":
		bullet_damage *= 1.5
	if upgrade["name"] == "Gunner I":
		fire_delay *= 0.2
	if upgrade["name"] == "Buckshot I":
		bullets_per_shot *= 5
		spread += PI / 8
		reload_time += 1
		damage_falloff += 0.05
	if upgrade["name"] == "Commando I":
		max_ammo *= 2.5
		reload_time *= 0.7
	if upgrade["name"] == "Sharpshooter I":
		crit_chance += 0.09
		bullet_velocity *= 1.2
	if upgrade["name"] == "Sharpshooter II":
		crit_damage += 0.5
	if upgrade["name"] == "Focus I":
		spread /= 2
		bullet_velocity /= 1.5
		damage_falloff  -= 0.1
	if upgrade["name"] == "Starburst":
		bullets_per_shot += 5
		spread = 2 * PI
		bullet_damage *= 0.7
		homing_bullets = true
		damage_falloff = 0
	if upgrade["name"] == "Laserbeam":
		bullets_per_shot = 1
		spread = 0
		fire_delay = 0.01
		bullet_damage /= 10
		max_ammo *= 50
	if upgrade["name"] == "Minesweeper":
		bullets_per_shot = 1
		fire_delay = clampf(fire_delay, 0.5, 99)
		bullet_velocity = 0
		bullet_damage *= 20
	if upgrade["name"] == "Commando II":
		dash_reload = true


func _on_dash_timer_timeout() -> void:
	dash_on_cooldown = false
	dashing_ui.visible = false

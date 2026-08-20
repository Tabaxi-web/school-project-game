extends CharacterBody2D
@export var max_health := 100.0 ## Max health of the enemy.
var health: float
var player: CharacterBody2D
@export var health_bar : ProgressBar ## Health bar progressbar.
var acceleration := 50.0 ## Acceleration of the movement.
var max_speed := 200.0 ## Max speed.
@export var base_max_speed := 200.0
@export var dashing_max_speed := 600.0
@export var base_acceleration := 50.0
@export var dashing_acceleration := 5.0
@export var attack_area : Area2D ## Area for the melee attacks of the enemy.
@export var attack_timer: Timer ## Cooldown timer for melee attacks
@export var attack_damage := 5 ## How much damage melee attacks do
@export var stopping_distance := 50.0 ## How close the enemy will stop trying to move to the player
@export var friction_coeff := 5.0 ## How much friction the movement of the enemy has
@export var ranged := false ## Whether the enemy is ranged or not.
@export var death_fx: PackedScene ## Death effect for the enemy
@export var death_sfx: AudioStream
@export var eyes_move_dist := 10.0 ## How far the eyes will sit from the centre.
@export var eyes_sprite: Sprite2D ## The eyes sprite.
@export var eyes_angle_quantisation := PI/8 ## how much the eyes snap, in RADIANS.
@export var eyes_predictive_weight := 0.5 ## How weighted the projected path of the player is to where the enemy will look
@export var healing_orb_prefab: PackedScene
enum PHASES {RANGED, DASH, AREAS}
var phase: PHASES
@export var starting_phase: PHASES
@export var ranged_phase_attack_delay := 0.2
@export var area_phase_attack_delay := 1.0
# --- BULLET VARS: only important for ranged enemies ---
@export var bullet_prefab: PackedScene ## Does not matter for melee enemies.
@export var bullet_velocity := 500 ## Velocity of the player's bullets.
@export var bullet_damage := 30.0 ## Damage of the player's bullets.
@export var area_prefab: PackedScene
var cooling_down := false ## Whether the enemy is cooling down from an attack or not.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	# Assign player.
	for node in get_tree().get_nodes_in_group("Player"):
		player = node
	health_bar.value = health / max_health
	phase = starting_phase


func _process(delta: float) -> void:
	if player == null:
		return
	# Health handling.
	if health <= 0:
		# Die, instantiation various stuff etc.
		Globals.play_sound(death_sfx)
		var fx = death_fx.instantiate()
		fx.global_position = position
		add_sibling(fx)
		fx.emitting = true
		if randf() < Globals.healing_orbs_chance and Globals.healing_orbs:
			var orb = healing_orb_prefab.instantiate()
			orb.global_position = global_position
			add_sibling(orb)
		queue_free()
	
	#Look at the player.
	var eyes_angle
	if ranged:
		# This weights the actual direction of the player vs where the enemy think they'll be
		eyes_angle = lerp(predictive_rotation(player), position.direction_to(player.position).angle(), eyes_predictive_weight)
	else:
		# No need to do allat for melee enemies.
		eyes_angle = position.direction_to(player.position).angle()
	eyes_angle = snapped(eyes_angle, eyes_angle_quantisation)
	eyes_sprite.position = eyes_move_dist * Vector2.from_angle(eyes_angle)
	# Movement.
	
	# If the enemy is further away than the stopping distance, move towards them.
	if position.distance_to(player.position) > stopping_distance:
		velocity += delta * acceleration * (player.position - position)
		velocity = velocity.limit_length(max_speed)
	else:
		# Otherwise, slow down.
		velocity *= (1 / friction_coeff) * delta
	
	move_and_slide()
	
	if phase == PHASES.DASH:
		#basic melee attack.
		if not cooling_down:
			for body in attack_area.get_overlapping_bodies():
				if body == player:
					cooling_down = true
					player.take_damage(attack_damage)
					attack_timer.start()
					
	if phase == PHASES.RANGED: 
		attack_timer.wait_time = ranged_phase_attack_delay
		if not cooling_down:
			# This bullet logic is about the same as the player's.
			var new_bullet = bullet_prefab.instantiate()
			new_bullet.position = position
			new_bullet.speed = bullet_velocity
			new_bullet.damage = bullet_damage
			new_bullet.rotation = predictive_rotation(player)
			add_sibling(new_bullet)
			cooling_down = true
			attack_timer.start()
			
	if phase == PHASES.AREAS: # summons an area on the player.
		attack_timer.wait_time = area_phase_attack_delay
		if not cooling_down:
			var new_bullet = area_prefab.instantiate()
			new_bullet.position = player.position
			new_bullet.damage = bullet_damage
			add_sibling(new_bullet)
			cooling_down = true
			attack_timer.start()
		


func take_damage(damage: float) -> void:
	var tween = get_tree().create_tween()
	health -= damage
	tween.tween_property(health_bar, "value", health / max_health, 0.2)
	
func _on_attack_timer_timeout() -> void:
	cooling_down = false
	
func predictive_rotation(body) -> float: #lets the enemy know WHERE the player is gonna be.
	var predicted_position: Vector2
	var time := bullet_velocity / position.distance_to(body.position)
	predicted_position = body.position + (body.velocity * time)
	return (predicted_position - position).angle()

func predictive_position(body) -> Vector2:
	var time := bullet_velocity / position.distance_to(body.position)
	return body.position + (body.velocity * time)

func _on_phase_timer_timeout() -> void:
	if phase == PHASES.DASH:
		acceleration = base_acceleration
		attack_timer.wait_time = area_phase_attack_delay
		phase = PHASES.AREAS
		max_speed = base_max_speed
	elif phase == PHASES.AREAS:
		acceleration = base_acceleration
		attack_timer.wait_time = ranged_phase_attack_delay
		phase = PHASES.RANGED
		max_speed = base_max_speed
	elif phase == PHASES.RANGED:
		acceleration = dashing_acceleration
		attack_timer.wait_time = area_phase_attack_delay
		phase = PHASES.DASH
		max_speed = dashing_max_speed

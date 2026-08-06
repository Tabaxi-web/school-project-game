extends CharacterBody2D
@export var max_health := 100.0 ## Max health of the enemy.
var health: float
var player: CharacterBody2D
@export var health_bar : ProgressBar ## Health bar progressbar.
@export var acceleration := 50 ## Acceleration of the movement.
@export var max_speed := 200 ## Max speed.
@export var attack_area : Area2D ## Area for the melee attacks of the enemy.
@export var attack_timer: Timer ## Cooldown timer for melee attacks
@export var attack_damage := 5 ## How much damage melee attacks do
@export var stopping_distance := 50.0 ## How close the enemy will stop trying to move to the player
@export var ranged_stopping_distance := 600.0 ## How close the enemy (if it is ranged) will stop
@export var ranged_backaway_coefficient := 3 ## What fraction of the stopping distance the player must be for it to back away.
@export var friction_coeff := 5.0 ## How much friction the movement of the enemy has
@export var ranged := false ## Whether the enemy is ranged or not.
@export var death_fx: PackedScene ## Death effect for the enemy
@export var death_sfx: AudioStream
@export var eyes_move_dist := 10.0 ## How far the eyes will sit from the centre.
@export var eyes_sprite: Sprite2D ## The eyes sprite.
@export var eyes_angle_quantisation := PI/8 ## how much the eyes snap, in RADIANS.
@export var eyes_predictive_weight := 0.5 ## How weighted the projected path of the player is to where the enemy will look
@export var healing_orb_prefab: PackedScene
# --- BULLET VARS: only important for ranged enemies ---
@export var bullet_prefab: PackedScene ## Does not matter for melee enemies.
@export var bullet_velocity := 500 ## Velocity of the player's bullets.
@export var bullet_damage := 30.0 ## Damage of the player's bullets.
var cooling_down := false ## Whether the enemy is cooling down from an attack or not.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	# Assign player.
	for node in get_tree().get_nodes_in_group("Player"):
		player = node
	health_bar.value = health / max_health


func _process(delta: float) -> void:
	if player == null:
		return
	# Health handling.
	if health <= 0:
		_play_sound(death_sfx)
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
	
	if not ranged:
		# If the enemy is further away than the stopping distance, move towards them.
		if position.distance_to(player.position) > stopping_distance:
			velocity += delta * acceleration * (player.position - position)
			velocity = velocity.limit_length(max_speed)
		else:
			# Otherwise, slow down.
			velocity *= (1 / friction_coeff) * delta
	if ranged:
		# Same thing, but it'll move away if the player is too close.
		if position.distance_to(player.position) > ranged_stopping_distance:
			velocity += delta * acceleration * (player.position - position)
			velocity = velocity.limit_length(max_speed)
		elif position.distance_to(player.position) < ranged_stopping_distance / ranged_backaway_coefficient:
			velocity += delta * acceleration * -(player.position - position)
			velocity = velocity.limit_length(max_speed)
		else:
			velocity *= (1 / friction_coeff) * delta
	
	move_and_slide()
	
	if not ranged:
		#basic melee attack.
		if not cooling_down:
			for body in attack_area.get_overlapping_bodies():
				if body == player:
					cooling_down = true
					player.take_damage(attack_damage)
					attack_timer.start()
	if ranged: 
		if not cooling_down and position.distance_to(player.position) < ranged_stopping_distance:
			# This bullet logic is about the same as the player's.
			var new_bullet = bullet_prefab.instantiate()
			new_bullet.position = position
			new_bullet.speed = bullet_velocity
			new_bullet.damage = bullet_damage
			new_bullet.rotation = predictive_rotation(player)
			add_sibling(new_bullet)
			cooling_down = true
			attack_timer.start()


func take_damage(damage: float) -> void:
	var tween = get_tree().create_tween()
	health -= damage
	tween.tween_property(health_bar, "value", health / max_health, 0.2)
	
func _on_attack_timer_timeout() -> void:
	cooling_down = false
	
func predictive_rotation(body) -> float:
	var predicted_position: Vector2
	var time := bullet_velocity / position.distance_to(body.position)
	predicted_position = body.position + (body.velocity * time)
	return (predicted_position - position).angle()

func _play_sound(sound: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	add_sibling(player)
	player.stream = sound
	player.play()
	await player.finished
	player.queue_free()

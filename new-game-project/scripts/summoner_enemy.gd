extends CharacterBody2D

## This script is specific to the summoner enemy type.

@export var max_health := 100.0 ## Max health of the enemy.
var health: float
var player: CharacterBody2D
@export var health_bar : ProgressBar ## Health bar progressbar.
@export var acceleration := 50 ## Acceleration of the movement.
@export var max_speed := 200 ## Max speed.
@export var attack_timer: Timer ## Cooldown timer for melee attacks
@export var stopping_distance := 1000.0 ## How close the enemy will stop trying to move to the player
@export var friction_coeff := 5.0 ## How much friction the movement of the enemy has
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
@export var attack_width := 50.0
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
		
	if position.distance_to(player.position) > stopping_distance:
		velocity += delta * acceleration * (player.position - position)
		velocity = velocity.limit_length(max_speed)
	else:
		velocity *= (1 / friction_coeff) * delta
	
	move_and_slide()

	if not cooling_down and position.distance_to(player.position) < stopping_distance:
		# This bullet logic summons an evil area on the player.
		var new_bullet = bullet_prefab.instantiate()
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
	
func predictive_rotation(body) -> float:
	var predicted_position: Vector2
	var time := bullet_velocity / position.distance_to(body.position)
	predicted_position = body.position + (body.velocity * time)
	return (predicted_position - position).angle()

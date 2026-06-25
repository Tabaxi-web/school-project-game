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
@export var friction_coeff := 5.0 ## How much friction the movement of the enemy has
@export var ranged := false ## Whether the enemy is ranged or not.
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
		queue_free()

	# Movement.
	if not ranged:
		if position.distance_to(player.position) > stopping_distance:
			velocity += delta * acceleration * (player.position - position)
			velocity = velocity.limit_length(max_speed)
		else:
			velocity *= (1 / friction_coeff) * delta
	if ranged:
		look_at(player.position)
		if position.distance_to(player.position) > ranged_stopping_distance:
			velocity += delta * acceleration * (player.position - position)
			velocity = velocity.limit_length(max_speed)
		elif position.distance_to(player.position) < ranged_stopping_distance / 3:
			velocity += delta * acceleration * -(player.position - position)
			velocity = velocity.limit_length(max_speed)
		else:
			velocity *= (1 / friction_coeff) * delta
	move_and_slide()
	if not ranged:
		if not cooling_down:
			for body in attack_area.get_overlapping_bodies():
				if body == player:
					cooling_down = true
					player.take_damage(attack_damage)
					attack_timer.start()
	if ranged: 
		if not cooling_down and position.distance_to(player.position) < ranged_stopping_distance:
			var new_bullet = bullet_prefab.instantiate()
			new_bullet.position = position
			# Bullet Velocity is randomised based on both spread and itself!
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
	print("recovered")
	cooling_down = false
	
func predictive_rotation(body) -> float:
	var predicted_position: Vector2
	var time := bullet_velocity / position.distance_to(body.position)
	predicted_position = body.position + (body.velocity * time)
	return (predicted_position - position).angle()

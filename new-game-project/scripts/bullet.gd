extends Area2D

## fork of the bullet script for AOE attacks.

var speed: float # Speed of the bullet, assigned by player on instantiation
var damage: float # Ditto for damage
var crit_chance: float # Ditto for crit chance
var crit_damage: float # Ditto for crit damage
@export var damage_text: PackedScene ## Prefab for damage text
@export var lifetime := 5.0 ## lifetime of the bullet
@export var allied := true ## Whether the bullet is allied with the player or not
@export var homing := false ## Whether the bullet homes, like in starburst.
@export var damage_falloff_coefficient := 0.005
@export var damage_falloff_coeffecient_2 := 0.0001 ## How much to reduce the damage by as the bullet travels
var target: Node2D # Only relevant for homing bullets. Defines the target.
var lifetime_timer: SceneTreeTimer # The timer that defines how long a bullet is "alive"
@export var acquisition_time_ratio := 0.9 ## How fast the homing bullets will lock on
# Called when the node enters the scene tree for the first time.
@export var homing_spawn_speed_divisor := 10.0 ## Drifts the bullet at a speed divided by this when spawning homing.
@export var homing_speed_power := 1.5 ## Exponent for time alive component of the homing bullet's speed
@export var spin_coefficient := 0.1 ## Whee!
func _ready() -> void:
	# Destroy the bullet after its lifetime is up
	if homing:
		# if the bullet is homing, make it grab a target upon spawning
		target = _homing_acquire()
	lifetime_timer = get_tree().create_timer(lifetime)
	await lifetime_timer.timeout
	queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move the bullet along
	if len(get_tree().get_nodes_in_group("Enemies")) == 0:
		#destroy the bullet if no enemies are alive.
		queue_free()
	if homing and is_instance_valid(target):
		# Make the homing bullet drift a little before locking on.
		if lifetime_timer.time_left / lifetime > acquisition_time_ratio:
			move_local_x((speed * delta) / homing_spawn_speed_divisor)
		else:
			# Disgusting line of code. In a nutshell, exponentially increase speed towards an enemy relative to how long the bullet is alive times speed.
			position += (pow((1 + acquisition_time_ratio) - (lifetime_timer.time_left / lifetime), homing_speed_power)) * delta * global_position.direction_to(target.position) * speed
	elif homing:
		# If the bullet has no target as a homing bullet, acquire a new one.
		target = _homing_acquire()
	else:
		move_local_x(speed * delta)
	# Put some spin on it for fun
	$SpriteContainer.rotation += (speed * delta) * spin_coefficient
	# Damage falloff. Clamps to 0 so no enemy healing.
	damage = damage - (speed * (lifetime - lifetime_timer.time_left) * damage_falloff_coefficient * damage * delta)
	damage = clampf(damage, 0, INF)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies") and allied: # Enemies must all have a take_damage() method
		if randf() < crit_chance: # Check for crits
			body.take_damage(damage * crit_damage)
			# Damage text things
			var new_damage_text = damage_text.instantiate()
			new_damage_text.position = body.position
			new_damage_text.label.text = str(round(damage * crit_damage)) + "!!!"
			add_sibling(new_damage_text)
		else:
			body.take_damage(damage)
			# Damage text things.
			var new_damage_text = damage_text.instantiate()
			new_damage_text.position = body.position
			new_damage_text.label.text = str(round(damage))
			new_damage_text.label.add_theme_font_size_override("font_size", 15)
			add_sibling(new_damage_text)
		# Destroy if not piercing.
		queue_free()
	elif body.is_in_group("Player") and not allied:
		body.take_damage(damage)
		queue_free()

func _homing_acquire() -> Node2D:
	# Simple iterative function which finds the closest enemy. Enemy bullets will never be homing so no player compatibility needed.
	var min_distance := INF
	var new_target: Node2D
	for node in get_tree().get_nodes_in_group("Enemies"):
			if global_position.distance_squared_to(node.global_position) < min_distance:
				min_distance = global_position.distance_squared_to(node.global_position)
				new_target = node
	return new_target

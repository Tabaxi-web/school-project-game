extends Area2D
var speed: float # Speed of the bullet, assigned by player on instantiation
var damage: float # Ditto for damage
var crit_chance: float # Ditto for crit chance
var crit_damage: float # Ditto for crit damage
@export var damage_text: PackedScene # Prefab for damage text
@export var lifetime := 5.0 # lifetime of the bullet
@export var allied := true # Whether the bullet is allied with the player or not
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Destroy the bullet after its lifetime is up
	await get_tree().create_timer(lifetime).timeout #
	queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move the bullet along
	move_local_x(speed * delta)
	# Put some spin on it for fun
	$SpriteContainer.rotation += (speed * delta) / 10



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies") and allied: # Enemies must all have a take_damage() method
		if randf() < crit_chance: # Check for crits
			body.take_damage(damage * crit_damage)
			# Damage text things
			var new_damage_text = damage_text.instantiate()
			new_damage_text.position = body.position
			new_damage_text.label.text = str(damage * crit_damage) + "!!!"
			add_sibling(new_damage_text)
		else:
			body.take_damage(damage)
			# Damage text things.
			var new_damage_text = damage_text.instantiate()
			new_damage_text.position = body.position
			new_damage_text.label.text = str(damage)
			new_damage_text.label.add_theme_font_size_override("font_size", 15)
			add_sibling(new_damage_text)
		# Destroy if not piercing.
		queue_free()
	elif body.is_in_group("Player") and not allied:
		body.take_damage(damage)
		queue_free()

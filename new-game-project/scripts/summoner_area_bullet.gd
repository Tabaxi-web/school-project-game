extends Area2D
var speed: float # Speed of the bullet, assigned by player on instantiation
var damage: float # Ditto for damage
var crit_chance: float # Ditto for crit chance
var crit_damage: float # Ditto for crit damage
@export var lifetime := 5.0 ## lifetime of the bullet
@onready var explosion_delay := lifetime * 0.90
@export var allied := true ## Whether the bullet is allied with the player or not
@export var indicator_circle: Sprite2D
@export var progress_circle: Sprite2D
@export var area_scale := 3.0
@export var explosion_prefab: PackedScene
@export var explosion_sound: AudioStream
var exploded := false
var lifetime_timer: SceneTreeTimer # The timer that defines how long a bullet is "alive"


func _ready() -> void:
	# Destroy the bullet after its lifetime is up
	scale.x = area_scale 
	scale.y = area_scale
	indicator_circle.global_scale.x = area_scale
	indicator_circle.global_scale.y = area_scale
	lifetime_timer = get_tree().create_timer(lifetime)
	await lifetime_timer.timeout
	queue_free()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if len(get_tree().get_nodes_in_group("Enemies")) == 0:
		#destroy the bullet if no enemies are alive.
		queue_free()
	# Provide an indicator of how close the area is to exploding.
	if (lifetime - lifetime_timer.time_left) < explosion_delay and not exploded:
		progress_circle.global_scale.x = (lifetime - lifetime_timer.time_left) / explosion_delay * area_scale
		progress_circle.global_scale.y = (lifetime - lifetime_timer.time_left) / explosion_delay * area_scale
	elif not exploded: # Explode!!
		exploded = true
		var explosion = explosion_prefab.instantiate()
		explosion.global_position = global_position
		explosion.scale.x = area_scale
		explosion.scale.y = area_scale
		add_sibling(explosion)
		explosion.emitting = true
		Globals.play_sound(explosion_sound)
		for victim in get_overlapping_bodies():
			_explode(victim)


func _explode(body: Node2D) -> void:
	if body.is_in_group("Player") and not allied:
		body.take_damage(damage)
		queue_free()

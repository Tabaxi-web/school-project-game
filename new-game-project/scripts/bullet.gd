extends Area2D
var speed: float
var damage: float
var crit_chance: float
var crit_damage: float
var hit := false
@export var damage_text: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(5).timeout
	queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_local_x(speed * delta)
	
	$SpriteContainer.rotation += (speed * delta) / 10
	pass



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies") and not hit:
		print(crit_chance)
		if randf() < crit_chance:
			body.take_damage(damage * crit_damage)
			var new_damage_text = damage_text.instantiate()
			new_damage_text.position = body.position
			new_damage_text.label.text = str(damage * crit_damage) + "!!!"
			add_sibling(new_damage_text)
		else:
			body.take_damage(damage)
			var new_damage_text = damage_text.instantiate()
			new_damage_text.position = body.position
			new_damage_text.label.text = str(damage)
			new_damage_text.label.add_theme_font_size_override("font_size", 15)
			add_sibling(new_damage_text)
		
		hit = true
		queue_free()

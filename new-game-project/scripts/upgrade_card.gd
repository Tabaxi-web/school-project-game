extends VBoxContainer

@export var number_label: Label ## The label for the number (out of three) the upgrade is.
@export var upgrade_name_label: Label ## The label for the upgrade name
@export var upgrade_description_label: Label ## Ditto for the description
@export var upgrade_number: int ## The number out of 3 the upgrade is
@export var upgrade_name := ""
@export var upgrade_description := ""
@export var upgrade: Dictionary
@export var texture_rect: TextureRect
@export var holder: Control
@export var holder_index: int
@export var transport_time := 0.25
var prev_holder: Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	number_label.text = str(upgrade_number) + " of 3"
	upgrade_name_label.text = upgrade_name
	
	upgrade_description_label.text = upgrade_description
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("Upgrade Card Holders") != []:
		holder = get_tree().get_nodes_in_group("Upgrade Card Holders")[holder_index]
	if prev_holder != holder:
		var tween_thing = get_tree().create_tween()
		tween_thing.tween_property(self, "global_position", holder.global_position, transport_time)
	prev_holder = holder

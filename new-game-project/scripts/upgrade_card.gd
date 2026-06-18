extends VBoxContainer

@export var number_label: Label ## The label for the number (out of three) the upgrade is.
@export var upgrade_name_label: Label ## The label for the upgrade name
@export var upgrade_description_label: Label ## Ditto for the description
@export var upgrade_number: int ## The number out of 3 the upgrade is
@export var upgrade_name := ""
@export var upgrade_description := ""
@export var upgrade: Dictionary
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	number_label.text = str(upgrade_number) + " of 3"
	upgrade_name_label.text = upgrade_name
	upgrade_description_label.text = upgrade_description
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

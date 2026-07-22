extends FlowContainer
@export var texture_rect_prefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for upgrade in Globals.upgrades:
		if upgrade["icon_path"] != null:
			var icon_rect = texture_rect_prefab.instantiate()
			icon_rect.texture = load(upgrade["icon_path"])
			add_child(icon_rect)
	for upgrade in Globals.rare_upgrades:
		if upgrade["icon_path"] != null:
			var icon_rect = texture_rect_prefab.instantiate()
			icon_rect.texture = load(upgrade["icon_path"])
			add_child(icon_rect)

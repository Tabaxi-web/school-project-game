extends FlowContainer
@export var texture_rect_prefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _refresh() -> void:
	for child in get_children():
		if child.get_index() == 0:
			continue
		child.queue_free()
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
func _ready() -> void:
	call_deferred("_start")

func _start() -> void:
	_refresh()
	Globals.start_wave.connect(_refresh)

extends Node2D

@export var upgrades_amount := 3
@export var upgrade_card_prefab: PackedScene
@export var upgrade_card_carousel: HBoxContainer
@export var rare_rarity := 0.1
@export var upgrade_cards: Array
@export var non_selected_transparency := 0.3
var upgrades_this_time := []
var chance_index := 0.0
var current_card: Control
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	var i := 0
	if len(Globals.potential_common_upgrades) + len(Globals.potential_rare_upgrades) <= 0:
		push_error("No upgrades left!!")
		get_tree().call_deferred("quit")
	if len(Globals.potential_common_upgrades) + len(Globals.potential_rare_upgrades) < upgrades_amount:
		upgrades_amount = len(Globals.potential_common_upgrades) + len(Globals.potential_rare_upgrades)
	while i < upgrades_amount:
		var upgrade: Dictionary
		if (randf() < 0.1 and len(Globals.potential_rare_upgrades) > 0) or len(Globals.potential_common_upgrades) < 1:
			upgrade = Globals.potential_rare_upgrades[randi_range(0, len(Globals.potential_rare_upgrades) - 1)]
		else:
			upgrade = Globals.potential_common_upgrades[randi_range(0, len(Globals.potential_common_upgrades) - 1)]
		if upgrade in upgrades_this_time: 
			continue
		upgrades_this_time.append(upgrade)
		i += 1
		var upgrade_card = upgrade_card_prefab.instantiate()
		upgrade_card.name = upgrade["name"]
		upgrade_card.upgrade_name = upgrade["name"]
		upgrade_card.upgrade_description = upgrade["description"]
		upgrade_card.upgrade_number = i
		upgrade_card.upgrade = upgrade
		upgrade_card_carousel.add_child(upgrade_card)
		upgrade_cards.append(upgrade_card)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		current_card = upgrade_card_carousel.get_child(upgrades_amount / 2)
		
		if Input.is_action_just_pressed("movement_left"):
			for child in upgrade_card_carousel.get_children():
				if child.get_index() == upgrades_amount - 1:
					upgrade_card_carousel.move_child(child, 0)
					break
		if Input.is_action_just_pressed("movement_right"):
			for child in upgrade_card_carousel.get_children():
				if child.get_index() == 0:
					upgrade_card_carousel.move_child(child, - 1)
					break
		if Input.is_action_just_pressed("ui_accept"):
			Globals.upgrades.append(current_card.upgrade)
			if current_card.upgrade.rarity == "Common":
				Globals.potential_common_upgrades.erase(current_card.upgrade)
			elif current_card.upgrade.rarity == "Rare":
				Globals.potential_rare_upgrades.erase(current_card.upgrade)
			Globals.next_wave()
		for child in upgrade_card_carousel.get_children():
			if child == current_card:
				child.modulate.a = 1
			else:
				child.modulate.a = non_selected_transparency
		

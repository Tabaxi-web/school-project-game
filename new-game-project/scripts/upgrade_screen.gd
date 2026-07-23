extends Node2D

@export var upgrades_amount := 3
@export var upgrade_card_prefab: PackedScene
@export var upgrade_holder_prefab: PackedScene
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
	# If there are no upgrades left, give up!
	if len(Globals.potential_common_upgrades) + len(Globals.potential_rare_upgrades) <= 0:
		push_error("No upgrades left!!")
		get_tree().call_deferred("quit")
	# If there are less than upgrades_amount upgrades, generatate less
	if len(Globals.potential_common_upgrades) + len(Globals.potential_rare_upgrades) < upgrades_amount:
		upgrades_amount = len(Globals.potential_common_upgrades) + len(Globals.potential_rare_upgrades)
	# While loop so it doesn't have to increment by 1, it only increments if an upgrade is selected
	while i < upgrades_amount:
		var upgrade: Dictionary
		if (randf() < rare_rarity and len(Globals.potential_rare_upgrades) > 0) or len(Globals.potential_common_upgrades) < 1:
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
		if upgrade["icon_path"]  != null:
			upgrade_card.texture_rect.texture = load(upgrade["icon_path"])
		add_child(upgrade_card)
		var holder = upgrade_holder_prefab.instantiate()
		upgrade_card_carousel.add_child(holder)
		holder.add_to_group("Upgrade_Card_Holders")
		upgrade_card.holder_index = i - 1
		
		upgrade_cards.append(upgrade_card)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		for card in upgrade_cards:
			if card.holder_index == round(upgrades_amount / 2):
				current_card = card
		if Input.is_action_just_pressed("movement_right"):
			for child in upgrade_cards:
				if child.holder_index == 0:
					child.holder_index = len(upgrade_cards) - 1
				else:
					child.holder_index -= 1
		if Input.is_action_just_pressed("movement_left"):
			for child in upgrade_cards:
				if child.holder_index == len(upgrade_cards) - 1:
					child.holder_index = 0
				else:
					child.holder_index += 1
		if Input.is_action_just_pressed("ui_accept"):
			
			if current_card.upgrade.rarity == "Common":
				Globals.potential_common_upgrades.erase(current_card.upgrade)
				Globals.upgrades.append(current_card.upgrade)
			elif current_card.upgrade.rarity == "Rare":
				Globals.potential_rare_upgrades.erase(current_card.upgrade)
				Globals.rare_upgrades.append(current_card.upgrade)
			# Handle incompatible upgrades.
			if "incompatible_upgrades" in current_card.upgrade:
				for incomp_upgrade_name in current_card.upgrade["incompatible_upgrades"]:
					for common_upgrade in Globals.potential_common_upgrades:
						if common_upgrade["name"] == incomp_upgrade_name:
							Globals.potential_common_upgrades.erase(common_upgrade)
					for rare_upgrade in Globals.potential_rare_upgrades:
						if rare_upgrade["name"] == incomp_upgrade_name:
							Globals.potential_rare_upgrades.erase(rare_upgrade)
			Globals.next_wave()
		for child in upgrade_cards:
			if child == current_card:
				child.modulate.a = 1
			else:
				child.modulate.a = non_selected_transparency
		

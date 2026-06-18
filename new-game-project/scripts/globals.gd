extends Node

var wave := 1
var upgrades := []
var potential_common_upgrades_init_value := [
	{"name": "Buckshot I", "rarity": "Common", "chance": 1,
	"description": "Increase spread, increase pellets per shot, increase reload time."},
	{"name": "Gunner I", "rarity": "Common", "chance": 1,
	"description": "Increase fire-rate and magazine size."},
	{"name": "Hollow Point I", "rarity": "Common", "chance": 1,
	"description": "Increase damage per bullet."}
]
var potential_common_upgrades := []
var potential_rare_upgrades_init_value := [
	{"name": "Starburst", "rarity": "Rare",
	"description": "Spread becomes 360 degrees. Increase pellets per shot. Reduce damage."}
]
var potential_rare_upgrades := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_all_globals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_all_globals() -> void:
	wave = 1
	upgrades = []
	potential_common_upgrades = potential_common_upgrades_init_value
	potential_rare_upgrades = potential_rare_upgrades_init_value

func next_wave() -> void:
	wave += 1
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func intermission() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrade_screen.tscn")

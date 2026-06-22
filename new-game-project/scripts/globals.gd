extends Node

var wave := 1
var upgrades := []
var potential_common_upgrades_init_value := [
	{"name": "Buckshot I", "rarity": "Common",
	"description": "Increase spread, increase pellets per shot, increase reload time."},
	{"name": "Gunner I", "rarity": "Common",
	"description": "Increase fire-rate."},
	{"name": "Hollow Point I", "rarity": "Common",
	"description": "Increase damage per bullet."},
	{"name": "Commando I", "rarity": "Common",
	"description": "Increase mag size and decrease reload time."},
	{"name": "Sharpshooter I", "rarity": "Common",
	"description": "Increase bullet velocity. Bullets have a chance to crit for 1.5x damage."},
	{"name": "Sharpshooter II", "rarity": "Common",
	"description": "Increase crit damage by 50%."},
	{"name": "Focus I", "rarity": "Common",
	"description": "Decrease spread and bullet velocity."}
]
var potential_common_upgrades := []
var potential_rare_upgrades_init_value := [
	{"name": "Starburst", "rarity": "Rare",
	"description": "Spread becomes 360 degrees. Increase pellets per shot. Reduce damage."},
	{"name": "Laserbeam", "rarity": "Rare",
	"description": "Vastly increaes firerate but drastically reduces damage. Only one bullet per shot."},
	{"name": "Minesweeper", "rarity": "Rare",
	"description": "Bullet velocity becomes zero. Increase damage. Only one bullet per shot."}
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
	if len(potential_common_upgrades) + len(potential_rare_upgrades) < 1:
		next_wave()
	else:
		get_tree().change_scene_to_file("res://scenes/upgrade_screen.tscn")

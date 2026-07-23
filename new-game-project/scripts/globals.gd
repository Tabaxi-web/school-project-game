extends Node

var wave := 1
var upgrades := []
var rare_upgrades := []
var upgrade_screen_how_often := 3
enum upgrade_ids {BUCKSHOT1, GUNNER1, HOLLOWPT1, COMMANDO1, SHARPSHT1, SHARPSHT2, FOCUS1, COMMANDO2,
STRBURST, LSRBEAM, SWEEPER}
enum player_attributes {SPREAD, PELLETS, FALLOFF, RELOAD_TIME, FIRE_DELAY, DAMAGE,
MAX_AMMO, CRIT_CHANCE, CRIT_DAMAGE, HOMING, DASH_RELOAD}
var potential_common_upgrades_init_value := [
	
	{"id": upgrade_ids.BUCKSHOT1, "name": "Buckshot I", "rarity": "Common",
	"description": "Increase spread, increase pellets per shot, increase reload time, increase damage falloff, decrease damage.",
	"icon_path": "res://assets/icons/Buckshot_Icon.png",
	"spread": "+PI/8", "pellets_per_shot": "+5", "damage_falloff": "+0.05", "reload_time": "+1"},
	
	{"id": upgrade_ids.GUNNER1, "name": "Gunner I", "rarity": "Common",
	"description": "Increase fire-rate.",
	"icon_path": "res://assets/icons/Gunner_Icon.png",
	"fire_rate": ""},
	
	{"id": upgrade_ids.HOLLOWPT1, "name": "Hollow Point I", "rarity": "Common",
	"description": "Increase damage per bullet.",
	"icon_path": "res://assets/icons/Hollowpoint_Icon.png"},
	
	{"id": upgrade_ids.COMMANDO1, "name": "Commando I", "rarity": "Common",
	"description": "Increase mag size and decrease reload time.",
	"icon_path": "res://assets/icons/Commando_Icon.png"},
	
	{"id": upgrade_ids.SHARPSHT1, "name": "Sharpshooter I", "rarity": "Common",
	"description": "Increase bullet velocity. Bullets have a chance to crit for 1.5x damage.",
	"icon_path": "res://assets/icons/Sharpshooter_Icon.png"},
	
	{"id": upgrade_ids.SHARPSHT2, "name": "Sharpshooter II", "rarity": "Common",
	"description": "Increase crit damage by 50%.",
	"icon_path": "res://assets/icons/Sharpshooter_Icon.png"},
	
	{"id": upgrade_ids.FOCUS1, "name": "Focus I", "rarity": "Common",
	"description": "Decrease spread and bullet velocity. Decrease bullet damage falloff.",
	"icon_path": "res://assets/icons/Focus_Icon.png",
	"incompatible_upgrades": ["Starburst", "Laserbeam", "Minesweeper"]},
	
	{"id": upgrade_ids.COMMANDO2, "name": "Commando II", "rarity": "Common", "description": "Dashing reloads half your magazine.",
	"icon_path": "res://assets/icons/Commando_Icon.png"},
	#{"name": "Medic I", "rarity": "Common", "description": "Enemies have a chance to drop healing orbs."}
]
var potential_common_upgrades := []
var potential_rare_upgrades_init_value := [
	{"id": upgrade_ids.STRBURST, "name": "Starburst", "rarity": "Rare",
	"description": "Spread becomes 360 degrees. Increase pellets per shot. Reduce damage. Bullets now home.",
	"icon_path": "res://assets/icons/Starburst_Icon.png",
	"incompatible_upgrades": ["Focus I", "Laserbeam", "Minesweeper"]},
	{"id": upgrade_ids.LSRBEAM, "name": "Laserbeam", "rarity": "Rare",
	"description": "Vastly increaes firerate but drastically reduces damage. Only one bullet per shot.",
	"icon_path": "res://assets/icons/Laserbeam_Icon.png",
	"incompatible_upgrades": ["Focus I", "Starburst", "Minesweeper"]},
	{"id": upgrade_ids.SWEEPER, "name": "Minesweeper", "rarity": "Rare",
	"description": "Bullet velocity becomes zero. Increase damage. Only one bullet per shot.",
	"icon_path": "res://assets/icons/Minesweeper_Icon.png",
	"incompatible_upgrades": ["Focus I", "Laserbeam", "Starburst"]}
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
	
	get_tree().change_scene_to_file("res://scenes/scene_transition.tscn")

func intermission() -> void:
	if len(potential_common_upgrades) + len(potential_rare_upgrades) < 1:
		next_wave()
	else:
		get_tree().change_scene_to_file("res://scenes/upgrade_screen.tscn")

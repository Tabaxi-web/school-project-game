extends Node
# This is an autoload singleton that persists between scenes.
var master_volume := 0.8
var music_volume := 0.8
var master_bus_name := "Master"
var music_bus_name := "Music"
var wave := 1 # Wave number.
var winning_wave := 14
var upgrades := [] # An array of dictionaries that define upgrades the player has.
var rare_upgrades := [] # ditto, but the rares.
var upgrade_screen_how_often := 3 # Every n waves the player will get an upgrade.

enum upgrade_ids {BUCKSHOT1, GUNNER1, HOLLOWPT1, COMMANDO1, SHARPSHT1, SHARPSHT2, FOCUS1, COMMANDO2,
STRBURST, LSRBEAM, SWEEPER, MEDIC1, GUNNER2, BURST1, BURST2, SLAMMER} # ENUM ids for each upgrade.
enum player_attributes {SPREAD, PELLETS, FALLOFF, RELOAD_TIME, FIRE_DELAY, DAMAGE,
MAX_AMMO, CRIT_CHANCE, CRIT_DAMAGE, HOMING, DASH_RELOAD, MAX_HP, LIFESTEAL, 
HEALING_ORBS, HEALING_ORBS_AMOUNT, HEALING_ORBS_CHANCE, BURST_AMOUNT, BURST_DELAY} # ENUM IDS for all attributes that can be upgraded

var healing_orbs := true
var healing_orbs_amount := 20.0
var healing_orbs_chance := 0.05

signal start_wave
signal upgrade_screen

var potential_common_upgrades_init_value := [ # The pool of common upgrades that the player starts with
	
	{"id": upgrade_ids.BUCKSHOT1, "name": "Buckshot I", "rarity": "Common",
	"description": "Increase spread, increase pellets per shot, increase reload time, increase damage falloff, decrease damage.",
	"icon_path": "res://assets/icons/Buckshot_Icon.png"},
	
	{"id": upgrade_ids.GUNNER1, "name": "Gunner I", "rarity": "Common",
	"description": "Increase fire-rate.",
	"icon_path": "res://assets/icons/Gunner_Icon.png"},
	
	{"id": upgrade_ids.GUNNER2, "name": "Gunner II", "rarity": "Common",
	"description": "Increase fire-rate and spread.",
	"icon_path": "res://assets/icons/Gunner_Icon.png"},
	
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
	
	{"id": upgrade_ids.MEDIC1,"name": "Medic I", "rarity": "Common", "description": "Increased Max HP. Enemies have a chance to drop healing orbs.",
	"icon_path": "res://assets/icons/Medic_Icon.png"},
	
	{"id": upgrade_ids.BURST1, "name": "Burst I", "rarity": "Common",
	"description": "Increases burst volley by 2. Decreases fire rate.",
	"icon_path": "res://assets/icons/Burst_Icon.png"},
	
	{"id": upgrade_ids.BURST2, "name": "Burst II", "rarity": "Common",
	"description": "Increases burst volley by 1. Increase damage slightly.",
	"icon_path": "res://assets/icons/Burst_Icon.png"},
	
]
var potential_common_upgrades := [] # Initialised to the above variable on game start, taken from so the player can't get two upgrades twice.


var potential_rare_upgrades_init_value := [ # Ditto but rare
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
	"incompatible_upgrades": ["Focus I", "Laserbeam", "Starburst"]},
	{"id": upgrade_ids.SLAMMER, "name": "Slamfire", "rarity": "Rare",
	"description": "Light 'em up!",
	"icon_path": "res://assets/icons/Minesweeper_Icon.png",
	"incompatible_upgrades": ["Focus I", "Laserbeam", "Starburst"]},
	
]
var potential_rare_upgrades := [] # Ditto again.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_all_globals() # Inits all variables
	


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var master_bus_index = AudioServer.get_bus_index(master_bus_name)
	AudioServer.set_bus_volume_linear(master_bus_index, master_volume)
	var music_bus_index = AudioServer.get_bus_index(master_bus_name)
	AudioServer.set_bus_volume_linear(music_bus_index, music_volume)

func reset_all_globals() -> void: # Used to reset game state on death.
	wave = 1
	upgrades = []
	potential_common_upgrades = potential_common_upgrades_init_value
	potential_rare_upgrades = potential_rare_upgrades_init_value

func next_wave() -> void: # What it says on the tin.
	if wave == winning_wave:
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
	wave += 1
	if wave % upgrade_screen_how_often == 0:
		intermission()
	else:
		start_wave.emit()

func intermission() -> void: # Triggered upon entering the shop

	if len(potential_common_upgrades) + len(potential_rare_upgrades) < 1:
		next_wave() # Just skip it if there are no upgrades left.
	else:
		upgrade_screen.emit()

func play_sound(sound: AudioStream) -> void: # Generic sound player. Instantiates an audio stream then destroys it once its done.
	var player = AudioStreamPlayer.new()
	add_sibling(player) # Note it's instantiated as a sibling, so it will persist between scenes.
	player.stream = sound
	player.play()
	await player.finished
	player.queue_free()

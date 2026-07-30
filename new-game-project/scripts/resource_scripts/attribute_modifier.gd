class_name Modifier extends Resource
# This is the thing that actually modifies the player's stats.
# These are checked and applied in the order they are listed.
@export var modified_attribute: Globals.player_attributes ## Refers back to attributes defined in the globals enum
@export var modifier_bonus := 0.0 ## Add this to the stat's value
@export var modifier_multiplier := 1.0 ## Multiply the stat's value by this
@export var modifier_override := false ## Whether to set the player's stat value to the follow value outright.
@export var modifier_override_value := 0.0 ## See above. Does nothing unless above is turned on.
@export var modifier_bool := false ## For bool modifiers, this is the bool it checks.

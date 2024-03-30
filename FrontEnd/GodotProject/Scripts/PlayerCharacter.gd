class_name PlayerCharacter extends Character

var phi = (1 + sqrt(5)) / 2
var negative_phi = (1 - sqrt(5)) / 2
var current_xp = 0
var xp_to_next_level

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func award_xp(xp_amount):
	current_xp += xp_amount
	if current_xp >= xp_to_next_level:
		_level_up()

func set_stats(stats):
	super(stats)
	xp_to_next_level = _calculate_xp_to_next_level()

func _calculate_xp_to_next_level():
	return ceil((pow(phi, character_stats.level) \
	- pow(negative_phi, character_stats.level)) / sqrt(5))

func _level_up():
	# Alert via twitch DM your character has unallocated stat points
	# for now, were not doing that :), just level up power
	character_stats.power += 1
	
	# Full heal character
	full_heal()
	
	# Consume xp needed to level
	current_xp -= xp_to_next_level
	
	# Calcualte new level xp threshold
	xp_to_next_level = _calculate_xp_to_next_level()

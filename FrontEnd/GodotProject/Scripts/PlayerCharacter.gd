class_name PlayerCharacter extends Character

# Properties
var player_hp_scale = 5
var discord_id
@onready var death_timer = $DeathTimer

# Stat variable
var is_dead

signal on_level_up
signal on_respawn

func get_xp_breakpoint(level):
	return floor(pow(level, 3)/10) + 10*level

# Called when the nde enters the scene tree for the first time.
func _ready():
	super()
	death_timer.timeout.connect(_respawn_character)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _die():
	is_dead = true
	super()

func award_xp(xp_amount):
	character_stats.current_xp += xp_amount
	if character_stats.current_xp >= character_stats.xp_to_next_level:
		_level_up()

func set_stats(stats):
	super(stats)
	character_stats.xp_to_next_level = _calculate_xp_to_next_level()

func set_discord_id(_discord_id):
	discord_id = _discord_id

func _calculate_xp_to_next_level():
	var next_xp_amount = get_xp_breakpoint(character_stats.level) - get_xp_breakpoint(character_stats.level - 1)
	return next_xp_amount

func spend_stat_points(skill, point_amount):
	# Externalize command input sanitation
	# TODO More specific error cases
	if not skill or not point_amount or point_amount <= 0:
		return "Did not provide correct arguments"
	var status_message = ""
	if character_stats.stat_points >= point_amount:
		character_stats.stat_points -= point_amount
		status_message = "{skill} increased by " + str(point_amount) +\
		 " it is now {stat_total}"
		match skill: 
			"Power": 
				character_stats.power += point_amount
				status_message = status_message.format({
					"skill": "Power", 
					"stat_total": character_stats.power
				})
			"Wisdom":
				character_stats.wisdom += point_amount
				status_message = status_message.format({
					"skill": "Wisdom", 
					"stat_total": character_stats.wisdom
				})
			"Dexterity":
				character_stats.dexterity += point_amount
				status_message = status_message.format({
					"skill": "Dexterity", 
					"stat_total": character_stats.dexterity
				})
			"Defense":
				character_stats.defense += point_amount
				status_message = status_message.format({
					"skill": "Defense", 
					"stat_total": character_stats.defense
				})
			_:
				character_stats.stat_points += point_amount
				status_message = str("Skill ", skill, " not found.")
	else:
		status_message = "Not enough available skill points"
	return status_message

func _level_up():
	# Add a level to the character
	character_stats.level += 1
	
	# Add a skill point to the character
	character_stats.stat_points += 1
	
	# Recalculate HP
	character_stats.max_hp = (character_stats.level - 1) * character_stats.hp_per_level_scaler + character_stats.base_hp

	# Full heal character
	full_heal()
	
	# Consume xp needed to level
	character_stats.current_xp -= character_stats.xp_to_next_level
	
	# Calcualte new level xp threshold
	character_stats.xp_to_next_level = _calculate_xp_to_next_level()
	
	on_level_up.emit(self)

func _respawn_character():
	full_heal()
	on_respawn.emit(self)

func save():
	var save_data = {
		"id": discord_id,
		"username": character_name,
		"level": character_stats.level,
		"power": character_stats.power,
		"wisdom": character_stats.wisdom,
		"dexterity": character_stats.dexterity,
		"defense": character_stats.defense,
		"max_attack_delay_time": character_stats.max_attack_delay_time,
		"base_hp": character_stats.base_hp,
		"hp_per_level_scaler": character_stats.hp_per_level_scaler,
		"stat_points": character_stats.stat_points,
		"current_xp": character_stats.current_xp,
		"xp_to_next_level": character_stats.xp_to_next_level,
		"max_hp": character_stats.max_hp,
	}
	return save_data

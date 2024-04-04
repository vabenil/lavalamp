class_name PlayerCharacterManager extends CharacterManager

var intro_message = """{username} has joined the game
Your character is level 1, you can use /join to join an active room [broken]
You can see a list of active rooms by using /room_list [broken]
"""

var player_already_in_game_message = """{username} you are already in the game!"""

var player_leveled_up = """You have leveled up
You are now level {level}
You have {stat_points} unallocated stat points
use /spend_stat_point <stat> <value=1> to add points to a skill
========================================================
"""

# TODO Make this message spawn a timer instead of strict 2 minutes
var player_died_message = """{username} you have died! 
You will respawn in 2 minutes"""

var player_respawned_message = """{username} you have respawned!
Use /join to join a room"""

var waiting_to_respawn_message = """{username} your character is dead
You must wait {timer} seconds to rejoin"""

var player_already_exists_in_save = """{username} your character has previosuly joined the game
but is not currently active. Use /join <room> to add them to the current session"""

func parse_string_message(message, arguments):
	return message.format(arguments)

# Scene refs
@onready var player_character_scene = load("res://Scenes/player_character.tscn")

# Resource refs
@onready var new_character_stats = load(
	"res://Resources/Saved/NewPlayerCharacterStats.tres")

# Child refs
@onready var timer = $CheckForNewPlayersTimer
@onready var autosave_timer = $AutosaveTimer

# Properteis
var file_path = "res://Integration/joined_characters.csv"

# State vars
var new_character_input_index = 0
var new_character_input_file
var active_characters = {}
var dead_characters = []
var save_data

# Called when the node enters the scene tree for the first time.
func _ready():
	save_data = load_data()
	autosave_timer.timeout.connect(_autosave)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _create_character(discord_username, discord_id, stats=new_character_stats) -> Character:
	# Spawn in a new player
	var new_player = player_character_scene.instantiate()
	
	# Set the player to not be visible before joining a room
	new_player.visible = false
	
	# Add child
	add_child(new_player)

	# Set the player name
	new_player.set_character_name(discord_username)
	
	# Sets the discord id
	new_player.set_discord_id(discord_id)
	
	# Set the characters base stats
	new_player.set_stats(stats)
	
	# Attack to player signals 
	_attack_to_character_signals(new_player)
	
	# Return the created character
	return new_player

#func _check_for_new_players():
	#pass

func add_new_player(discord_id, username):
	if active_characters.has(discord_id):
		send_message_to_discord({
			"username": username,
			"message": parse_string_message(player_already_in_game_message,
			{"username": username
			})
		})
		return
	if save_data.has(discord_id):
		send_message_to_discord({
			"username": username,
			"message": parse_string_message(player_already_exists_in_save,
			{"username": username
			})
		})
		return

	var new_character = _create_character(username, discord_id)
	active_characters[discord_id] = new_character
	send_message_to_discord({
		"username": username,
		"message": parse_string_message(intro_message, 
		{"username": 
			username}
		)
	})


func add_player_to_room(discord_id, username, room):
	if save_data.has(discord_id) && not active_characters.has(discord_id):
		_reactive_chatacter(discord_id)
	
	if active_characters.has(discord_id):
		var character = active_characters[discord_id]
		if character.death_timer.is_stopped():
			var status_message = _join_room(character, room)
			send_message_to_discord({
				"username": username,
				"message": parse_string_message(status_message, 
				{
					"username": username,
					"room": room
				})
			})
		else:
			send_message_to_discord({
				"username": username,
				"message": parse_string_message(waiting_to_respawn_message, 
				{
					"username": username,
					"timer": format_time(character.death_timer.time_left)
				})
			})

func send_message_to_discord(message):
	$DiscordIntegrationConnectionTest.web_socket_server.send(0, str(message))

func _character_leveled_up(character):
	var discord_message = {
		"discord_id": character.discord_id,
		"message": parse_string_message(player_leveled_up, {
			"level": character.character_stats.level,
			"stat_points": character.character_stats.stat_points
		})
	}
	send_message_to_discord(discord_message)

func spend_stat_points(discord_id, username, stat_name, stat_amount):
	if active_characters.has(discord_id):
		var character = active_characters[discord_id]
		var status_message = character.spend_stat_points(stat_name, stat_amount)
		send_message_to_discord({"username": username, "message":status_message})
	else:
		# TODO Player not in game message
		pass

func _character_died(character):
	_remove_from_active_room(character)
	_start_death_timer(character)
	_send_character_died_message(character)

func _attack_to_character_signals(new_character):
	new_character.on_level_up.connect(_character_leveled_up)
	new_character.on_death.connect(_character_died)
	new_character.on_respawn.connect(_character_respawned)

func _remove_from_active_room(character):
	character.visible = false
	character.leave_room()

func _send_character_died_message(character: PlayerCharacter):
	send_message_to_discord({	
		"discord_id": character.discord_id,
		"message": parse_string_message(player_died_message, {
			"username": character.character_name
		})
	})

func _start_death_timer(character):
	character.death_timer.start()

func _character_respawned(character):
	send_message_to_discord({	
		"discord_id": character.discord_id,
		"message": parse_string_message(player_respawned_message, {
			"username": character.character_name
		})
	})

func format_time(time):
	return "%02d" % time

func _autosave():
	save_data = load_data()
	for discord_id in active_characters:
		save_data[discord_id] = active_characters[discord_id].save()
	
	var json_string = JSON.stringify(save_data)
	
	var save_game_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	save_game_file.store_line(json_string)

func load_data():
	var save_game_data = FileAccess.open("user://savegame.save", FileAccess.READ)
	if save_game_data == null:
		return {}
	else:
		save_game_data = JSON.parse_string(save_game_data.get_line())
		return save_game_data

func _reactive_chatacter(discord_id):
	var loaded_stats = save_data[discord_id]
	var character_resource = CharacterStats.new()
	character_resource.update_character_stats(loaded_stats)
	character_resource.current_hp = character_resource.max_hp
	
	var new_character = _create_character(loaded_stats.username, discord_id, character_resource)	
	active_characters[discord_id] = new_character

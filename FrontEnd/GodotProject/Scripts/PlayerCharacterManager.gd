class_name PlayerCharacterManager extends CharacterManager

# Scene refs
@onready var player_character_scene = load("res://Scenes/player_character.tscn")

# Resource refs
@onready var new_character_stats = load(
	"res://Resources/Saved/NewPlayerCharacterStats.tres")

# Child refs
@onready var timer = $CheckForNewPlayersTimer

# Properteis
var file_path = "res://Integration/joined_characters.csv"

# State vars
var new_character_input_index = 0
var new_character_input_file
var active_characters = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#timer.timeout.connect(_check_for_new_players)
	
	# Create perred, the first of many
	#var perred := _create_character("perred")
	#_join_room(perred, "Forest")
	#
	## Create ateRstones, the wizard of dyslexia
	#var ateRstones := _create_character("ateRstones")
	#_join_room(ateRstones, "Forest")
	#
	## Create RobearRobachan, the wizard of dyslexia
	#var RobearRobachan := _create_character("RobearRobachan")
	#_join_room(RobearRobachan, "Forest")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TODO Use usernames as login, but display display names
	pass

func _create_character(twitch_username) -> Character:
	# Spawn in a new player
	var new_player = player_character_scene.instantiate()
	
	# Set the player to not be visible before joining a room
	new_player.visible = false
	
	# Add child
	add_child(new_player)

	# Set the player name
	new_player.set_character_name(twitch_username)
	
	# Set the characters base stats
	new_player.set_stats(new_character_stats)
	
	# Return the created character
	return new_player

#func _check_for_new_players():
	#pass

func add_new_player(username):
	if not active_characters.has(username):
		active_characters[username] = ""
		var new_character = _create_character(username)
		_join_room(new_character, "Forest")
		send_message_to_discord(str(username, " has joined the game"))
	else:
		send_message_to_discord(str(username, " you are already in the game :)"))

func send_message_to_discord(message):
	$DiscordIntegrationConnectionTest.web_socket_server.send(0, message)

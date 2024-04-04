## A room for characters to join and fight monsters
class_name Room extends Node2D


# Children References
@onready var character_position_marker = $CharactersMarker
@onready var enemy_spawn_marker = $EnemySpawnMarker
@onready var enemy_character_manager = $EnemyCharacterManager

# Room properties
@export var enemy_groups: Array[EnemyGroup]
var player_joined_room_message = """{username} you have joined the {room}"""
var player_already_joined_room = """{username} you are already in the {room}"""
var player_left_room_message = """{username} has left the {room}"""
var player_not_found_in_room_message = """{username} is not present in the {room}"""
var is_first_spawn = true

# State vairables
var player_characters_in_room = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Init Enemy Manager for the room
	_initialize_enemy_manager()
	_connect_to_enemy_manager_signals()
	
	# TODO move this into the process loop
	enemy_character_manager.spawn_new_group(is_first_spawn)
	is_first_spawn = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Progress all players in the room forward on their attack timers
	_process_characters(delta)
	
	# Progress the enemy character forward on attack timers
	if not player_characters_in_room.is_empty():
		_process_enemy_characters(delta)

## Adds a character to the room
func add_character(character):
	if player_characters_in_room.has(character.discord_id):
		return player_already_joined_room
	
	# Move character into room control position
	character.global_position = _get_room_character_position()
	
	# Make character visible if room is visible
	character.visible = visible
	
	# Add the character to the list of characters in the room
	player_characters_in_room[character.discord_id] = character
	
	# Increment room count
	enemy_character_manager.update_player_count(player_characters_in_room.size())
	
	# Attack to the signals of the character
	_connect_to_player_attack_signals(character)
	
	return player_joined_room_message

## Determines the base position of the 
func _get_room_character_position() -> Vector2:
	var room_position = global_position
	var base_character_position = room_position +\
	 character_position_marker.global_position
	var random_x_position = base_character_position.x + randi_range(-40, 40)
	var random_y_position = base_character_position.y + 80 * randf()
	return Vector2(random_x_position, random_y_position)

## Initilizes the Enemy Manager
func _initialize_enemy_manager():
	# Set the groups of enemies that can spawn
	enemy_character_manager.set_enemy_groups(enemy_groups)
	
	# Set the marker for the enemy spawn location
	enemy_character_manager.enemy_spawn_marker = enemy_spawn_marker

## Progress characters forward on their attack timers
func _process_characters(delta):
	for player_character in player_characters_in_room.keys():
		player_characters_in_room[player_character].progress_attack_timers(delta)

## Connects to the signal of attacking from the character
func _connect_to_player_attack_signals(character):
	character.attack.connect(_on_player_character_attack)

## Called when a player character makes an attack
# Attack the boss with the character
func _on_player_character_attack(character):
	enemy_character_manager.enemy_characters.pick_random().get_attacked(character)

## Progress enemy characters forward on their attack timers
func _process_enemy_characters(delta):
	for enemy_character in enemy_character_manager.enemy_characters:
		enemy_character.progress_attack_timers(delta)

## 
func _on_enemy_character_attack(enemy_character):
	# Single target attack
	player_characters_in_room[player_characters_in_room.keys().pick_random()].get_attacked(enemy_character)

## 
func _connect_to_enemy_manager_signals():
	enemy_character_manager.character_attacked.connect(_on_enemy_character_attack)

## Awards xp to all characters in the room
func award_xp(enemy_level, is_boss):
	var total_xp
	if not is_boss:
		total_xp = enemy_level
	else:
		total_xp = enemy_level * 5
	for player_character in player_characters_in_room:
		player_characters_in_room[player_character].award_xp(total_xp)

## Awards drops to all characters in the room based on the drop table
func award_drops(drop_tables):
	pass

func leave(player_character: PlayerCharacter):
	if player_characters_in_room.erase(player_character.discord_id):
		_check_if_room_is_empty()
		return player_left_room_message
	else:
		return player_not_found_in_room_message

func _check_if_room_is_empty():
	if player_characters_in_room.size() == 0:
		_reset_room()

func _reset_room():
	_despawn_enemies()
	enemy_character_manager.spawn_new_group(true)

func _despawn_enemies():
	enemy_character_manager.despawn_enemies()

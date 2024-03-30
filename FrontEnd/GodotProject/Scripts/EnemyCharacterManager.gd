class_name EnemyCharacterManager extends CharacterManager

var enemy_groups: Array[EnemyGroup]

# References
var enemy_spawn_marker
@onready var room_manager = get_parent()

# Scene refs
# TODO preload when converting room to room scene
@onready var enemy_scene = load("res://Scenes/enemy_character.tscn")

## Properties
@export var spawn_area_height = 250 - 160 # From enemy spawn marker down

# Minimum amout of enemies to stagger the x positions
@export var stagger_horizontal_spawn_enemy_threshold = 3
@export var stagger_amount = 25 # px

# State varibales
var enemy_characters: Array[EnemyCharacter]

# Signals
signal character_attacked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Spawns a group of enemies
func spawn_new_group():
	var enemy_group = _determine_enemy_group_spawn()
	var total_enemies = 0
	for enemy_count in enemy_group.enemy_counts:
		total_enemies += enemy_count
	for index in enemy_group.enemy_types.size():
		for _index in range(enemy_group.enemy_counts[index]):
			_spawn_new_enemy(enemy_group.enemy_types[index], total_enemies)
	
## Spwans a new enemy from the list of possible enemies for a given room
func _spawn_new_enemy(enemy_resource, total_enemies):
	# Create new enemy
	var new_enemy = enemy_scene.instantiate()
	
	# Set sprite bounding box
	new_enemy.set_sprite_bounding_box(enemy_resource.sprite_bounding_box)
	
	# Add to enemies
	add_child(new_enemy)
	
	# Set stats resource
	new_enemy.set_stats(enemy_resource.stats)
	
	# Set if new enemy is a boss type
	new_enemy.is_boss = enemy_resource.is_boss
	
	# Set enemy sprite
	new_enemy.set_sprite_frames(enemy_resource.sprite_frames)
	
	# Set the name
	new_enemy.set_character_name(enemy_resource.name)
	
	# Add character to enemy character list
	enemy_characters.append(new_enemy)
	
	# Set the position of the enemy to be the position of the room
	_set_enemy_position(new_enemy, total_enemies)
	
	_connect_to_signals(new_enemy)
	
	return new_enemy

## Randomly selects an enemy to spwan from the list of possible enemies
func _determine_enemy_group_spawn() -> EnemyGroup:
	return enemy_groups.pick_random()

## Sets the rooms enemy list to spawn from
func set_enemy_groups(_enemy_groups):
	enemy_groups = _enemy_groups

func _connect_to_signals(new_enemy):
	new_enemy.attack.connect(_on_enemy_attacked)
	new_enemy.death.connect(_on_enemy_died)

func _on_enemy_attacked(enemy):
	character_attacked.emit(enemy)

## Sets the position of the spawned enemy. Uses the total amount of enemies to
## determine the position
func _set_enemy_position(enemy, total_enemies):
	var spawned_enemies = enemy_characters.size()
	# TODO calculate only once per enemy group spawn
	var per_enemy_offset = spawn_area_height / (total_enemies + 2)
	var spawn_offset = per_enemy_offset * spawned_enemies
	# TODO Wiggle x position based on total spawns 
	# Need to determine the back and fourth movement for different groups
	var x_position = enemy_spawn_marker.position.x
	var y_position = enemy_spawn_marker.position.y + spawn_offset
	if total_enemies >= stagger_horizontal_spawn_enemy_threshold:
		if spawned_enemies % 2 == 0:
			x_position -= stagger_amount
		else:
			x_position += stagger_amount
	enemy.position = Vector2(x_position, y_position)

## Called when enemy dies
func _on_enemy_died(enemy: EnemyCharacter):
	
	# Remove from list of enemies
	for index in range(enemy_characters.size()):
		if enemy_characters[index].name == enemy.name:
			enemy_characters.remove_at(index)
			break
	
	# Check if all enemies are dead
	if _check_if_all_enemies_cleared():
		spawn_new_group()
	
	# Award XP to all alive players
	room_manager.award_xp(enemy.character_stats.level, enemy.is_boss)
	
	# Award drops to all alive players
	# room_manager.award_drops(enemy.drop_table)
	
	# Delete the node
	enemy.queue_free()

## Checks if all enemies in the room are cleared
func _check_if_all_enemies_cleared():
	return enemy_characters.size() == 0

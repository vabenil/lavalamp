## Base character class inhereted by all characters in the game
class_name Character extends Node2D

# Children references
@onready var name_text = $Name
@onready var sprite = $Sprite
@onready var hp_bar = $HPBar

# Properties
@export var font_size = 16
var character_stats: CharacterStats
var bounding_box: Rect2i

# State variables
var attack_timer_buildup = 0

# Signals
signal attack
signal death

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Sets the stats of the character
func set_stats(stats: CharacterStats):
	character_stats = stats.duplicate() as CharacterStats
	character_stats.max_hp = character_stats.base_hp +\
	 character_stats.hp_per_level_scaler * character_stats.level
	character_stats.current_hp = character_stats.max_hp

## Sets the character display name
func set_character_name(character_name):
	name_text.text = str("[center][font_size=", font_size, "]", 
	character_name.left(11))

## Sets the sprite offset
func set_sprite_bounding_box(sprite_bounding_box: Rect2i):
	bounding_box = sprite_bounding_box

## Sets the sprite frames for the character
func set_sprite_frames(sprite_frames: SpriteFrames):
	sprite.sprite_frames = sprite_frames
	sprite.play()

## Progress foward all attack timers
func progress_attack_timers(delta):
	_check_attack_trigger(delta)
	

## Checks if the attack timer has exceed the max, and if so, attacks
func _check_attack_trigger(delta):
	attack_timer_buildup += delta
	if attack_timer_buildup >= character_stats.max_attack_delay_time:
		attack_timer_buildup -= character_stats.max_attack_delay_time
		_attack()

## Sends the room a signal for the attack
func _attack():
	# TODO Add crit damage
	# Animate the player attack, if the player is visible
	if visible:
		_animate_attack()
	# Emit signal to the room
	attack.emit(self)

## Tweens the character twoards the center of the room
func _animate_attack():
	var shimmy_vector
	if int(position.x) % 400 < 200:
		shimmy_vector = Vector2(1, 0)
	else:
		shimmy_vector = Vector2(-1, 0)
	# Tween sprite in direction
	var tween = get_tree().create_tween()
	var shimmy_magnitude = 20
	var shimmy_duration = .15
	var original_position = sprite.position
	var position_shift = shimmy_vector * shimmy_magnitude
	tween.tween_property(sprite, "position", position_shift, shimmy_duration)
	tween.tween_property(sprite, "position", original_position, shimmy_duration)
	await tween.finished

## Get attacked by another character
func get_attacked(attacking_character):
	var damage = _calculate_damage(attacking_character)
	character_stats.current_hp -= damage
	_update_hp_bar()
	if character_stats.current_hp <= 0:
		_die()

## Calculate the damage done by the attacker
func _calculate_damage(attacking_character):
	return max(1, attacking_character.character_stats.power - character_stats.defense)

## Process character death
func _die():
	death.emit(self)

## Updates the hp bar
func _update_hp_bar():
	hp_bar.value = max(0, float(character_stats.current_hp) / character_stats.max_hp)

## Fully heals the character
func full_heal():
	character_stats.current_hp = character_stats.max_hp
	_update_hp_bar()

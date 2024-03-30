class_name EnemyCharacter extends Character

# Properties
var is_boss

# Called when the node enters the scene tree for the first time.
func _ready():
	font_size = 30

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_stats(character_stats):
	super(character_stats)
	_add_attack_timer_noise()

## Sets the character display name
func set_character_name(character_name):
	super(character_name)
	_adjust_text_offset()

## Adjust the text display to match the offset set by the sprite bounding box 
func _adjust_text_offset():
	var hp_bar_size = hp_bar.size.y * hp_bar.scale.y
	var text_box_size = name_text.size.y
	var hp_bar_position = -hp_bar_size - bounding_box.position.y
	var text_box_position = hp_bar_position - text_box_size
	hp_bar.position. y = hp_bar_position
	name_text.position.y = text_box_position

## Adds small random noise to attack timer to prevent all attacks happening at once
func _add_attack_timer_noise():
	character_stats.max_attack_delay_time = character_stats.max_attack_delay_time *\
	 randf_range(.95, 1.05)

## Overloaded to add variability to attack timers
func _attack():
	super()
	_add_attack_timer_noise()

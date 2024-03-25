class_name PlayerCharacter extends Character


# Called when the node enters the scene tree for the first time.
func _ready():
	attack_delay_max = 2
	hp_per_level_scaler = 5
	base_hp = 5
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

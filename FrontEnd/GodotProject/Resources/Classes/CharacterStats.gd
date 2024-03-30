class_name CharacterStats extends Resource

@export var level: int
@export var power: int
@export var wisdom: int
@export var dexterity: int
@export var defense: int
@export var max_attack_delay_time: float
@export var base_hp: int
@export var hp_per_level_scaler: int


# To be set during gameplay
var max_hp: int
var current_hp: int

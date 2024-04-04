class_name CharacterStats extends Resource

@export var level: int
@export var power: int
@export var wisdom: int
@export var dexterity: int
@export var defense: int
@export var max_attack_delay_time: float
@export var base_hp: int
@export var hp_per_level_scaler: int
@export var stat_points: int
@export var current_xp: int
@export var xp_to_next_level: int

# To be set during gameplay
var max_hp: int
var current_hp: int

func update_character_stats(loaded_stats):
	self.level = loaded_stats['level']
	self.power = loaded_stats['power']
	self.wisdom = loaded_stats['wisdom']
	self.dexterity = loaded_stats['dexterity']
	self.defense = loaded_stats['defense']
	self.max_attack_delay_time = loaded_stats['max_attack_delay_time']
	self.base_hp = loaded_stats['base_hp']
	self.hp_per_level_scaler = loaded_stats['hp_per_level_scaler']
	self.stat_points = loaded_stats['stat_points']
	self.current_xp = loaded_stats['current_xp']
	self.xp_to_next_level = loaded_stats['xp_to_next_level']
	self.max_hp = loaded_stats['max_hp']

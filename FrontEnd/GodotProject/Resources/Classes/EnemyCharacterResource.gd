class_name EnemyCharacterResource extends Resource

@export var name: String
@export var display_name: String
@export var sprite_frames: SpriteFrames
@export var scale: float
@export var stats: CharacterStats
# TODO split to enemy types for more granularity
@export var is_boss: bool
@export var sprite_bounding_box: Rect2i

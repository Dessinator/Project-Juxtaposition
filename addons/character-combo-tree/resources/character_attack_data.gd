@tool
class_name CharacterAttackData
extends Resource

@export var animation_name: StringName = ""
@export var next_attacks: Array[CharacterAttackData] = []

#@export var _hitbox_data: Dictionary = {} # e.g., {"shape": "rectangle", "width": 50, "height": 30}
#@export var _damage: float = 10.0

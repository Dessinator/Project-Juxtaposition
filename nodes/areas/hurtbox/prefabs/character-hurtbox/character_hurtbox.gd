@tool
class_name CharacterHurtbox
extends Hurtbox

# responsible for defining a hurtbox for a Character.

var character: Character

func initialize(character: Character):
	self.character = character

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

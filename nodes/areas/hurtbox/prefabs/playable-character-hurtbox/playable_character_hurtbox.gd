class_name PlayableCharacterHurtbox
extends Hurtbox

# responsible for providing the correct hurtbox to a PlayableCharacter depending on
# what character is currently active (via PlayableCharacterCharacterContainer)

var playable_character: PlayableCharacter
var current_character_hurtbox: CharacterHurtbox

func initialize(playable_character: PlayableCharacter) -> void:
	self.playable_character = playable_character
	
	var character_container = playable_character.get_playable_character_character_container()
	var character = character_container.get_current_character()
	_set_current_hurtbox(character.get_character_hurtbox())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_playable_character_character_container_current_character_changed(old: Character, new: Character) -> void:
	_set_current_hurtbox(new.get_character_hurtbox())

func _set_current_hurtbox(character_hurtbox: CharacterHurtbox):
	current_character_hurtbox = character_hurtbox
	shape = current_character_hurtbox.shape
	position = current_character_hurtbox.position

func _on_area_entered(area: Area3D):
	# the only areas that should be able to interact with
	# a hurtbox is a hitbox (due to the collision layers)
	# but just in case we'll run this check.
	var hitbox = area as Hitbox
	if not hitbox:
		return
	
	var instance = hitbox.damage_instance
	if instance.source == playable_character:
		return
	
	if not hitbox.try_consume():
		return
	
	var damage_instance = hitbox.consume()
	var status = status_interface.get_status()
	status.damage(damage_instance)

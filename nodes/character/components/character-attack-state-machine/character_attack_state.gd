@tool
class_name CharacterAttackState
extends FSMState

@export var _attack_definition: AttackDefinition

@onready var _transitions: Array = get_children()

var _can_advance_to_light_attack: bool = false
var _can_advance_to_heavy_attack: bool = false

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	assert(_attack_definition != null, "Character Attack State {attack_state_name} must have an Attack Definition!".format({
		"attack_state_name" : name
	}))
	
	_can_advance_to_light_attack = false
	_can_advance_to_light_attack = false
	
	for transition in _transitions:
		var next_state = transition.next_state as CharacterAttackState
		var next_attack_definition = next_state.get_attack_definition()
		
		# if there is no attack definition, assume the transition takes the character
		# back to the neutral state
		if next_attack_definition == null:
			continue
		
		print(next_attack_definition.resource_path)
		
		if next_attack_definition.get_attack_type() == AttackDefinition.AttackType.LIGHT:
			_can_advance_to_light_attack = true
			continue
		if next_attack_definition.get_attack_type() == AttackDefinition.AttackType.HEAVY:
			_can_advance_to_heavy_attack = true
			continue
	
	_attack_definition.attack_ended.connect(_on_attack_ended.bind(blackboard))
	
	_attack_definition.do(actor)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, blackboard: BTBlackboard) -> void:
	_handle_advance_buffering(blackboard)

# Executes before the state is exited.
func _on_exit(_actor: Node, blackboard: BTBlackboard) -> void:
	blackboard.set_value("advance_light_attack_buffered", false)
	blackboard.set_value("advance_heavy_attack_buffered", false)
	
	_attack_definition.attack_ended.disconnect(_on_attack_ended)

func get_attack_definition() -> AttackDefinition:
	return _attack_definition

func _handle_advance_buffering(blackboard: BTBlackboard):
	if blackboard.get_value("advance_light_attack_buffered"):
		return
	if blackboard.get_value("advance_heavy_attack_buffered"):
		return
	
	if Input.is_action_just_pressed("light_attack"):
		if not _can_advance_to_light_attack:
			return
		blackboard.set_value("advance_light_attack_buffered", true)
		return
	
	if Input.is_action_just_pressed("heavy_attack"):
		if not _can_advance_to_heavy_attack:
			return
		blackboard.set_value("advance_heavy_attack_buffered", true)
		return

func _on_attack_ended(blackboard: BTBlackboard):
	if blackboard.get_value("advance_light_attack_buffered"):
		get_parent().fire_event("advance_light_attack")
		return
	if blackboard.get_value("advance_heavy_attack_buffered"):
		get_parent().fire_event("advance_heavy_attack")
		return
	
	get_parent().fire_event("return_to_neutral_state")

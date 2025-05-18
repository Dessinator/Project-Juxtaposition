@tool
class_name CharacterAttackStateMachine
extends FiniteStateMachine

signal attack_state_entered
signal neutral_state_entered

@export var _neutral_states: Array[CharacterAttackState] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)

func set_next_attack_type(type: AttackDefinition.AttackType):
	blackboard.set_value("next_attack_type", type)

func _on_state_changed(state: FSMState):
	if _neutral_states.has(state):
		neutral_state_entered.emit()
		return
	
	attack_state_entered.emit()

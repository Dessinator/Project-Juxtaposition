@tool
extends PlayableCharacterGameplayState

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager

var _attack_instance: AttackInstance
var _attack_instance_awaiting_phase_advance_input: bool
var _can_interrupt: bool = true
var _interrupted: bool = false

@export var _damage_multiplier: float = 1

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	actor.velocity = Vector3.ZERO
	_can_interrupt = true
	_interrupted = false
	_handle_attack_chain_start(actor, blackboard)
	
# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var interrupted = _handle_charge_interrupt(actor, blackboard.get_value("holding_light_attack_input"))
	if interrupted:
		_handle_transitions(actor, blackboard)
		return
	
	_handle_attack_phase_advance_input(actor, blackboard)

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	
	_can_interrupt = true
	_interrupted = false
	
	_attack_instance.charge_attack_advance_requested.disconnect(_on_charge_attack_advance_requested)
	_attack_instance.await_attack_phase_advance_input_requested.disconnect(_on_await_attack_phase_advance_input_requested)
	_attack_instance.ignore_attack_phase_advance_input_requested.disconnect(_on_ignore_attack_phase_advance_input_requested)
	_attack_instance.attack_concluded.disconnect(_on_attack_concluded)
	_attack_instance = null
	_attack_instance_awaiting_phase_advance_input = false

func _handle_attack_chain_start(playable_character: PlayableCharacter, blackboard: BTBlackboard):
	if blackboard.get_value(CURRENT_ATTACK_PHASE):
		_handle_attack_chain_continue(playable_character, blackboard)
		return
	
	_attack_instance = _playable_character_combat_manager.start_charged_attack(_animation_state, 1)
	_attack_instance.charge_attack_advance_requested.connect(_on_charge_attack_advance_requested)
	_attack_instance.await_attack_phase_advance_input_requested.connect(_on_await_attack_phase_advance_input_requested.bind(playable_character, blackboard))
	_attack_instance.ignore_attack_phase_advance_input_requested.connect(_on_ignore_attack_phase_advance_input_requested.bind(playable_character, blackboard))
	_attack_instance.attack_concluded.connect(_on_attack_concluded.bind(playable_character, blackboard))

func _handle_attack_chain_continue(playable_character: PlayableCharacter, blackboard: BTBlackboard):
	var next_phase = blackboard.get_value(CURRENT_ATTACK_PHASE) + 1
	if next_phase > 3:
		next_phase = 1
	_attack_instance = _playable_character_combat_manager.start_charged_attack(_animation_state, next_phase)
	_attack_instance.charge_attack_advance_requested.connect(_on_charge_attack_advance_requested)
	_attack_instance.await_attack_phase_advance_input_requested.connect(_on_await_attack_phase_advance_input_requested.bind(playable_character, blackboard))
	_attack_instance.ignore_attack_phase_advance_input_requested.connect(_on_ignore_attack_phase_advance_input_requested.bind(playable_character, blackboard))
	_attack_instance.attack_concluded.connect(_on_attack_concluded.bind(playable_character, blackboard))

func _handle_charge_interrupt(playable_character: PlayableCharacter, holding_light_attack_input: bool) -> bool:
	if not _can_interrupt:
		return false
	
	if holding_light_attack_input:
		return false
	
	playable_character.emit_action_interrupted(_action_type)
	return true

func _handle_attack_phase_advance_input(playable_character: PlayableCharacter, blackboard: BTBlackboard):
	if _interrupted:
		return
	
	if not _attack_instance_awaiting_phase_advance_input:
		return

	if blackboard.get_value("holding_light_attack_input"):
		_handle_attack_phase_advance(playable_character, blackboard)
		return
	if blackboard.get_value("holding_heavy_attack_input"):
		playable_character.pressed_light_attack_input.disconnect(_on_pressed_light_attack_input)
		playable_character.pressed_heavy_attack_input.disconnect(_on_pressed_heavy_attack_input)
		_attack_instance.await_attack_phase_advance_input_requested.disconnect(_on_await_attack_phase_advance_input_requested)
		_attack_instance.ignore_attack_phase_advance_input_requested.disconnect(_on_ignore_attack_phase_advance_input_requested)
		_attack_instance.attack_concluded.disconnect(_on_attack_concluded)
		_attack_instance_awaiting_phase_advance_input = false
		
		# wait for the attack animation to end before transitioning to the next
		# (this should allow for input buffering)
		await _attack_instance.attack_concluded
		
		get_parent().fire_event(ON_START_GROUNDED_HEAVY_CHARGE_ATTACK)
		return
func _handle_attack_phase_advance(playable_character: PlayableCharacter, blackboard: BTBlackboard):
	_attack_instance.charge_attack_advance_requested.disconnect(_on_charge_attack_advance_requested)
	_attack_instance.await_attack_phase_advance_input_requested.disconnect(_on_await_attack_phase_advance_input_requested)
	_attack_instance.ignore_attack_phase_advance_input_requested.disconnect(_on_ignore_attack_phase_advance_input_requested)
	_attack_instance.attack_concluded.disconnect(_on_attack_concluded)
	_attack_instance_awaiting_phase_advance_input = false
	
	# wait for the attack animation to end before transitioning to the next
	# (this should allow for input buffering)
	await _attack_instance.attack_concluded
	
	_attack_instance = null
	
	_handle_attack_chain_continue(playable_character, blackboard)

func _on_charge_attack_advance_requested():
	_can_interrupt = false
func _on_await_attack_phase_advance_input_requested(playable_character: PlayableCharacter, blackboard: BTBlackboard):
	_attack_instance_awaiting_phase_advance_input = true

	playable_character.pressed_light_attack_input.connect(_on_pressed_light_attack_input.bind(playable_character, blackboard))
	playable_character.pressed_heavy_attack_input.connect(_on_pressed_heavy_attack_input.bind(playable_character, blackboard))

func _on_ignore_attack_phase_advance_input_requested(playable_character: PlayableCharacter, _blackboard: BTBlackboard):
	if (_attack_instance == null) or (not _attack_instance_awaiting_phase_advance_input):
		return 
	
	_attack_instance_awaiting_phase_advance_input = false

	playable_character.pressed_light_attack_input.disconnect(_on_pressed_light_attack_input)
	playable_character.pressed_heavy_attack_input.disconnect(_on_pressed_heavy_attack_input)
	_attack_instance.await_attack_phase_advance_input_requested.disconnect(_on_await_attack_phase_advance_input_requested)
	_attack_instance.ignore_attack_phase_advance_input_requested.disconnect(_on_ignore_attack_phase_advance_input_requested)
	
func _on_attack_concluded(playable_character: PlayableCharacter, blackboard: BTBlackboard):
	if _attack_instance == null:
		return 
	
	_playable_character_combat_manager.conclude_attack()
	_handle_transitions(playable_character, blackboard)

func _on_pressed_light_attack_input(playable_character: PlayableCharacter, _blackboard: BTBlackboard):
	playable_character.pressed_light_attack_input.disconnect(_on_pressed_light_attack_input)
	playable_character.pressed_heavy_attack_input.disconnect(_on_pressed_heavy_attack_input)
	_attack_instance.await_attack_phase_advance_input_requested.disconnect(_on_await_attack_phase_advance_input_requested)
	_attack_instance.ignore_attack_phase_advance_input_requested.disconnect(_on_ignore_attack_phase_advance_input_requested)
	_attack_instance.attack_concluded.disconnect(_on_attack_concluded)
	_attack_instance_awaiting_phase_advance_input = false
	
	# wait for the attack animation to end before transitioning to the next
	# (this should allow for input buffering)
	await _attack_instance.attack_concluded
	
	get_parent().fire_event(ON_START_GROUNDED_LIGHT_ATTACK)
func _on_pressed_heavy_attack_input(playable_character: PlayableCharacter, _blackboard: BTBlackboard):
	playable_character.pressed_light_attack_input.disconnect(_on_pressed_light_attack_input)
	playable_character.pressed_heavy_attack_input.disconnect(_on_pressed_heavy_attack_input)
	_attack_instance.await_attack_phase_advance_input_requested.disconnect(_on_await_attack_phase_advance_input_requested)
	_attack_instance.ignore_attack_phase_advance_input_requested.disconnect(_on_ignore_attack_phase_advance_input_requested)
	_attack_instance.attack_concluded.disconnect(_on_attack_concluded)
	_attack_instance_awaiting_phase_advance_input = false
	
	# wait for the attack animation to end before transitioning to the next
	# (this should allow for input buffering)
	await _attack_instance.attack_concluded
	
	get_parent().fire_event(ON_START_GROUNDED_HEAVY_ATTACK)

func _handle_transitions(actor: PlayableCharacter, blackboard: BTBlackboard):
	if not actor.is_on_floor():
		get_parent().fire_event(ON_START_FALLING)
		return
	
	if not Input.is_action_pressed("move"):
		get_parent().fire_event(ON_START_IDLING)
		return
	
	var character_container = actor.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var status = current_character.get_character_status()
	
	if Input.is_action_pressed("sprint") and (not status.is_exhausted()):
		get_parent().fire_event(ON_START_SPRINTING)
		return
	
	if blackboard.get_value(AUTO_JOG):
		get_parent().fire_event(ON_START_JOGGING)
		return
	
	get_parent().fire_event(ON_START_WALKING)

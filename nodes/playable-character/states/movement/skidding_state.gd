@tool
extends PlayableCharacterGameplayState

@export var _speed_retained_percentage: float = 0.5
@export var _skid_duration_timer: Timer
@export var _skid_cooldown_timer: Timer

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	var velocity = _handle_skidding(actor.velocity)
	_playable_character_mover.use_root_motion = false
	_playable_character_mover.set_velocity(velocity)
	
	_skid_duration_timer.timeout.connect(_on_skid_duration_timer_timeout.bind(actor, blackboard))
	_skid_duration_timer.start()

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	_playable_character_mover.use_root_motion = true
	_skid_duration_timer.timeout.disconnect(_on_skid_duration_timer_timeout)

func _handle_skidding(current_velocity: Vector3) -> Vector3:
	var velocity = Vector3(
		current_velocity.x * _speed_retained_percentage,
		0,
		current_velocity.z * _speed_retained_percentage)
	
	return velocity

func _handle_transition_events(actor: Node, blackboard: BTBlackboard):
	if Input.is_action_pressed("move"):
		if Input.is_action_pressed("sprint"):
			get_parent().fire_event(ON_START_SPRINTING)
			return

		blackboard.remove_value("is_skidding_allowed_while_running")
		get_parent().fire_event(ON_START_WALKING)
		return 
	
	blackboard.remove_value("is_skidding_allowed_while_running")
	get_parent().fire_event(ON_START_IDLING)
	return

func _on_skid_duration_timer_timeout(playable_character: PlayableCharacter, blackboard: BTBlackboard):
	_playable_character_mover.set_velocity(Vector3.ZERO)
	_handle_transition_events(playable_character, blackboard)
	_skid_cooldown_timer.start()

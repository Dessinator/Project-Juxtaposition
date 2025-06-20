@tool
extends PlayableCharacterGameplayState

@export var _speed_retained_percentage: float = 0.5
@export var _skid_duration_timer: Timer
@export var _skid_cooldown_timer: Timer

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	var velocity = _handle_skidding(actor.velocity)
	actor.velocity = velocity
	
	_skid_duration_timer.timeout.connect(_on_skid_duration_timer_timeout)
	_skid_duration_timer.start()

func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	if not _skid_duration_timer.is_stopped():
		return
	
	actor.velocity = Vector3.ZERO
	_handle_transition_events(actor, blackboard)

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
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
			get_parent().fire_event("on_start_sprinting")
			return

		blackboard.remove_value("is_skidding_allowed_while_running")
		get_parent().fire_event("on_start_walking")
		return 
	
	blackboard.remove_value("is_skidding_allowed_while_running")
	get_parent().fire_event("on_start_idling")
	return

func _on_skid_duration_timer_timeout():
	_skid_cooldown_timer.start()

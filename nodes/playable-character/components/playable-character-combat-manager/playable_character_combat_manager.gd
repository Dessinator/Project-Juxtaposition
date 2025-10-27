class_name PlayableCharacterCombatManager
extends Node

const HITBOX_SCENE = preload("res://nodes/areas/hitbox/hitbox.tscn")

const IS_STAYING: String = "is_staying"
const IS_TARGETING: String = "is_targeting"
const TRACKED_TARGET_POSITION: String = "tracked_target_position"

const ATTACK_STAT: StringName = &"attack"
const ATTACK_DAMAGE_STAT: StringName = &"attack_damage"
const CRITICAL_CHANCE_STAT: StringName = &"critical_chance"
const CRITICAL_MULTIPLIER_STAT: StringName = &"critical_multiplier"

const PLACEHOLDER_POSITION_DISTANCE: float = 20.0

# const CURRENT_ATTACK_PHASE: String = "current_attack_phase"
const COMBO_ACTIVE: String = "combo_active"
const CURRENT_ATTACK_ANIMATION_NAME: String = "current_attack_animation_name"
const ATTACK_CONCLUDED: String = "attack_concluded"

signal stop_targeting
signal start_targeting
signal damage_dealt(damage: int)

signal await_attack_phase_advance_input_requested
signal ignore_attack_phase_advance_input_requested

@onready var _camera_behaviour_tree: BeehaveTree = %CameraBehaviourTree
@onready var _camera_behaviour_tree_blackboard: BHBlackboard = %CameraBehaviourTreeBlackboard
@onready var _gameplay_blackboard: BTBlackboard = _gameplay_finite_state_machine.blackboard
@onready var _animation_blackboard: BTBlackboard = _animation_finite_state_machine.blackboard
@onready var _damage_interrupt_timer: Timer = %DamageInterruptTimer

var playable_character: PlayableCharacter
var _current_character: Character

var _tracked_target: TrackableTarget

var _current_interrupt_callback: Signal

@export var camera: PlayableCharacterCamera
@export var target_range: PlayableCharacterRange
@export var _gameplay_finite_state_machine: FiniteStateMachine
@export var _animation_finite_state_machine: FiniteStateMachine

@export var _parry_stamina_cost: int = 3
@export var _dodge_stamina_cost: int = 3

func initialize(playable_character: PlayableCharacter) -> void:
	self.playable_character = playable_character
	var character_container = playable_character.get_playable_character_character_container()
	_current_character = character_container.get_current_character()
	
	_camera_behaviour_tree.enable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_targeting()

func _unhandled_input(event: InputEvent) -> void:
	_camera_behaviour_tree_blackboard.set_value(IS_STAYING, _handle_toggle_staying(_camera_behaviour_tree_blackboard.get_value("is_staying", false)))
	_gameplay_blackboard.set_value(IS_TARGETING, _handle_toggle_targeting(_gameplay_blackboard.get_value("is_targeting")))
	_animation_blackboard.set_value(IS_TARGETING, _handle_toggle_targeting(_animation_blackboard.get_value("is_targeting")))
	
	_handle_damage_interruption_input()

func _on_playable_character_character_container_current_character_changed(old: Character, new: Character) -> void:
	_current_character = new
	
	if old:
		var old_status = old.get_character_status()
		old_status.about_to_be_damaged.disconnect(_on_current_character_about_to_be_damaged)
	var new_status = _current_character.get_character_status()
	new_status.about_to_be_damaged.connect(_on_current_character_about_to_be_damaged)

# targeting

func get_tracked_target() -> TrackableTarget:
	return _tracked_target

func _handle_toggle_staying(is_staying: bool) -> bool:
	if Input.is_action_just_pressed("stay_camera"):
		return not is_staying
	return is_staying
func _handle_toggle_targeting(is_targeting: bool) -> bool:
	if Input.is_action_just_pressed("target") and Input.is_action_pressed("backwards"):
		if _tracked_target:
			_tracked_target.set_tracked(false)
			_tracked_target = null
		if is_targeting == true:
			stop_targeting.emit()
		return false
	
	if Input.is_action_just_pressed("target"):
		if is_targeting == false:
			start_targeting.emit()
		return true
	
	return is_targeting

func _handle_targeting():
	if not _gameplay_blackboard.get_value(IS_TARGETING):
		_camera_behaviour_tree_blackboard.erase_value(TRACKED_TARGET_POSITION)
		_gameplay_blackboard.remove_value(TRACKED_TARGET_POSITION)
		_animation_blackboard.remove_value(TRACKED_TARGET_POSITION)
		return
	
	if target_range.targets_in_range.is_empty():
		var placeholder_position = (camera.get_front_direction() * PLACEHOLDER_POSITION_DISTANCE) + playable_character.global_position		
		_camera_behaviour_tree_blackboard.set_value(TRACKED_TARGET_POSITION, placeholder_position)
		_gameplay_blackboard.set_value(TRACKED_TARGET_POSITION, placeholder_position)
		_animation_blackboard.set_value(TRACKED_TARGET_POSITION, placeholder_position)
		return
	
	# if tracked target is null find the closest target
	if _tracked_target == null:
		var closest = _find_closest_target_in_target_range()
		_tracked_target = closest
		_tracked_target.set_tracked(true)
	
	if Input.is_action_just_pressed("track_next_target"):
		_tracked_target.set_tracked(false)
		var next_target = _find_next_target_in_target_range(_tracked_target)
		_tracked_target = next_target
		_tracked_target.set_tracked(true)
	
	if Input.is_action_just_pressed("track_previous_target"):
		_tracked_target.set_tracked(false)
		var next_target = _find_previous_target_in_target_range(_tracked_target)
		_tracked_target = next_target
		_tracked_target.set_tracked(true)
	
	_camera_behaviour_tree_blackboard.set_value(TRACKED_TARGET_POSITION, _tracked_target.global_position)
	_gameplay_blackboard.set_value(TRACKED_TARGET_POSITION, _tracked_target.global_position)
	_animation_blackboard.set_value(TRACKED_TARGET_POSITION, _tracked_target.global_position)

func _find_closest_target_in_target_range() -> TrackableTarget:
	var min_distance = 9999999
	var closest
	
	for target in target_range.targets_in_range:
		var distance = target_range.global_position.distance_to(target.global_position)
		if distance >= min_distance:
			continue
		
		min_distance = distance
		closest = target
	
	return closest
func _find_next_target_in_target_range(current_target: Node) -> TrackableTarget:
	assert(target_range.targets_in_range.has(current_target), "Could not find target {current_target} in TargetRange!".format({"current_target" : current_target.get_parent().name}))
	
	var current_index = target_range.targets_in_range.find(current_target)
	var next_index = current_index + 1
	if next_index >= target_range.targets_in_range.size():
		next_index = 0
	
	return target_range.targets_in_range[next_index]
func _find_previous_target_in_target_range(current_target: Node) -> TrackableTarget:
	assert(target_range.targets_in_range.has(current_target), "Could not find target {current_target} in TargetRange!".format({"current_target" : current_target.get_parent().name}))
	
	var current_index = target_range.targets_in_range.find(current_target)
	var next_index = current_index - 1
	if next_index < 0:
		next_index = target_range.targets_in_range.size() - 1
	
	return target_range.targets_in_range[next_index]
func _on_playable_character_target_range_target_entered(_target: TrackableTarget) -> void:
	pass
func _on_playable_character_target_range_target_exited(target: TrackableTarget) -> void:
	if target == _tracked_target:
		_tracked_target.set_tracked(false)
		_tracked_target = null

# attacking

func can_do_attack(attack_type: CharacterAttackState.AttackType) -> bool:
	var attack_state_machine = _current_character.get_character_attack_state_machine()
	var current_attack_state = attack_state_machine.active_state

	var next_state: CharacterAttackState
	for transition in current_attack_state.transitions:
		var possible_next_state = transition.next_state as CharacterAttackState
		assert(possible_next_state, "State {state} is not a CharacterAttackState!".format({"state" : possible_next_state}))
		
		if not possible_next_state.attack_type == attack_type:
			continue
		
		return true
	

	return false

func start_attack(attack_type: CharacterAttackState.AttackType, animation_state: PlayableCharacterAnimationState) -> AttackInstance:
	var attack_state_machine = _current_character.get_character_attack_state_machine()
	var current_attack_state = attack_state_machine.active_state

	var next_state: CharacterAttackState
	for transition in current_attack_state.transitions:
		var possible_next_state = transition.next_state as CharacterAttackState
		assert(possible_next_state, "State {state} is not a CharacterAttackState!".format({"state" : possible_next_state}))
		
		if not possible_next_state.attack_type == attack_type:
			continue
		
		next_state = possible_next_state
	
	# if there are no attacks that match the given attack type,
	# do not proceed!
	# (can_do_attack() should still be ran before even trying, though.)
	if not next_state:
		return null
	
	attack_state_machine.change_state(next_state)
	_gameplay_blackboard.set_value(COMBO_ACTIVE, true)
	_animation_blackboard.set_value(CURRENT_ATTACK_ANIMATION_NAME, next_state.animation_name)
	_animation_finite_state_machine.change_state(animation_state)
	
	var attack_instance = AttackInstance.new()
	var character_model = _current_character.get_character_model()

	character_model.request_spawn_hitbox_on_target.connect(_on_request_spawn_hitbox_on_target)
	character_model.request_await_attack_phase_advance_input.connect(attack_instance.emit_await_attack_phase_advance_input_requested)
	character_model.request_ignore_attack_phase_advance_input.connect(attack_instance.emit_ignore_attack_phase_advance_input_requested)
	character_model.attack_concluded.connect(attack_instance.emit_attack_concluded)

	## if this attack is a charged attack (CHLA or CHHA), connect the request_charge_attack_advance
	## signal to the attack_instance, too.
	if (attack_type == CharacterAttackState.AttackType.TYPE_CHARGED_LIGHT_ATTACK) or (attack_type == CharacterAttackState.AttackType.TYPE_CHARGED_HEAVY_ATTACK):
		character_model.request_charge_attack_advance.connect(attack_instance.emit_charge_attack_advance_requested)
	
	return attack_instance

# func start_attack(animation_state: PlayableCharacterAnimationState, phase: int) -> AttackInstance:
# 	_gameplay_finite_state_machine.blackboard.set_value(CURRENT_ATTACK_PHASE, phase)
# 	_animation_finite_state_machine.blackboard.set_value(CURRENT_ATTACK_PHASE, phase)
# 	_animation_finite_state_machine.change_state(animation_state)
	
# 	var attack_instance = AttackInstance.new()
# 	var character_model = _current_character.get_character_model()
	
# 	character_model.request_spawn_hitbox_on_target.connect(_on_request_spawn_hitbox_on_target)
# 	character_model.request_await_attack_phase_advance_input.connect(attack_instance.emit_await_attack_phase_advance_input_requested)
# 	character_model.request_ignore_attack_phase_advance_input.connect(attack_instance.emit_ignore_attack_phase_advance_input_requested)
# 	character_model.attack_concluded.connect(attack_instance.emit_attack_concluded)
	
# 	return attack_instance

# func start_charged_attack(animation_state: PlayableCharacterAnimationState, phase: int) -> AttackInstance:
# 	_gameplay_finite_state_machine.blackboard.set_value(CURRENT_ATTACK_PHASE, phase)
# 	_animation_finite_state_machine.blackboard.set_value(CURRENT_ATTACK_PHASE, phase)
# 	_animation_finite_state_machine.change_state(animation_state)
	
# 	var attack_instance = AttackInstance.new()
# 	var character_model = _current_character.get_character_model()
	
# 	character_model.request_spawn_hitbox_on_target.connect(_on_request_spawn_hitbox_on_target)
# 	character_model.request_charge_attack_advance.connect(attack_instance.emit_charge_attack_advance_requested)
# 	character_model.request_await_attack_phase_advance_input.connect(attack_instance.emit_await_attack_phase_advance_input_requested)
# 	character_model.request_ignore_attack_phase_advance_input.connect(attack_instance.emit_ignore_attack_phase_advance_input_requested)
# 	character_model.attack_concluded.connect(attack_instance.emit_attack_concluded)
	
# 	return attack_instance

# NOTE: not sure if this function is really necessary right now. but. just in case. -Pastiree
func interrupt_attack():
	var attack_state_machine = _current_character.get_character_attack_state_machine()
	var character_model = _current_character.get_character_model()
	
	attack_state_machine.fire_event(ATTACK_CONCLUDED)
	character_model.request_spawn_hitbox_on_target.disconnect(_on_request_spawn_hitbox_on_target)
	_gameplay_blackboard.set_value(COMBO_ACTIVE, false)
	_animation_finite_state_machine.blackboard.remove_value(CURRENT_ATTACK_ANIMATION_NAME)

func conclude_attack():
	var attack_state_machine = _current_character.get_character_attack_state_machine()
	var character_model = _current_character.get_character_model()
	
	attack_state_machine.fire_event(ATTACK_CONCLUDED)
	character_model.request_spawn_hitbox_on_target.disconnect(_on_request_spawn_hitbox_on_target)
	_gameplay_blackboard.set_value(COMBO_ACTIVE, false)
	_animation_finite_state_machine.blackboard.remove_value(CURRENT_ATTACK_ANIMATION_NAME)

func _on_request_spawn_hitbox_on_target():
	var hitbox: Hitbox = HITBOX_SCENE.instantiate()
	playable_character.add_child(hitbox)
	
	var hitbox_position: Vector3
	if not _tracked_target:
		# if no tracked target, the hitbox will be spawned 10 units away from
		# the PlayableCharacter in the forward position.
		
		hitbox_position = (playable_character.get_front_direction() * 10) + playable_character.global_position
	else:
		hitbox_position = _tracked_target.global_position
	
	var damage_instance = DamageInstance.new()
	damage_instance.source = playable_character
	damage_instance.base_damage = 10
	damage_instance.can_dodge = false
	damage_instance.can_parry = false
	damage_instance.is_crit = false
	damage_instance.spawn_damage_number = true
	
	var shape = BoxShape3D.new()
	shape.size = Vector3.ONE * 5
	
	hitbox.source = playable_character
	hitbox.damage_instance = damage_instance
	hitbox.shape = shape
	
	hitbox.top_level = true
	hitbox.global_position = hitbox_position
	hitbox.enable()
	await get_tree().create_timer(0.1).timeout
	hitbox.queue_free()

# damaging

func deal_damage(status_interface: StatusInterface, damage_multiplier: float = 1, can_dodge: bool = true, can_parry: bool = true):
	var status = status_interface.get_status()
	
	var stats = _current_character.get_character_stats()
	var attack_stat = stats.get_stat(ATTACK_STAT)
	var attack_value = attack_stat.get_value(false)
	var attack_damage_stat = stats.get_substat(ATTACK_DAMAGE_STAT)
	var critical_chance_stat = stats.get_substat(CRITICAL_CHANCE_STAT)
	var critical_multiplier_stat = stats.get_substat(CRITICAL_MULTIPLIER_STAT)
	var attack_damage_value = attack_damage_stat.sample(attack_value, false)
	var critical_chance_value = critical_chance_stat.sample(attack_value, false) 
	var critical_multiplier_value = critical_multiplier_stat.sample(attack_value, false) 
	
	var damage = attack_damage_value * damage_multiplier
	var crit = randf() < critical_chance_value
	if crit:
		damage += damage * critical_multiplier_value
	damage = int(damage + 0.5)
	
	var damage_instance = DamageInstance.new()
	damage_instance.source = playable_character
	damage_instance.base_damage = damage
	damage_instance.can_dodge = can_dodge
	damage_instance.can_parry = can_parry
	damage_instance.is_crit = crit
	damage_instance.spawn_damage_number = true
	
	status.damage(damage_instance)
	damage_dealt.emit(damage)

# parrying and dodging

func _on_current_character_about_to_be_damaged(damage_instance: DamageInstance, interrupt_callback: Signal):
	_current_interrupt_callback = interrupt_callback
	_gameplay_finite_state_machine.blackboard.set_value("interrupted_damage_instance", damage_instance)
	_damage_interrupt_timer.start(damage_instance.time_to_interrupt)
	_damage_interrupt_timer.timeout.connect(_on_damage_interrupt_timer_timeout)

func _on_damage_interrupt_timer_timeout():
	_handle_damage_interrupt_failure()

func _handle_damage_interruption_input():
	if _current_interrupt_callback.is_null():
		return
	
	var interrupted_damage_instance = _gameplay_finite_state_machine.blackboard.get_value("interrupted_damage_instance")
	
	if Input.is_action_just_pressed("parry"):
		if _can_parry() and interrupted_damage_instance.can_parry:
			_handle_damage_interrupt_success()
			_handle_parry()
			return
		_handle_damage_interrupt_failure()
		return
	
	if Input.is_action_just_pressed("dodge"):
		if _can_dodge() and interrupted_damage_instance.can_dodge:
			_handle_damage_interrupt_success()
			_handle_dodge()
			return
		_handle_damage_interrupt_failure()
		return

func _handle_damage_interrupt_failure():
	_damage_interrupt_timer.timeout.disconnect(_on_damage_interrupt_timer_timeout)
	_current_interrupt_callback.emit(false)
	_current_interrupt_callback = Signal()
	_gameplay_finite_state_machine.blackboard.set_value("interrupted_damage_instance", null)

func _handle_damage_interrupt_success():
	_damage_interrupt_timer.timeout.disconnect(_on_damage_interrupt_timer_timeout)
	_damage_interrupt_timer.stop()
	_current_interrupt_callback.emit(true)
	_current_interrupt_callback = Signal()

func _handle_parry():
	_current_character.get_character_status().exhaust(_parry_stamina_cost)
	_gameplay_finite_state_machine.fire_event("on_parry")
func _handle_dodge():
	_current_character.get_character_status().exhaust(_dodge_stamina_cost)
	_gameplay_finite_state_machine.fire_event("on_dodge")

func get_parry_stamina_cost() -> int:
	return _parry_stamina_cost
func get_dodge_stamina_cost() -> int:
	return _dodge_stamina_cost
func _can_parry() -> bool:
	var status = _current_character.get_character_status()
	var stamina_drain = _parry_stamina_cost
	var stamina = status.get_stamina()
	
	return stamina - stamina_drain >= 0
func _can_dodge() -> bool:
	var status = _current_character.get_character_status()
	var stamina_drain = _dodge_stamina_cost
	var stamina = status.get_stamina()
	
	return stamina - stamina_drain >= 0

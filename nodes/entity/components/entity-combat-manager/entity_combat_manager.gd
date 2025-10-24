extends Node
class_name EntityCombatManager

signal damage_dealt(damage: int)

@onready var _status_interface: StatusInterface = %StatusInterface
@onready var _state_machine: FiniteStateMachine = %StateMachine

var entity: Entity

func initialize(entity: Entity) -> void:
	self.entity = entity
	
	var status = _status_interface.get_status()
	status.about_to_be_damaged.connect(_on_about_to_be_damaged)
	status.damaged.connect(_on_damaged)

# damaging

func deal_damage(status_interface: StatusInterface, damage: int, can_dodge: bool, can_parry: bool):
	var status = status_interface.get_status()
	
	var damage_instance = DamageInstance.new()
	damage_instance.source = entity
	damage_instance.base_damage = damage
	damage_instance.can_dodge = can_dodge
	damage_instance.can_parry = can_parry
	damage_instance.spawn_damage_number = true
	
	status.damage(damage_instance)
	damage_dealt.emit(damage)

# parrying and dodging

func _on_about_to_be_damaged(damage_instance: DamageInstance, interrupt_callback: Signal):
	if not interrupt_callback.is_null():
		interrupt_callback.emit(false)
	#_current_interrupt_callback = interrupt_callback
	#_gameplay_finite_state_machine.blackboard.set_value("interrupted_damage_instance", damage_instance)
	#_damage_interrupt_timer.start(damage_instance.time_to_interrupt)
	#_damage_interrupt_timer.timeout.connect(_on_damage_interrupt_timer_timeout)

func _on_damaged(damage_instance: DamageInstance):
	_state_machine.fire_event("on_damaged")

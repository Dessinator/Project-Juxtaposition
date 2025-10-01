extends Resource
class_name DamageInstance

## responsible for communicating any information about any source of damage to any Status resource.

## The originator of the damage.
var source: Node

## Can this damage be dodged and negated?
var can_dodge: bool
## Can this damage be parried and negated?
var can_parry: bool
## The window of time where the damage can be interrupted.
var time_to_interrupt: float = 0.5

## The amount of damage to apply before resistances and other status effects.
var base_damage: int
## Is this critical damage?
var is_crit: bool
## The amount of additional damage to apply after resistances and other status effects.
var additional_damage: int 

## Spawn a damage number when consumed?
var spawn_damage_number: bool

# the only really required values are the source and base damage.
func _init(source: Node, base_damage: int) -> void:
	self.source = source
	self.base_damage = base_damage

func duplicate_instance() -> DamageInstance:
	var damage_instance = DamageInstance.new(self.source, self.base_damage)
	
	damage_instance.can_dodge = self.can_dodge
	damage_instance.can_parry = self.can_parry
	damage_instance.is_crit = self.is_crit
	damage_instance.additional_damage = self.additional_damage
	damage_instance.spawn_damage_number = self.spawn_damage_number
	
	return damage_instance

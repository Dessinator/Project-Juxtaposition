extends Resource
class_name HealInstance

## responsible for communicating any information about any source of healing to any Status resource.

## The originator of the heal.
var source: Node

## The amount of health to apply.
@export var heal: int

## Spawn a heal number when consumed?
@export var spawn_heal_number: bool

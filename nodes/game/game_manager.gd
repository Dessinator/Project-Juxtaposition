class_name GameManager
extends Node

@onready var _game_finite_state_machine: FiniteStateMachine = $GameFiniteStateMachine

func _ready():
	_game_finite_state_machine.start()

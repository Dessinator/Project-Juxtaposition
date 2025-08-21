@tool 
class_name CharacterComboChainRootGraphNode
extends CharacterComboChainGraphNode

@onready var _prerequisite_state_option: GraphNodeHorizontalOptionContainer = %PrerequisiteStateOption

var attached_chain: CharacterComboChain
var chain_root_node: CharacterComboChainRootNode

func _ready():
	_set_title()
	
	chain_root_node = attached_chain.root_node
	_update_prerequisite_state()

func _set_title():
	title = "{chain_name} Root".format({"chain_name" : attached_chain.chain_name})

func _on_prerequisite_state_option_input_set() -> void:
	_set_prerequisite_state()

func _update_prerequisite_state():
	%PrerequisiteStateOption.set_input_type(GraphNodeHorizontalOptionContainer.InputType.TYPE_OPTION)
	%PrerequisiteStateOption.set_value(chain_root_node.prerequisite_state)

func _set_prerequisite_state():
	var prerequisite_state = %PrerequisiteStateOption.read() as CharacterComboChainRootNode.ChainPrerequisiteState
	chain_root_node.prerequisite_state = prerequisite_state
	print(chain_root_node.prerequisite_state)

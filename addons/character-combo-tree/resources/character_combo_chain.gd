@tool
class_name CharacterComboChain
extends Resource

# Metadata
@export var chain_name: StringName
@export_multiline var chain_description: String

# Nodes
@export var root_node: CharacterComboChainRootNode = CharacterComboChainRootNode.new()
@export var nodes: Array[CharacterComboChainAttackNode]

func add_node(at: int, node: CharacterComboChainAttackNode):
	nodes.insert(at, node)

func remove_node(node: CharacterComboChainAttackNode):
	nodes.erase(node)

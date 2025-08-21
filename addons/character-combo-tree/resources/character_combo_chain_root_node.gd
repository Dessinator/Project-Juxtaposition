@tool
class_name CharacterComboChainRootNode
extends Resource

enum ChainPrerequisiteState
{
	STATE_GROUNDED,
	STATE_ARIAL,
	STATE_JUXTAPOSED
}

var starting_node: CharacterComboChainAttackNode

# The state that the PlayableCharacter preforming this combo needs to be in for it to be available.
@export var prerequisite_state: ChainPrerequisiteState = ChainPrerequisiteState.STATE_GROUNDED

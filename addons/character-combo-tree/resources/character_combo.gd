@tool
class_name CharacterCombo
extends Resource

@export var chains: Array[CharacterComboChain]:
	set(value):
		chains = value
		update_chain_lookup()

var chain_lookup: Dictionary[StringName, CharacterComboChain]

func add_chain(chain: CharacterComboChain):
	chains.append(chain)
	update_chain_lookup()

func remove_chain(chain_name: StringName):
	if not chain_lookup.has(chain_name):
		push_warning("Chain by name {chain_name} not found.".format({"chain_name" : str(chain_name)}))
		return
	
	var chain = chain_lookup[chain_name]
	chains.erase(chain)
	update_chain_lookup()

func update_chain_lookup():
	chain_lookup = {}
	
	for chain in chains:
		var chain_name = chain.chain_name
		chain_lookup[chain_name] = chain

#const GROUNDED_ROOT: StringName = &"grounded_root"
#const AIR_ROOT: StringName = &"air_root"
#const JUXTAPOSITION_ROOT: StringName = &"juxtaposition_root"
#const LIGHT_ATTACK_TYPE: StringName = &"light_attack"
#const HEAVY_ATTACK_TYPE: StringName = &"heavy_attack"
#
#@export var _combo_tree: Dictionary[StringName, Dictionary] = {
	#GROUNDED_ROOT : { LIGHT_ATTACK_TYPE : &"light_attack_internal_name", HEAVY_ATTACK_TYPE : &"heavy_attack_internal_name" },
	#AIR_ROOT : { LIGHT_ATTACK_TYPE : &"light_attack_internal_name", HEAVY_ATTACK_TYPE : &"heavy_attack_internal_name" },
	#JUXTAPOSITION_ROOT : { LIGHT_ATTACK_TYPE : &"light_attack_internal_name", HEAVY_ATTACK_TYPE : &"heavy_attack_internal_name" }
#}
#
#func get_next_attack_id(current_attack_internal_name: StringName, next_attack_type: StringName) -> StringName:
	## If no valid combo path, return an empty StringName.
	#if (not _combo_tree.has(current_attack_internal_name)) or (not _combo_tree[current_attack_internal_name].has(next_attack_type)):
		#return &""
	#
	#var next_attack_key = _combo_tree[current_attack_internal_name][next_attack_type]
	##_current_attack_key = next_attack_key
	#return next_attack_key
#
## Resets the combo chain back to the beginning.
##func reset_combo():
	##_current_attack_key = GROUNDED_ROOT

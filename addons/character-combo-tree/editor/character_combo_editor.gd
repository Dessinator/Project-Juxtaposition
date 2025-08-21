@tool
extends Control

const CHAIN_SELECTOR_BUTTON_SCENE = preload("res://addons/character-combo-tree/editor/chain_selector_button.tscn")
const CHAIN_NAMING_POPUP_SCENE = preload("res://addons/character-combo-tree/editor/chain_naming_popup.tscn")
const CHAINS_POPUP_MENU_SCENE = preload("res://addons/character-combo-tree/editor/chains_popup_menu.tscn")

const CHARACTER_COMBO_CHAIN_ROOT_GRAPH_NODE_SCENE = preload("res://addons/character-combo-tree/editor/graph-nodes/root/character_combo_chain_root_graph_node.tscn")
const CHARACTER_COMBO_CHAIN_LIGHT_ATTACK_GRAPH_NODE_SCENE = preload("res://addons/character-combo-tree/editor/graph-nodes/light-attack/character_combo_chain_light_attack_graph_node.tscn")
const CHARACTER_COMBO_CHAIN_HEAVY_ATTACK_GRAPH_NODE_SCENE = preload("res://addons/character-combo-tree/editor/graph-nodes/heavy-attack/character_combo_chain_heavy_attack_graph_node.tscn")
const CHARACTER_COMBO_CHAIN_DODGE_GRAPH_NODE_SCENE = preload("res://addons/character-combo-tree/editor/graph-nodes/dodge/character_combo_chain_dodge_graph_node.tscn")
const CHARACTER_COMBO_CHAIN_PARRY_GRAPH_NODE_SCENE = preload("res://addons/character-combo-tree/editor/graph-nodes/parry/character_combo_chain_parry_graph_node.tscn")
const CHARACTER_COMBO_CHAIN_JUXDODGE_GRAPH_NODE_SCENE = preload("res://addons/character-combo-tree/editor/graph-nodes/jux-dodge/character_combo_chain_juxdodge_graph_node.tscn")
const CHARACTER_COMBO_CHAIN_JUXPARRY_GRAPH_NODE_SCENE = preload("res://addons/character-combo-tree/editor/graph-nodes/jux-parry/character_combo_chain_juxparry_graph_node.tscn")
const CHARACTER_COMBO_CHAIN_JUXTAPOSE_GRAPH_NODE_SCENE = preload("res://addons/character-combo-tree/editor/graph-nodes/juxtapose/character_combo_chain_juxtapose_graph_node.tscn")

const CHAIN_PLACEHOLDER_NAME: StringName = &'New Chain'
const ADD_NODE_TEXT: String = "Add Node..."
const TOGGLE_ANIMATION_PREVIEW_BUTTON_TOOLTIP_TEXT: String = "Toggle animation preview."

@onready var _chains_button: MenuButton = %ChainsButton
@onready var _chains_popup_menu: PopupMenu = %ChainsPopupMenu
@onready var _delete_chain_confirmation_dialog: ConfirmationDialog = %DeleteChainConfirmationDialog
@onready var _chain_selector_button_container: VBoxContainer = %ChainSelectorButtonContainer
@onready var _no_chains_label: Label = %NoChainsLabel

@onready var _chain_description_editor: TextEdit = %ChainDescriptionEditor
@onready var _chain_description_label: RichTextLabel = %ChainDescriptionLabel
@onready var _chain_description_dimmer: Panel = %ChainDescriptionDimmer

@onready var _graph_edit: GraphEdit = %GraphEdit
@onready var _chain_editor_dimmer: Panel = %ChainsEditorDimmer
@onready var _node_popup_menu: PopupMenu = %NodePopupMenu
@onready var _delete_node_confirmation_dialog: ConfirmationDialog = %DeleteNodeConfirmationDialog
@onready var _add_node_menu: Window = %AddNodeMenu

@onready var _animation_preview_sidebar: VBoxContainer = %AnimationPreviewSidebar

var current_combo: CharacterCombo
var current_chain: CharacterComboChain
var current_node: CharacterComboChainGraphNode

var last_right_click_position: Vector2
var graph_nodes: Array[GraphNode] = []
var orphan_attack_nodes: Array = []

func _ready():
	orphan_attack_nodes = []
	
	_chains_button.get_popup().id_pressed.connect(_on_chains_popup_menu_id_pressed)
	_chains_popup_menu.id_pressed.connect(_on_chains_popup_menu_id_pressed)
	_node_popup_menu.id_pressed.connect(_on_node_popup_menu_id_pressed)
	
	_graph_edit.node_selected.connect(_on_node_selected)
	_graph_edit.popup_request.connect(_on_graph_edit_popup_request)
	_graph_edit.connection_request.connect(_on_connection_request)
	_graph_edit.disconnection_request.connect(_on_disconnection_request)
	
	_add_node_menu.light_attack_node_requested.connect(_on_light_attack_node_requested)
	_add_node_menu.heavy_attack_node_requested.connect(_on_heavy_attack_node_requested)
	_add_node_menu.dodge_node_requested.connect(_on_dodge_node_requested)
	_add_node_menu.parry_node_requested.connect(_on_parry_node_requested)
	_add_node_menu.jux_dodge_node_requested.connect(_on_jux_dodge_node_requested)
	_add_node_menu.jux_parry_node_requested.connect(_on_jux_parry_node_requested)
	_add_node_menu.juxtapose_node_requested.connect(_on_juxtapose_node_requested)
	
	_chain_description_editor.text_changed.connect(_on_chain_description_editor_text_changed)
	_chain_description_editor.text_set.connect(_on_chain_description_editor_text_set)
	_chain_description_editor.mouse_entered.connect(_on_chain_description_label_mouse_entered)
	_chain_description_editor.mouse_exited.connect(_on_chain_description_label_mouse_exited)
	
	_setup_graph_edit_toolbar()

func set_combo_data(combo: CharacterCombo):
	current_combo = combo
	update()

func update():
	_update_chains()
	_update_chains_editor()
	_update_chain_description_editor()

# Chains
func _select_chain(chain_name: StringName):
	current_chain = current_combo.chain_lookup[chain_name]
	_update_chains_editor()
	_update_chain_description_editor()
	
func _on_chain_selector_button_clicked(chain_name: StringName):
	_select_chain(chain_name)
	
func _on_chain_selector_button_right_clicked(chain_name: StringName):
	_select_chain(chain_name)
	
	var mouse_position = DisplayServer.mouse_get_position()
	var popup_position = mouse_position
	
	_show_chains_popup_menu(popup_position, true, true, true)

func _show_chains_popup_menu(popup_position, duplicate_available = false, rename_available = false, delete_available = false):
	_chains_popup_menu.popup()
	_chains_popup_menu.position = popup_position
	
	_chains_popup_menu.set_item_disabled(1, !duplicate_available)
	_chains_popup_menu.set_item_disabled(2, !rename_available)
	_chains_popup_menu.set_item_disabled(3, !delete_available)

func _on_chains_popup_menu_id_pressed(id: int):
	match id:
		0: # New Chain...
			_create_new_chain()
		1: # Duplicate Chain...
			_duplicate_chain(current_chain)
		2: # Rename Chain...
			_rename_chain(current_chain)
		3: # Delete Chain
			_confirm_delete_chain(current_chain)
		_:
			return

func _create_new_chain():
	var new_chain = CharacterComboChain.new()
	new_chain.chain_name = CHAIN_PLACEHOLDER_NAME
	
	var popup = CHAIN_NAMING_POPUP_SCENE.instantiate()
	add_child(popup)
	popup.popup()
	
	var chain_name = await popup.named
	if chain_name.is_empty():
		return
	new_chain.chain_name = chain_name
	
	current_combo.add_chain(new_chain)
	_select_chain(new_chain.chain_name)
	update()

func _duplicate_chain(original_chain: CharacterComboChain):
	var new_chain = original_chain.duplicate(true)
	new_chain.chain_name = CHAIN_PLACEHOLDER_NAME
	
	var popup = CHAIN_NAMING_POPUP_SCENE.instantiate()
	add_child(popup)
	popup.popup()
	
	var chain_name = await popup.named
	if chain_name.is_empty():
		return
	new_chain.chain_name = chain_name
	
	current_combo.add_chain(new_chain)
	_select_chain(new_chain.chain_name)
	update()
func _rename_chain(original_chain: CharacterComboChain):
	var popup = CHAIN_NAMING_POPUP_SCENE.instantiate()
	add_child(popup)
	popup.popup()
	
	var chain_name = await popup.named
	if chain_name.is_empty():
		return
	original_chain.chain_name = chain_name
	
	current_combo.update_chain_lookup()
	update()

func _confirm_delete_chain(chain: CharacterComboChain):
	_delete_chain_confirmation_dialog.popup()
	
	_delete_chain_confirmation_dialog.canceled.connect(_on_delete_chain_canceled)
	_delete_chain_confirmation_dialog.confirmed.connect(_on_delete_chain_confirmed.bind(chain))
func _on_delete_chain_canceled():
	_delete_chain_confirmation_dialog.canceled.disconnect(_on_delete_chain_canceled)
	_delete_chain_confirmation_dialog.confirmed.disconnect(_on_delete_chain_confirmed)
func _on_delete_chain_confirmed(chain: CharacterComboChain):
	_delete_chain_confirmation_dialog.canceled.disconnect(_on_delete_chain_canceled)
	_delete_chain_confirmation_dialog.confirmed.disconnect(_on_delete_chain_confirmed)
	
	_delete_chain(chain)
func _delete_chain(chain: CharacterComboChain):
	current_combo.remove_chain(chain.chain_name)
	update()

func _update_chains():
	for child in _chain_selector_button_container.get_children():
		child.queue_free()
	
	if not current_combo:
		return
	
	if current_combo.chains.is_empty():
		_no_chains_label.show()
		current_chain = null
		return
	
	_no_chains_label.hide()
	
	for chain in current_combo.chains:
		var chain_selector_button = CHAIN_SELECTOR_BUTTON_SCENE.instantiate()
		_chain_selector_button_container.add_child(chain_selector_button)
		chain_selector_button.chain_name = chain.chain_name
		
		chain_selector_button.right_clicked.connect(_on_chain_selector_button_right_clicked.bind(chain.chain_name))
		chain_selector_button.clicked.connect(_on_chain_selector_button_clicked.bind(chain.chain_name))
	
	current_chain = current_combo.chains[0]

# Chain Description
func _update_chain_description_editor():
	_chain_description_editor.clear()
	
	if not current_combo:
		return
	
	if current_combo.chains.is_empty():
		_chain_description_dimmer.show()
		return
	_chain_description_dimmer.hide()
	
	_chain_description_editor.text = current_chain.chain_description
	_chain_description_label.text = current_chain.chain_description

func _on_chain_description_editor_text_changed():
	current_chain.chain_description = _chain_description_editor.text
	_chain_description_label.text = current_chain.chain_description

func _on_chain_description_editor_text_set():
	pass
	#_chain_description_label.show()

func _on_chain_description_label_mouse_entered():
	_chain_description_editor.modulate = Color(1, 1, 1, 1)
func _on_chain_description_label_mouse_exited():
	_chain_description_editor.modulate = Color(1, 1, 1, 0)

# Chain Editor
func _setup_graph_edit_toolbar():
	var menu_hbox = _graph_edit.get_menu_hbox()
	
	var add_node_button: Button = Button.new()
	add_node_button.text = ADD_NODE_TEXT
	
	add_node_button.pressed.connect(_on_add_node_pressed)
	
	menu_hbox.add_child(add_node_button)
	menu_hbox.move_child(add_node_button, 0)
	
	var toggle_animation_preview_button = Button.new()
	toggle_animation_preview_button.icon = get_theme_icon("SubViewport", "EditorIcons")
	toggle_animation_preview_button.tooltip_text = TOGGLE_ANIMATION_PREVIEW_BUTTON_TOOLTIP_TEXT
	menu_hbox.add_child(toggle_animation_preview_button)
	
	toggle_animation_preview_button.pressed.connect(_toggle_animation_preview)

func _on_node_selected(node):
	node = node as CharacterComboChainGraphNode
	current_node = node

func _on_graph_edit_popup_request(at_position: Vector2):
	last_right_click_position = at_position
	
	# is there a GraphNode at this position
	var graph_node_found: GraphNode
	for graph_node in graph_nodes:
		var rect = graph_node.get_rect()
		if rect.has_point(at_position):
			graph_node_found = graph_node
			break
	
	var popup_position = DisplayServer.mouse_get_position()
	_node_popup_menu.popup()
	_node_popup_menu.position = DisplayServer.mouse_get_position()
	
	# if not, disable the 'Delete Node...' item
	if graph_node_found:
		# if this node is the root node, keep it disabled.
		if graph_node_found is CharacterComboChainRootGraphNode:
			_node_popup_menu.set_item_disabled(1, true)
			return
		_node_popup_menu.set_item_disabled(1, false)
		return
	_node_popup_menu.set_item_disabled(1, true)

func _update_chains_editor():
	_graph_edit.clear_connections()
	for child in _graph_edit.get_children():
		if not child is GraphElement:
			continue
		_remove_graph_node(child)
	
	if not current_combo:
		return
	
	if current_combo.chains.is_empty():
		_chain_editor_dimmer.show()
		return
	
	_chain_editor_dimmer.hide()
	
	_create_root_node()

func _add_graph_node(graph_node: CharacterComboChainGraphNode):
	_graph_edit.add_child(graph_node)
	graph_nodes.append(graph_node)
	
	# if not the root node then add this nodes attack_node to the unsaved nodes list
	if graph_node is CharacterComboChainRootGraphNode:
		return
	
	var attack_node = graph_node._create_attack_node()
	graph_node.node = attack_node
	orphan_attack_nodes.append(attack_node)
	print("Created new CharacterComboChainGraphNode - CharacterComboChainAttackNode {attack_node} currently orphaned.".format({"attack_node" : attack_node}))

func _remove_graph_node(graph_node: CharacterComboChainGraphNode):
	# cant remove the root
	if graph_node is CharacterComboChainRootGraphNode:
		return
	
	graph_nodes.erase(graph_node)
	
	var attack_node = graph_node.node
	
	# if the current chain doesn't have this attack node then it is an orphan node
	if current_chain.nodes.has(attack_node):
		current_chain.remove_node(attack_node)
		print("Removed CharacterComboChainGraphNode - Removed CharacterComboChainAttackNode {attack_node}".format({"attack_node" : attack_node}))
	
	orphan_attack_nodes.erase(attack_node)
	print("Removed CharacterComboChainGraphNode - Removed (orphaned) CharacterComboChainAttackNode {attack_node}".format({"attack_node" : attack_node}))
	graph_node.queue_free()

func _create_root_node():
	var root_graph_node: CharacterComboChainRootGraphNode = CHARACTER_COMBO_CHAIN_ROOT_GRAPH_NODE_SCENE.instantiate()
	root_graph_node.attached_chain = current_chain
	root_graph_node.node = current_chain.root_node
	
	print("Creating CharacterComboChainRootGraphNode - CharacterComboChainRootNode {root_node} successfully initialized.".format({"root_node" : current_chain.root_node}))
	
	_add_graph_node(root_graph_node)

func _on_node_popup_menu_id_pressed(id: int):
	match id:
		0: # Add Node...
			_on_add_node_pressed()
		1: # Delete Node...
			_confirm_delete_node(current_node)
		_:
			return

func _on_add_node_pressed():
	_add_node_menu.popup()

func _on_light_attack_node_requested() -> void:
	var light_attack_graph_node = CHARACTER_COMBO_CHAIN_LIGHT_ATTACK_GRAPH_NODE_SCENE.instantiate()
	_add_graph_node(light_attack_graph_node)
	light_attack_graph_node.position = last_right_click_position
func _on_heavy_attack_node_requested() -> void:
	var heavy_attack_graph_node = CHARACTER_COMBO_CHAIN_HEAVY_ATTACK_GRAPH_NODE_SCENE.instantiate()
	_add_graph_node(heavy_attack_graph_node)
	heavy_attack_graph_node.position = last_right_click_position
func _on_dodge_node_requested() -> void:
	var dodge_graph_node = CHARACTER_COMBO_CHAIN_DODGE_GRAPH_NODE_SCENE.instantiate()
	_add_graph_node(dodge_graph_node)
	dodge_graph_node.position = last_right_click_position
func _on_parry_node_requested() -> void:
	var parry_graph_node = CHARACTER_COMBO_CHAIN_PARRY_GRAPH_NODE_SCENE.instantiate()
	_add_graph_node(parry_graph_node)
	parry_graph_node.position = last_right_click_position
func _on_jux_dodge_node_requested() -> void:
	var jux_dodge_graph_node = CHARACTER_COMBO_CHAIN_JUXDODGE_GRAPH_NODE_SCENE.instantiate()
	_add_graph_node(jux_dodge_graph_node)
	jux_dodge_graph_node.position = last_right_click_position
func _on_jux_parry_node_requested() -> void:
	var jux_parry_graph_node = CHARACTER_COMBO_CHAIN_JUXPARRY_GRAPH_NODE_SCENE.instantiate()
	_graph_edit.add_child(jux_parry_graph_node)
	jux_parry_graph_node.position = last_right_click_position
	_add_graph_node(jux_parry_graph_node)
func _on_juxtapose_node_requested() -> void:
	var juxtapose_graph_node = CHARACTER_COMBO_CHAIN_JUXTAPOSE_GRAPH_NODE_SCENE.instantiate()
	_add_graph_node(juxtapose_graph_node)
	juxtapose_graph_node.position = last_right_click_position

func _confirm_delete_node(node: CharacterComboChainGraphNode):
	_delete_node_confirmation_dialog.popup()
	
	_delete_node_confirmation_dialog.canceled.connect(_on_delete_node_canceled)
	_delete_node_confirmation_dialog.confirmed.connect(_on_delete_node_confirmed.bind(node))
func _on_delete_node_canceled():
	_delete_node_confirmation_dialog.canceled.disconnect(_on_delete_node_canceled)
	_delete_node_confirmation_dialog.confirmed.disconnect(_on_delete_node_confirmed)
func _on_delete_node_confirmed(node: CharacterComboChainGraphNode):
	_delete_node_confirmation_dialog.canceled.disconnect(_on_delete_node_canceled)
	_delete_node_confirmation_dialog.confirmed.disconnect(_on_delete_node_confirmed)
	
	_remove_graph_node(node)

func _on_connection_request(from_node, from_port, to_node, to_port):
	var from_graph_node: CharacterComboChainGraphNode = _graph_edit.get_node(str(from_node)) as CharacterComboChainGraphNode
	var to_graph_node: CharacterComboChainGraphNode = _graph_edit.get_node(str(to_node)) as CharacterComboChainGraphNode
	
	print("Requested connection from {from} to {to}.".format({"from" : from_graph_node, "to" : to_graph_node}))
	
	var from_attack_node = from_graph_node.node
	var to_attack_node = to_graph_node.node
	
	if orphan_attack_nodes.has(from_attack_node):
		orphan_attack_nodes.erase(from_attack_node)
	if orphan_attack_nodes.has(to_attack_node):
		orphan_attack_nodes.erase(to_attack_node)
	
	if from_attack_node is CharacterComboChainRootNode:
		from_attack_node = from_attack_node as CharacterComboChainRootNode
		from_attack_node.starting_node = to_attack_node
	else:
		from_attack_node = from_attack_node as CharacterComboChainAttackNode
		from_attack_node.next_node = to_attack_node
	
	var print_message = "Connected CharacterComboChainGraphNode {from_node} to {to_node}".format({"from_node" : from_node, "to_node" : to_node})
	
	if not current_chain.nodes.has(from_attack_node):
		current_chain.nodes.append(from_attack_node)
		print_message = print_message + "\n- CharacterComboChainNode {node} no longer orphaned.".format({"node" : from_attack_node})
	if not current_chain.nodes.has(to_attack_node):
		current_chain.nodes.append(to_attack_node)
		print_message = print_message + "\n- CharacterComboChainNode {node} no longer orphaned.".format({"node" : to_attack_node})
	
	_graph_edit.connect_node(from_node, from_port, to_node, to_port)
	print(print_message)

func _on_disconnection_request(from_node, from_port, to_node, to_port):
	var from_graph_node: CharacterComboChainGraphNode = _graph_edit.get_node(str(from_node)) as CharacterComboChainGraphNode
	var to_graph_node: CharacterComboChainGraphNode = _graph_edit.get_node(str(to_node)) as CharacterComboChainGraphNode
	
	#if from_attack_node is CharacterComboChainRootNode:
		#from_attack_node = from_attack_node as CharacterComboChainRootNode
		#from_attack_node.starting_node = to_attack_node
	#else:
		#from_attack_node = from_attack_node as CharacterComboChainAttackNode
		#from_attack_node.next_node = to_attack_node
	#
	#to_graph_node.attack_node = to_attack_node
	_graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
	
	#var from_attack = _graph_edit.get_node(from_node).get_meta("attack_data")
	#var to_attack = _graph_edit.get_node(to_node).get_meta("attack_data")
	#from_attack.next_attacks.erase(to_attack)
	#_graph_edit.disconnect_node(from_node, from_port, to_node, to_port)

func _get_node_for_attack(attack_data: CharacterAttackData):
	for child in _graph_edit.get_children():
		if child is GraphNode and child.get_meta("attack_data") == attack_data:
			return child
	return null

# Animation Preview
func _toggle_animation_preview():
	_animation_preview_sidebar.visible = !_animation_preview_sidebar.visible

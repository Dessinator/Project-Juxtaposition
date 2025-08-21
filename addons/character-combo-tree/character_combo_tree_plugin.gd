@tool
extends EditorPlugin

var combo_editor_scene = preload("res://addons/character-combo-tree/editor/character_combo_editor.tscn")
var combo_editor

func _enter_tree():
	# Add the custom resource types to the "Create New Resource" dialog
	#add_custom_type("CharacterCombo", "Resource", preload("res://addons/character-combo-tree/character_combo.gd"), preload("res://icon.svg"))
	#add_custom_type("CharacterAttackData", "Resource", preload("res://addons/character-combo-tree/character_attack_data.gd"), preload("res://icon.svg"))

	# Instantiate and add the custom dock
	combo_editor = combo_editor_scene.instantiate()
	#add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, combo_editor)
	combo_editor.hide()

func _handles(object):
	# We handle objects of type CharacterCombo
	return object is CharacterCombo

func _edit(object):
	if combo_editor:
		remove_control_from_bottom_panel(combo_editor)
	
	# This is called when a CharacterCombo resource is selected
	if object:
		add_control_to_bottom_panel(combo_editor, "Combo Editor")
		combo_editor.set_combo_data(object)
	else:
		combo_editor.hide()

func _exit_tree():
	# Clean up when the plugin is disabled
	remove_control_from_bottom_panel(combo_editor)
	combo_editor.queue_free()
	#remove_custom_type("CharacterCombo")
	#remove_custom_type("CharacterAttackData")

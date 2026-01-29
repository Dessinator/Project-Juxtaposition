class_name PlayableCharacterPartyUI
extends Control

const CHARACTER_PARTY_SELECT_BUTTON_SCENE: PackedScene = preload("res://nodes/render/ui-render-handler/buttons/character-party-member-select-button/character_party_member_select_button.tscn")

signal character_selection_started
signal character_selection_confirmed
signal character_selection_canceled

signal character_details_requested(internal_name: StringName)
signal quick_select_requested
signal tentative_party_change_requested(party: Party)
signal party_deploy_requested
signal close_requested

@onready var _tab_container: TabContainer = %TabContainer

@onready var _deploy_button: Button = %DeployButton

@onready var _character_party_member_select_buttons_grid_container: GridContainer = %CharacterPartyMemberSelectButtonsGridContainer
@onready var _character_details_button: Button = %CharacterDetailsButton

@onready var _character_info_panel_container: PanelContainer = %CharacterInfoPanelContainer
@onready var _character_portrait_texture_rect: TextureRect = %CharacterPortraitTextureRect
@onready var _character_nickname_label: Label = %CharacterNicknameLabel
@onready var _character_level_label: Label = %CharacterLevelLabel
@onready var _character_health_bar: StatusBar = %CharacterHealthBar

var current_party: Party

var _character_party_member_select_button_group: ButtonGroup
var _character_party_member_select_buttons: Dictionary[StringName, CharacterPartyMemberSelectButton]

var _tentative_party: Party

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_tab_container_tab(0)

	_fill_character_select_panel()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# main

func _set_tab_container_tab(tab_index: int):
	_tab_container.current_tab = tab_index

# character select

## opens the character select tab and select the party member select button
## that corresponds to the clicked character (if there is one.)
## will also connect the button's toggled signal and bind member_index to it.
##
## Creates a new tentative party resource, copying the internal names provided
## by current_party.
func start_single_character_select(member_index: int):
	_set_tab_container_tab(1)

	_setup_single_character_select_menu(member_index)
	_setup_character_info_panel(current_party.member_internal_names[member_index])
	_setup_character_details_button(current_party.member_internal_names[member_index])
	_setup_new_tentative_party()

## opens the character select tab and selects all party member select buttons
## that correspond to the current party members.
## will also connect the button's toggled signal and bind member_index to it.
##
## Creates a new tentative party resource, copying the internal names provided
## by current_party.
func start_quick_character_select():
	_set_tab_container_tab(1)

	_setup_quick_character_select_menu()
	_setup_character_info_panel()
	_setup_character_details_button()
	_setup_new_tentative_party()

func cancel_character_select():
	_set_tab_container_tab(0)
	character_selection_canceled.emit()
	_reset_all_character_party_member_select_buttons()

func disable_deploy():
	_deploy_button.disabled = true
func enable_deploy():
	_deploy_button.disabled = false


func _setup_single_character_select_menu(member_index: int):
	for internal_name in _character_party_member_select_buttons.keys():
		var character_party_member_select_button = _character_party_member_select_buttons[internal_name]
		character_party_member_select_button.button.button_group = _character_party_member_select_button_group

		if not current_party.member_internal_names[member_index] == StringName():
			if internal_name == current_party.member_internal_names[member_index]:
				character_party_member_select_button.button.set_pressed_no_signal(true)

		character_party_member_select_button.button.toggled.connect(_on_character_party_single_select_button_toggled.bind(member_index, internal_name))
# treats an empty internal_name as a signal to hide the info panel.
func _setup_character_info_panel(internal_name: StringName = StringName()):
	if internal_name.is_empty():
		_character_info_panel_container.visible = false
		return
	
	_character_info_panel_container.visible = true

	var packet = Characters.get_character_packet(internal_name)
	print("viewing info for character "+str(packet.character_data.nickname))

	if packet.character_data.portrait:
		_character_portrait_texture_rect.texture = packet.character_data.portrait
	else:
		_character_portrait_texture_rect.texture = PlaceholderTexture2D.new()

	_character_nickname_label.text = "\"{nickname}\"".format({ "nickname" : packet.character_data.nickname })
	_character_level_label.text = "Lv. {level}".format({ "level" : packet.character_data.experience_level })
	# TODO: Implement storage of character health into character data somehow.
	# _character_health_bar
# ditto above
func _setup_character_details_button(internal_name: StringName = StringName()):
	if internal_name.is_empty():
		_character_details_button.visible = false
		if _character_details_button.pressed.is_connected(_on_character_details_button_pressed):
			_character_details_button.pressed.disconnect(_on_character_details_button_pressed)
		return
	
	_character_details_button.visible = true

	_character_details_button.pressed.connect(_on_character_details_button_pressed.bind(internal_name))


func _setup_quick_character_select_menu():
	_setup_character_details_button()
	var party_full = current_party.is_full()

	for i in range(current_party.member_internal_names.size()):
		var internal_name = current_party.member_internal_names[i]
		if internal_name.is_empty():
			continue

		var character_party_member_select_button = _character_party_member_select_buttons[internal_name]

		character_party_member_select_button.button.set_pressed_no_signal(true)
		character_party_member_select_button.show_member_index = true
		character_party_member_select_button.member_index = i + 1
	
	# go through and remove all the buttons from the button group
	for internal_name in _character_party_member_select_buttons.keys():
		var character_party_member_select_button = _character_party_member_select_buttons[internal_name]
		character_party_member_select_button.button.button_group = null

		character_party_member_select_button.button.toggled.connect(_on_character_party_quick_select_button_toggled.bind(internal_name))

		# if the party is full, disable the other options.
		if party_full:
			if current_party.member_internal_names.has(internal_name):
				continue
			_character_party_member_select_buttons[internal_name].button.disabled = true

func _setup_new_tentative_party():
	_tentative_party = current_party.duplicate_deep()

func _fill_character_select_panel():
	_character_party_member_select_button_group = ButtonGroup.new()
	_character_party_member_select_button_group.allow_unpress = true

	for character_packet: CharacterPacket in Characters.get_all_character_packets():
		var character_data = character_packet.character_data
		var character_party_select_button_instance: CharacterPartyMemberSelectButton = CHARACTER_PARTY_SELECT_BUTTON_SCENE.instantiate()
		_character_party_member_select_buttons_grid_container.add_child(character_party_select_button_instance)

		character_party_select_button_instance.button.button_group = _character_party_member_select_button_group
		character_party_select_button_instance.button.disabled = false

		character_party_select_button_instance.character_portrait = character_data.portrait
		character_party_select_button_instance.character_nickname = character_data.nickname
		character_party_select_button_instance.character_level = character_data.experience_level

		_character_party_member_select_buttons[character_data.internal_name] = character_party_select_button_instance

func _reset_all_character_party_member_select_buttons():
	for character_party_member_select_button in _character_party_member_select_buttons.values():
		character_party_member_select_button.button.set_pressed_no_signal(false)
		character_party_member_select_button.button.disabled = false
		character_party_member_select_button.show_member_index = false
		character_party_member_select_button.member_index = 0

		character_party_member_select_button.button.toggled.disconnect(_on_character_party_single_select_button_toggled)
		character_party_member_select_button.button.toggled.disconnect(_on_character_party_quick_select_button_toggled)

func _on_character_party_single_select_button_toggled(toggled_on: bool, member_index: int, internal_name: StringName):
	if toggled_on:
		# cant have more than one of the same party member
		# so get rid of the old one in the list.
		if _tentative_party.member_internal_names.has(internal_name):
			var index = _tentative_party.member_internal_names.find(internal_name)
			_tentative_party.member_internal_names[index] = StringName()

			
		_tentative_party.member_internal_names[member_index] = internal_name
		_setup_character_details_button(internal_name)
		_setup_character_info_panel(internal_name)
		tentative_party_change_requested.emit(_tentative_party)
		return
	
	_tentative_party.member_internal_names[member_index] = StringName()
	_setup_character_details_button()
	_setup_character_info_panel()
	tentative_party_change_requested.emit(_tentative_party)

func _on_character_party_quick_select_button_toggled(toggled_on: bool, internal_name: StringName):
	var button_pressed = _character_party_member_select_buttons[internal_name]
	
	if toggled_on:
		# if there is room in the party, add internal_name to the next empty spot.
		# if the party is full, disable every other button. cant add more than 3
		# members to the party.

		var found_space = false
		for i in range(_tentative_party.member_internal_names.size()):
			var member_internal_name = _tentative_party.member_internal_names[i]
			if member_internal_name.is_empty():
				# this is the next empty spot.
				found_space = true
				_tentative_party.member_internal_names[i] = internal_name
				tentative_party_change_requested.emit(_tentative_party)

				# set the member index on the button.
				button_pressed.show_member_index = true
				button_pressed.member_index = i + 1

				print(internal_name + " added.")
				break

		# if no space found, turn the button back off.
		# ideally the button should be disabled so this shouldnt happen but.
		# you know how things go.
		if not found_space:
			button_pressed.button.set_pressed_no_signal(false)
		
		# if there are no more empty spaces, disable all other buttons.
		if _tentative_party.is_full():
			for key in _character_party_member_select_buttons.keys():
				if _tentative_party.member_internal_names.has(key):
					continue
				_character_party_member_select_buttons[key].button.disabled = true
			print("party is now full. other options disabled.")
		
		return
	
	# if the party was full before removing a character, reenable all buttons.
	if _tentative_party.is_full():
		for key in _character_party_member_select_buttons.keys():
			_character_party_member_select_buttons[key].button.disabled = false
		print("party is no longer full. other options enabled.")

	
	if _tentative_party.member_internal_names.has(internal_name):
		var index = _tentative_party.member_internal_names.find(internal_name)
		_tentative_party.member_internal_names[index] = StringName()
	tentative_party_change_requested.emit(_tentative_party)

	# reset the member index on the button.
	button_pressed.show_member_index = false
	button_pressed.member_index = 0
	
	print(internal_name + " removed.")

func _confirm_character_selection():
	_set_tab_container_tab(0)
	character_selection_confirmed.emit()

	_reset_all_character_party_member_select_buttons()


func _open_party_synergy_menu():
	_set_tab_container_tab(2)

func _close_party_synergy_menu():
	_set_tab_container_tab(0)

# buttons

func _on_party_synergy_button_pressed() -> void:
	_open_party_synergy_menu()
func _on_party_synergy_close_button_pressed() -> void:
	_close_party_synergy_menu()

func _on_quick_select_button_pressed() -> void:
	quick_select_requested.emit()

func _on_character_select_cancel_button_pressed() -> void:
	cancel_character_select()

func _on_character_details_button_pressed(internal_name: StringName) -> void:
	print("requesting details for character by internal name "+str(internal_name))
	character_details_requested.emit(internal_name)

func _on_confirm_selection_button_pressed() -> void:
	_confirm_character_selection()

func _on_deploy_button_pressed() -> void:
	party_deploy_requested.emit()

func _on_close_button_pressed() -> void:
	close_requested.emit()

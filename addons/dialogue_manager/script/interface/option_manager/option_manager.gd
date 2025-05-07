extends Control
class_name OptionManager


const OptionContainer: Script = preload("./option_container.gd")
const OPTION_THEME: Theme = preload("./theme/option_theme.tres")

@export var base_container: Container
@export var h_size_flags: SizeFlags = SIZE_EXPAND_FILL
@export var text_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT

var _current_container: OptionContainer
var _container_info_list: Array[Dictionary]


func _init() -> void:
	theme = OPTION_THEME
	set_anchors_preset(Control.PRESET_FULL_RECT, true)
	z_index = 2
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func add_option(can_exit: bool = true, one_shot: bool = false) -> OptionContainer:
	var new_container: OptionContainer = _get_option_container(can_exit, one_shot)
	_add_container_list_data()
	if _current_container != null: _current_container.hide()
	add_child(new_container)

	_current_container = new_container
	return new_container


func add_main_option(one_shot: bool = true) -> OptionContainer:
	return add_option(false, one_shot)


func add_sub_option(one_shot: bool = true) -> OptionContainer:
	return add_option(true, one_shot)


func add_button(
	text: String,
	callable: Callable = Callable(),
	one_shot: bool = _current_container.one_shot,
	) -> Button:

	if _current_container == null: return
	var new_button: Button = _get_default_button()
	new_button.text = text
	new_button.alignment = text_alignment
	new_button.size_flags_horizontal = h_size_flags
	_current_container.add_button(new_button, callable, one_shot)
	return new_button


func add_custom_button(
	text: String,
	callable: Callable = Callable(),
	one_shot: bool = _current_container.one_shot,
	) -> CustomButton:

	if _current_container == null: return
	var new_button: CustomButton = CustomButton.new()
	new_button.text = text
	new_button.alignment = text_alignment
	new_button.size_flags_horizontal = h_size_flags
	_current_container.add_button(new_button, callable)
	return new_button


func add_long_press_button(
	text: String,
	callable: Callable = Callable(),
	one_shot: bool = _current_container.one_shot,
	) -> LongPressButton:

	if _current_container == null: return
	var new_button: LongPressButton = LongPressButton.new()
	new_button.text = text
	new_button.alignment = text_alignment
	new_button.size_flags_horizontal = h_size_flags
	_current_container.add_long_press_button(new_button, callable)
	return new_button


func set_button_horizontal(index: int = 0) -> void:
	if _current_container == null: return
	_current_container.set_button_horizontal(index)


func set_button_vertical(index: int = 0) -> void:
	if _current_container == null: return
	_current_container.set_button_vertical(index)


func reset_option() -> void:
	for child in get_children(): child.queue_free()
	_container_info_list.clear()
	_current_container = null


func hide_option() -> void:
	if _current_container == null: return
	_add_container_list_data()
	_current_container.hide()
	_current_container = null


func show_option() -> void:
	if _current_container == null && not _container_info_list.is_empty():
		_on_container_exited()


func _get_default_button() -> Button:
	var new_button: Button = Button.new()
	new_button.custom_minimum_size.x = size.x * 0.25
	new_button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	new_button.mouse_entered.connect(new_button.grab_focus)
	return new_button


func _get_option_container(
	can_exit: bool = true,
	one_shot: bool = false,
	) -> OptionContainer:

	var new_container: Container = base_container.duplicate() if (
		base_container != null) else _get_default_container()
	new_container.set_script(OptionContainer)
	new_container = new_container as OptionContainer

	new_container.can_exit = can_exit
	new_container.one_shot = one_shot

	new_container.tree_exited.connect(_on_container_exited)
	return new_container


func _get_default_container() -> VBoxContainer:
	var new_container: VBoxContainer = VBoxContainer.new()
	new_container.custom_minimum_size.x = size.x * 0.25
	new_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	new_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	new_container.set_anchors_preset(Control.PRESET_CENTER, true)
	return new_container


func _add_container_list_data() -> Dictionary:
	var current_focus: Control = get_viewport().gui_get_focus_owner()
	var list_info: Dictionary = {
		"previous_container": _current_container,
		"previous_focus": current_focus,
	}
	_container_info_list.append(list_info)
	return list_info


func _on_container_exited() -> void:
	var last_info: Dictionary = _container_info_list.pop_back()
	var previous_container: OptionContainer = last_info.get("previous_container")
	var previous_focus: Control = last_info.get("previous_focus")
	if previous_container != null:
		previous_container.show()
	_grab_previous_focus(previous_focus)
	_current_container = previous_container


func _grab_previous_focus(focus: Control) -> void:
	if is_instance_valid(focus)\
	&& focus.is_visible_in_tree()\
	&& focus.focus_mode != Control.FOCUS_NONE:
		focus.grab_focus.call_deferred()

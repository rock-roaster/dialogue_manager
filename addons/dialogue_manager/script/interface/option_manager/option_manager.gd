extends Control
class_name OptionManager


const OptionContainer := preload("./option_container.gd")

const OPTION_THEME: Theme = preload("./theme/option_theme.tres")

@export var base_container: Container
@export var h_size_flags: SizeFlags = SIZE_EXPAND_FILL
@export var text_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT

var current_container: OptionContainer
var current_previous_focus: Control


func _init() -> void:
	theme = OPTION_THEME

	set_anchors_preset(Control.PRESET_FULL_RECT, true)
	z_index = 3
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func add_option(can_exit: bool = true, one_shot: bool = false) -> OptionContainer:
	var new_container: OptionContainer = _get_option_container(can_exit, one_shot)
	if current_container != null: current_container.hide()
	current_container = new_container
	add_child(new_container)
	return new_container


func add_main_option(one_shot: bool = false) -> OptionContainer:
	return add_option(false, one_shot)


func add_sub_option(one_shot: bool = true) -> OptionContainer:
	return add_option(true, one_shot)


func add_button(text: String, callable: Callable = Callable()) -> Button:
	var new_button: Button = _get_default_button()
	new_button.text = text
	new_button.alignment = text_alignment
	new_button.size_flags_horizontal = h_size_flags
	current_container.add_button(new_button, callable)
	return new_button


func add_custom_button(text: String, callable: Callable = Callable()) -> CustomButton:
	var new_button: CustomButton = CustomButton.new()
	new_button.text = text
	new_button.alignment = text_alignment
	new_button.size_flags_horizontal = h_size_flags
	current_container.add_button(new_button, callable)
	return new_button


func add_long_press_button(text: String, callable: Callable = Callable()) -> LongPressButton:
	var new_button: LongPressButton = LongPressButton.new()
	new_button.text = text
	new_button.alignment = text_alignment
	new_button.size_flags_horizontal = h_size_flags
	current_container.add_long_press_button(new_button, callable)
	return new_button


func set_button_horizontal() -> void:
	var button_array: Array[Button] = current_container.button_array
	if !button_array: return
	button_array[0].focus_neighbor_left = button_array[-1].get_path()
	button_array[-1].focus_neighbor_right = button_array[0].get_path()
	button_array[0].grab_focus.call_deferred()


func set_button_vertical() -> void:
	var button_array: Array[Button] = current_container.button_array
	if !button_array: return
	button_array[0].focus_neighbor_top = button_array[-1].get_path()
	button_array[-1].focus_neighbor_bottom = button_array[0].get_path()
	button_array[0].grab_focus.call_deferred()


func reset_option() -> void:
	for child in get_children(): child.queue_free()
	current_container = null


func hide_option() -> void:
	current_previous_focus = get_viewport().gui_get_focus_owner()
	current_container.hide()


func show_option() -> void:
	current_container.show()
	_grab_previous_focus(current_previous_focus)


func _get_default_button() -> Button:
	var new_button: Button = Button.new()
	new_button.custom_minimum_size.x = 480.0
	new_button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	new_button.mouse_entered.connect(new_button.grab_focus)
	return new_button


func _get_option_container(
	can_exit: bool = true,
	one_shot: bool = false,
	) -> OptionContainer:

	var new_container: Container = base_container.duplicate()\
		if base_container != null else _get_default_container()
	new_container.set_script(OptionContainer)
	new_container = new_container as OptionContainer

	new_container.can_exit = can_exit
	new_container.one_shot = one_shot

	var option_focus: Control = get_viewport().gui_get_focus_owner()
	new_container.tree_exited.connect(
		_on_option_return.bind(current_container, option_focus))
	return new_container


func _get_default_container() -> VBoxContainer:
	var new_container: VBoxContainer = VBoxContainer.new()
	new_container.custom_minimum_size.x = 480.0
	new_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	new_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	new_container.set_anchors_preset(Control.PRESET_CENTER, true)
	return new_container


func _on_option_return(option: OptionContainer, focus: Control) -> void:
	current_container = option
	if current_container != null: current_container.show()
	_grab_previous_focus(focus)


func _grab_previous_focus(focus: Control) -> void:
	if is_instance_valid(focus) && focus.is_visible_in_tree():
		if focus.focus_mode != Control.FOCUS_NONE: focus.grab_focus.call_deferred()

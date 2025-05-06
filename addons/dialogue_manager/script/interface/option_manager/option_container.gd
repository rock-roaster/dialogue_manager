extends Container


var can_exit: bool = false
var one_shot: bool = false

var _button_array: Array[Button]


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return
	if event.is_action_pressed(&"ui_left"): grab_button_focus(0)
	if event.is_action_pressed(&"ui_right"): grab_button_focus(-1)
	if event.is_action_pressed(&"ui_cancel") && can_exit:
		exit_option_container()


func exit_option_container() -> void:
	get_viewport().set_input_as_handled()
	queue_free()


func grab_button_focus(index: int) -> void:
	if _button_array.is_empty(): return
	get_viewport().set_input_as_handled()
	_button_array[index].grab_focus.call_deferred()


func add_button(
	button: Button,
	callable: Callable = Callable(),
	close_after_press: bool = one_shot,
	) -> void:

	if callable.is_valid():
		button.pressed.connect(callable)
	if close_after_press:
		button.pressed.connect(exit_option_container)

	_button_array.append(button)
	add_child(button)


func add_long_press_button(
	button: LongPressButton,
	callable: Callable = Callable(),
	close_after_press: bool = one_shot,
	) -> void:

	if callable.is_valid():
		button.long_pressed.connect(callable)
	if close_after_press:
		button.long_pressed.connect(exit_option_container)

	_button_array.append(button)
	add_child(button)


func set_button_horizontal() -> void:
	if _button_array.is_empty(): return
	_button_array[0].focus_neighbor_left = _button_array[-1].get_path()
	_button_array[-1].focus_neighbor_right = _button_array[0].get_path()
	_button_array[0].grab_focus.call_deferred()


func set_button_vertical() -> void:
	if _button_array.is_empty(): return
	_button_array[0].focus_neighbor_top = _button_array[-1].get_path()
	_button_array[-1].focus_neighbor_bottom = _button_array[0].get_path()
	_button_array[0].grab_focus.call_deferred()

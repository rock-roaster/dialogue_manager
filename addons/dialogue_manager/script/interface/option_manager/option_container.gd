extends Container


var can_exit: bool = false
var one_shot: bool = false

var _button_array: Array[Button]


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return
	if event.is_action_pressed(&"ui_cancel") && can_exit:
		exit_option_container()


func exit_option_container() -> void:
	get_viewport().set_input_as_handled()
	queue_free()


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
	var button_head: Button = _button_array[0]
	var button_back: Button = _button_array[-1]

	var previous_button: Button = button_back
	for button in _button_array:
		button.focus_neighbor_top = button_head.get_path()
		button.focus_neighbor_bottom = button_back.get_path()
		button.focus_neighbor_left = previous_button.get_path()
		previous_button.focus_neighbor_right = button.get_path()
		previous_button = button

	button_head.grab_focus.call_deferred()


func set_button_vertical() -> void:
	if _button_array.is_empty(): return
	var button_head: Button = _button_array[0]
	var button_back: Button = _button_array[-1]

	var previous_button: Button = button_back
	for button in _button_array:
		button.focus_neighbor_left = button_head.get_path()
		button.focus_neighbor_right = button_back.get_path()
		button.focus_neighbor_top = previous_button.get_path()
		previous_button.focus_neighbor_bottom = button.get_path()
		previous_button = button

	button_head.grab_focus.call_deferred()

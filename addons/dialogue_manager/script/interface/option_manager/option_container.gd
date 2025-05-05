extends Container


var can_exit: bool = false
var one_shot: bool = false

var button_array: Array[Button]


func _input(event: InputEvent) -> void:
	if !is_visible_in_tree(): return
	if event.is_action_pressed(&"ui_cancel") && can_exit:
		exit_option_container()
	if event.is_action_pressed(&"ui_left"): grab_button_focus(0)
	if event.is_action_pressed(&"ui_right"): grab_button_focus(-1)


func exit_option_container() -> void:
	get_viewport().set_input_as_handled()
	queue_free()


func grab_button_focus(index: int) -> void:
	if !button_array: return
	get_viewport().set_input_as_handled()
	button_array[index].grab_focus.call_deferred()


func add_button(
	button: Button,
	callable: Callable = Callable(),
	close_after_press: bool = one_shot,
	) -> Button:

	if callable: button.pressed.connect(callable)
	if close_after_press: button.pressed.connect(exit_option_container)
	button_array.append(button)
	add_child(button)
	return button


func add_long_press_button(
	button: LongPressButton,
	callable: Callable = Callable(),
	close_after_press: bool = one_shot,
	) -> LongPressButton:

	if callable: button.long_pressed.connect(callable)
	if close_after_press: button.long_pressed.connect(exit_option_container)
	button_array.append(button)
	add_child(button)
	return button

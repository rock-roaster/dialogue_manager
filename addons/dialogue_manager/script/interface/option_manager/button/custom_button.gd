extends Button


func _init() -> void:
	custom_minimum_size.x = 480.0
	mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _ready() -> void:
	mouse_entered.connect(grab_focus)
	focus_entered.connect(on_focus_entered)
	focus_exited.connect(on_focus_exited)


func on_focus_entered() -> void:
	tween_miminum_size(48.0)


func on_focus_exited() -> void:
	tween_miminum_size(0.0)


func tween_miminum_size(value: float, time: float = 0.25) -> void:
	var target_size: float = custom_minimum_size.x + value
	var tween_size: Tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween_size.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween_size.tween_property(self, ^"size:x", target_size, time)
	await tween_size.finished


func tween_stylebox_margin(left: float, right: float, time: float = 0.25) -> void:
	var tween_stylebox: Tween = create_tween().set_parallel()
	tween_stylebox.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	var stylebox_list: PackedStringArray = theme.get_stylebox_list("Button")
	for stylebox_name in stylebox_list:
		var stylebox: StyleBox = get_theme_stylebox(stylebox_name)
		tween_stylebox.tween_property(stylebox, "expand_margin_left", left, time)
		tween_stylebox.tween_property(stylebox, "expand_margin_right", right, time)

	await tween_stylebox.finished

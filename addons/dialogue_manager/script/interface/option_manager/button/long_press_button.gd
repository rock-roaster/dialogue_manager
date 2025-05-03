extends Button
class_name LongPressButton


signal long_pressed

const BUTTON_THEME: Theme = preload("./long_press_button.tres")

@export_range(0.2, 1.0, 0.1) var hold_time: float = 0.5
@export var pressing_loop: bool = false

var is_long_pressing: bool

var _tween_progress: Tween

var _flash_light: ColorRect
var _progress_bar: ProgressBar


func _init() -> void:
	theme = BUTTON_THEME
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_build_node_structure()

	mouse_entered.connect(grab_focus)
	button_down.connect(progress_start)
	button_up.connect(progress_stop)
	mouse_exited.connect(progress_stop)


func _build_node_structure() -> void:
	_flash_light = ColorRect.new()
	_flash_light.color = Color(1.0, 1.0, 1.0, 0.5)
	_flash_light.z_index = 1
	_flash_light.modulate.a = 0.0
	_flash_light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_light.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	add_child(_flash_light)

	_progress_bar = ProgressBar.new()
	_progress_bar.show_percentage = false
	_progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_progress_bar.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	add_child(_progress_bar)


func progress_start() -> void:
	if is_long_pressing: return
	is_long_pressing = true

	if _tween_progress: _tween_progress.kill()
	_tween_progress = create_tween()
	_tween_progress.tween_property(_progress_bar, ^"value", _progress_bar.max_value, hold_time)
	_tween_progress.tween_callback(button_long_pressed)


func progress_stop() -> void:
	if not is_long_pressing: return
	is_long_pressing = false

	if _tween_progress: _tween_progress.kill()

	var fake_progress: ProgressBar = _progress_bar.duplicate()
	add_child(fake_progress)
	_progress_bar.value = 0.0

	var tween_time: float = clampf(fake_progress.value * hold_time * 0.01, 0.2, hold_time)
	var tween_fake: Tween = fake_progress.create_tween()
	tween_fake.tween_property(fake_progress, ^"modulate:a", 0.0, tween_time)
	tween_fake.tween_callback(fake_progress.queue_free)


func button_long_pressed() -> void:
	is_long_pressing = false
	_progress_bar.value = 0.0

	long_pressed.emit()
	if pressing_loop: progress_start.call_deferred()

	_flash_light.modulate.a = 1.0
	var tween_flash_light: Tween = create_tween()
	tween_flash_light.tween_property(_flash_light, ^"modulate:a", 0.0, hold_time)

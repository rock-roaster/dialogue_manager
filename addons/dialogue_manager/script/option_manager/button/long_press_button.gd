extends Button
class_name LongPressButton


signal long_pressed

const BUTTON_THEME: Theme = preload("./long_press_button.tres")

@export_range(0.2, 1.0, 0.1) var press_time: float = 0.5
@export var keep_pressing: bool = false

var tween_progress: Tween

var progress_bar: ProgressBar
var fake_board: Control
var flash_light: ColorRect


func _init() -> void:
	theme = BUTTON_THEME
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	_build_node_structure()


func _ready() -> void:
	mouse_entered.connect(grab_focus)
	button_up.connect(progress_stop)
	button_down.connect(progress_start)


func _build_node_structure() -> void:
	progress_bar = ProgressBar.new()
	progress_bar.show_percentage = false
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	add_child(progress_bar)

	fake_board = Control.new()
	fake_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fake_board.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	add_child(fake_board)

	flash_light = ColorRect.new()
	flash_light.color = Color(Color.WHITE, 0.5)
	flash_light.modulate.a = 0.0
	flash_light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_light.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	add_child(flash_light)


func progress_start() -> void:
	tween_progress = create_tween()
	tween_progress.tween_property(progress_bar, ^"value", progress_bar.max_value, press_time)
	tween_progress.tween_callback(button_long_pressed)


func progress_stop() -> void:
	if tween_progress: tween_progress.kill()

	var fake_progress: ProgressBar = progress_bar.duplicate()
	fake_board.add_child(fake_progress)
	progress_bar.value = 0.0

	var tween_time: float = clampf(fake_progress.value * press_time * 0.01, 0.2, press_time)
	var tween_fake: Tween = fake_progress.create_tween()
	tween_fake.tween_property(fake_progress, ^"modulate:a", 0.0, tween_time)
	tween_fake.tween_callback(fake_progress.queue_free)


func button_long_pressed() -> void:
	progress_bar.value = 0.0
	flash_light.modulate.a = 1.0

	long_pressed.emit()
	create_tween().tween_property(flash_light, ^"modulate:a", 0.0, press_time)
	if keep_pressing: progress_start.call_deferred()

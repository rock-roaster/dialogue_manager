extends VBoxContainer
class_name ScreenMargin


var top_bar: ColorRect
var bottom_bar: ColorRect

var top_panel: PanelContainer
var bottom_panel: PanelContainer


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT, true)
	z_index = 3
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_node_structure()


func _build_node_structure() -> void:
	var padding_control: Control = Control.new()
	padding_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padding_control.size_flags_vertical = Control.SIZE_EXPAND_FILL

	top_bar = ColorRect.new()
	top_bar.color = Color.BLACK

	bottom_bar = ColorRect.new()
	bottom_bar.color = Color.BLACK

	add_child(top_bar)
	add_child(padding_control)
	add_child(bottom_bar)

	var bar_panel: PanelContainer = PanelContainer.new()
	bar_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bar_panel.add_theme_stylebox_override(&"panel", StyleBoxEmpty.new())

	top_panel = bar_panel.duplicate()
	bottom_panel = bar_panel.duplicate()
	bar_panel.queue_free()

	top_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM, true)
	bottom_panel.set_anchors_preset(Control.PRESET_CENTER_TOP, true)

	top_bar.add_child(top_panel)
	bottom_bar.add_child(bottom_panel)


func change_bar_size(value: float) -> void:
	var bar_size_tweener: Tween = create_tween().set_parallel()
	bar_size_tweener.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	bar_size_tweener.tween_property(top_bar, ^"custom_minimum_size:y", value, 0.25)
	bar_size_tweener.tween_property(bottom_bar, ^"custom_minimum_size:y", value, 0.25)
	await bar_size_tweener.finished

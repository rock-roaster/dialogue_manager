extends CanvasLayer
class_name DialogueLayer


signal dialogue_label_popup (label: DialogueLabel)

@export var enable: bool

var _processing_label: DialogueLabel
var _dialogue_labels: Dictionary[StringName, DialogueLabel]

var _popup_position: Vector2
var _popup_direction: int
var _popup_parent: Node
var _use_label_bubble: bool

var _break_tweening: bool
var _ms_per_char: float
var _auto_advance_time: float

var _dialogue_manager: Dialogue = Dialogue


func _init() -> void:
	var screen_size_x: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screen_size_y: int = ProjectSettings.get_setting("display/window/size/viewport_height")

	_popup_position = Vector2(screen_size_x, screen_size_y) * 0.5
	_popup_direction = DialogueLabelBubble.PopupDirection.NONE
	_popup_parent = self
	_use_label_bubble = true

	_break_tweening = _dialogue_manager.get_setting_value("break_tweening")
	_ms_per_char = _dialogue_manager.get_setting_value("msec_per_character")
	_auto_advance_time = _dialogue_manager.get_setting_value("auto_advance_time")

	_dialogue_manager.dialogue_line_pushed.connect(_on_dialogue_line_pushed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()


func _on_accept_pressed() -> void:
	if not enable: return
	get_viewport().set_input_as_handled()

	if _processing_label != null && _processing_label.visible_characters_processing():
		if _break_tweening:
			_processing_label.break_visible_characters_process()
		return

	_dialogue_manager.get_next_line()


func _on_dialogue_line_pushed(line: DialogueLine) -> void:
	if not line.is_type_text(): return
	var label_name: StringName = line.get_data("name", "")
	close_dialogue_label(label_name)

	if line.get_text() != [""]:
		var new_dialogue_label: DialogueLabel = popup_dialogue_label(line, label_name)
		_processing_label = new_dialogue_label
		dialogue_label_popup.emit(new_dialogue_label)
		await new_dialogue_label.show_line_text(line)
		_processing_label = null

	_on_dialogue_line_finished(line)


func _on_dialogue_line_finished(line: DialogueLine) -> void:
	if line.get_data("auto_advance", false):
		var line_auto_advance_time: float = line.get_data("auto_time", _auto_advance_time)
		line_auto_advance_time = clampf(line_auto_advance_time, 0.0, line_auto_advance_time)
		await get_tree().create_timer(line_auto_advance_time).timeout

		_dialogue_manager._finish_line()
		_dialogue_manager.get_next_line()
	else:
		_dialogue_manager._finish_line()


func set_popup_parent(value: Node) -> void:
	_popup_parent = value


func set_popup_position(value: Vector2) -> void:
	_popup_position = value


func set_popup_direction(value: int) -> void:
	_popup_direction = value


func set_use_label_bubble(value: bool) -> void:
	_use_label_bubble = value


func popup_dialogue_label(line: DialogueLine, label_name: StringName = "") -> DialogueLabel:
	var line_position: Vector2 = line.get_data("position", _popup_position)
	var line_direction: int = line.get_data("direction", _popup_direction)
	var line_ms_per_char: float = line.get_data("ms_per_char", _ms_per_char)
	var line_bbcode_enabled: bool = line.get_data("bbcode_enabled", true)
	var line_pause_between_parts: float = line.get_data("gaps_time", 0.0)
	var line_popup_parent: Node = line.get_data("popup_parent", _popup_parent)
	var line_label_bubble: bool = line.get_data("label_bubble", _use_label_bubble)

	# 此处判断条件可自行修改，以适应弹出对话位置变化
	if line_popup_parent.get("position") != null:
		line_position = Vector2.ZERO

	var new_dialogue_label: DialogueLabel
	if not line_label_bubble:
		new_dialogue_label = DialogueLabel.new(
			line_ms_per_char,
			line_bbcode_enabled,
			line_pause_between_parts,
		)
	else:
		new_dialogue_label = DialogueLabelBubble.new(
			line_position,
			line_direction,
			line_ms_per_char,
			line_bbcode_enabled,
			line_pause_between_parts,
		)

	_dialogue_labels.set(label_name, new_dialogue_label)
	line_popup_parent.add_child(new_dialogue_label)
	return new_dialogue_label


func close_dialogue_label(label_name: StringName = "") -> void:
	if not _dialogue_labels.has(label_name): return
	var target_label: DialogueLabel = _dialogue_labels.get(label_name, null) as DialogueLabel
	_dialogue_labels.erase(label_name)
	if target_label == null: return
	target_label.get_parent().remove_child(target_label)
	target_label.queue_free()

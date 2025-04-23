extends CanvasLayer
class_name DialogueLayer


@export var enable: bool

var _dialogue_labels: Dictionary[StringName, DialogueLabel]

var _popup_parent: Node
var _popup_position: Vector2
var _popup_direction: DialogueLabelBubble.PopupDirection

var _break_tweening: bool
var _ms_per_char: float
var _auto_advance_time: float

var _dialogue_manager: Dialogue:
	get: return Dialogue


func _init() -> void:
	var screen_size_x: int = ProjectSettings.get_setting("display/window/size/viewport_width", 1920)
	var screen_size_y: int = ProjectSettings.get_setting("display/window/size/viewport_height", 1080)

	_popup_parent = self
	_popup_position = Vector2(screen_size_x, screen_size_y) * 0.5
	_popup_direction = DialogueLabelBubble.PopupDirection.NONE

	_break_tweening = _dialogue_manager.get_setting_value("break_tweening")
	_ms_per_char = _dialogue_manager.get_setting_value("msec_per_character")
	_auto_advance_time = _dialogue_manager.get_setting_value("auto_advance_time")

	_dialogue_manager.dialogue_line_pushed.connect(_on_dialogue_line_pushed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()


func _on_accept_pressed() -> void:
	if not enable: return
	get_viewport().set_input_as_handled()

	var current_label: DialogueLabel = _dialogue_labels.get("")
	if current_label != null && current_label.is_tweening():
		if _break_tweening: current_label.skip_tween_part()
		return

	_dialogue_manager.get_next_line()


func _on_dialogue_line_pushed(line: DialogueLine) -> void:
	if not line.is_type_text(): return
	var label_name: StringName = line.get_data("name", "")
	close_dialogue_label(label_name)

	if line.get_text() != [""]:
		var new_dialogue_label: DialogueLabel = popup_dialogue_label(line, label_name)
		await new_dialogue_label.show_line_text(line)

	_on_dialogue_line_finished(line)


func _on_dialogue_line_finished(line: DialogueLine) -> void:
	if line.get_data("auto_advance"):
		var line_auto_advance_time: float = line.get_data("auto_time") if\
			line.has_data("auto_time") else _auto_advance_time
		line_auto_advance_time = clampf(line_auto_advance_time, 0.0, line_auto_advance_time)
		await get_tree().create_timer(line_auto_advance_time).timeout
		_dialogue_manager._finish_line()
		_dialogue_manager.get_next_line()
	else:
		_dialogue_manager._finish_line()


func set_popup_parent(node: Node) -> void:
	_popup_parent = node


func set_popup_position(position: Vector2) -> void:
	_popup_position = position


func set_popup_direction(direction: DialogueLabelBubble.PopupDirection) -> void:
	_popup_direction = direction


func popup_dialogue_label(line: DialogueLine, label_name: StringName = "") -> DialogueLabel:
	var line_popup_label: bool = line.get_data("popup_label")\
		if line.has_data("popup_label") else true
	var line_position: Vector2 = line.get_data("position")\
		if line.has_data("position") else _popup_position
	var line_direction: DialogueLabelBubble.PopupDirection = line.get_data("direction")\
		if line.has_data("direction") else _popup_direction
	var line_ms_per_char: float = line.get_data("ms_per_char")\
		if line.has_data("ms_per_char") else _ms_per_char
	var line_bbcode_enabled: bool = line.get_data("bbcode_enabled")\
		if line.has_data("bbcode_enabled") else true
	var line_pause_between_parts: float = line.get_data("gaps_time")\
		if line.has_data("gaps_time") else 0.0
	var line_popup_parent: Node = line.get_data("popup_parent")\
		if line.has_data("popup_parent") else _popup_parent

	var new_dialogue_label: DialogueLabel
	if line_popup_label:
		new_dialogue_label = DialogueLabelBubble.new(
			line_position,
			line_direction,
			line_ms_per_char,
			line_bbcode_enabled,
			line_pause_between_parts,
		)
	else:
		new_dialogue_label = DialogueLabel.new(
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

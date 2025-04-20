extends CanvasLayer
class_name DialogueLayer


@export var enable: bool

var _popup_dialogue_label: DialogueLabel

var _popup_position: Vector2
var _popup_direction: DialogueLabel.PopupDirection

var _dialogue_labels: Dictionary[StringName, DialogueLabel]

var _break_tweening: bool = Dialogue.get_setting_value("break_tweening")
var _auto_advance_time: float = Dialogue.get_setting_value("auto_advance_time")


func _init() -> void:
	Dialogue.dialogue_line_pushed.connect(_on_dialogue_line_pushed)


func _ready() -> void:
	_popup_position = get_viewport().size * 0.5
	_popup_direction = DialogueLabel.PopupDirection.NONE


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()


func _on_accept_pressed() -> void:
	if not enable: return
	get_viewport().set_input_as_handled()

	if _popup_dialogue_label != null && _popup_dialogue_label.is_tweening():
		if _break_tweening: _popup_dialogue_label.skip_tween_part()
		return

	Dialogue.get_next_line()


func _on_dialogue_line_pushed(line: DialogueLine) -> void:
	if not line.is_type_text(): return
	close_dialogue_label()

	var label_name: StringName = line.get_data("name", "")
	popup_dialogue_label(line, label_name)
	await _popup_dialogue_label.show_line_text(line)
	_on_dialogue_line_finished(line)


func _on_dialogue_line_finished(line: DialogueLine) -> void:
	if line.get_data("auto_advance"):
		await get_tree().create_timer(_auto_advance_time).timeout
		Dialogue._finish_line()
		Dialogue.get_next_line()
	else:
		Dialogue._finish_line()


func set_popup_position(position: Vector2) -> void:
	_popup_position = position


func set_popup_direction(direction: DialogueLabel.PopupDirection) -> void:
	_popup_direction = direction


func popup_dialogue_label(line: DialogueLine, label_name: StringName = "") -> DialogueLabel:
	var line_position: Vector2 = line.get_data("position")\
		if line.has_data("position") else _popup_position
	var line_direction: DialogueLabel.PopupDirection = line.get_data("direction")\
		if line.has_data("direction") else _popup_direction
	var line_bbcode_enabled: bool = line.get_data("bbcode")\
		if line.has_data("bbcode") else true
	var line_gaps_between_parts: float = line.get_data("gaps_time")\
		if line.has_data("gaps_time") else 0.0

	var new_dialogue_label: DialogueLabel = DialogueLabel.new(
		line_position,
		line_direction,
		line_bbcode_enabled,
		line_gaps_between_parts,
		)

	_popup_dialogue_label = new_dialogue_label
	_dialogue_labels.set(label_name, new_dialogue_label)
	add_child(new_dialogue_label)
	return new_dialogue_label


func close_dialogue_label(label_name: StringName = "") -> void:
	if not _dialogue_labels.has(label_name): return
	var target_label: DialogueLabel = _dialogue_labels.get(label_name, null) as DialogueLabel
	_dialogue_labels.erase(label_name)
	if target_label == null: return
	target_label.get_parent().remove_child(target_label)
	target_label.queue_free()

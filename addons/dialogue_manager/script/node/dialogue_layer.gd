extends CanvasLayer
class_name DialogueLayer


@export var enable: bool
@export var dialogue_label: DialogueLabel

var _popup_dialogue_label: DialogueLabel
var _popup_position: Vector2

var _auto_advance_time: float = Dialogue.get_setting_value("auto_advance_time")


func _init() -> void:
	_popup_position = Vector2(1920, 1080) * 0.5
	Dialogue.dialogue_line_pushed.connect(_on_dialogue_line_pushed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()


func _on_accept_pressed() -> void:
	if not enable: return
	if dialogue_label == null: return
	get_viewport().set_input_as_handled()

	if dialogue_label.is_tweening(): return
	Dialogue.get_next_line()


func _on_dialogue_line_pushed(line: DialogueLine) -> void:
	if not line.is_type_text(): return

	dialogue_label.popup_position = _popup_position
	await dialogue_label.show_line_text(line)

	if line.get_data("auto_advance"):
		await get_tree().create_timer(_auto_advance_time).timeout
		Dialogue._finish_line()
		Dialogue.get_next_line()
	else:
		Dialogue._finish_line()


func set_dialogue_label(label: DialogueLabel) -> void:
	if label is not DialogueLabel: return
	dialogue_label = label

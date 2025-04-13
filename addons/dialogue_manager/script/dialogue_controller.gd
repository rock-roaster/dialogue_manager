extends Node
class_name DialogueController


@export var dialogue_label: DialogueLabel


func _init() -> void:
	Dialogue.dialogue_line_pushed.connect(_on_dialogue_line_pushed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()


func _on_accept_pressed() -> void:
	if dialogue_label == null: return
	if dialogue_label._text_tweening:
		dialogue_label.break_tween()
		return

	Dialogue.get_next_line()


func _on_dialogue_line_pushed(line: DialogueLine) -> void:
	if not line.is_type_text(): return

	await dialogue_label.show_line_text(line)
	Dialogue._finish_line()

	if line.get_data("auto_advance"):
		Dialogue.get_next_line()


func set_dialogue_label(label: DialogueLabel) -> void:
	if label is not DialogueLabel: return
	dialogue_label = label

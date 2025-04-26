extends Control


var _speaking_character: Character

@onready var dialogue_layer: DialogueLayer = $DialogueLayer


func _ready() -> void:
	dialogue_layer.dialogue_label_popup.connect(_on_label_popup)

	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"layer": dialogue_layer,
			"char_01": $Character1,
			"char_02": $Character2,
			"node_01": $Character1/Control,
			"node_02": $Character2/Control,
			"node_03": $Panel,
			"node_04": $Control,
			"call_01": set_speaking_character,
		}
	)


func set_speaking_character(value: Character) -> void:
	_speaking_character = value


func _on_label_popup(label: DialogueLabel) -> void:
	if _speaking_character == null: return
	_speaking_character.set_speaking_label(label)

extends Control


@onready var dialogue_layer: DialogueLayer = $DialogueLayer
@onready var character: Character = $Character


func _ready() -> void:
	dialogue_layer.dialogue_label_popup.connect(_on_label_popup)
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/script_sample.gd",
		{
			"node_01": $Panel,
			"node_02": $Control,
			"char_01": character,
			"push_01": $Character/Control,
			"push_02": $Character/Control2,
		}
	)


func _on_label_popup(label: DialogueLabel) -> void:
	character.set_speaking_label(label)

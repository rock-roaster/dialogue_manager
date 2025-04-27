extends Control


func _ready() -> void:
	var dialogue_layer: DialogueLayer = $DialogueLayer
	Dialogue.load_dialogue_script(
		"res://addons/dialogue_manager/tester/sample_script.gd",
		{
			"char_01": $Character1,
			"char_02": $Character2,
			"node_01": $Point1,
			"node_02": $Point2,
			"node_03": $Panel,
			"call_01": dialogue_layer.set_speaking_character,
		}
	)
